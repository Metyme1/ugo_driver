import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../config/theme.dart';
import '../../services/group_service.dart';
import '../../services/university_scan_service.dart';
import '../../services/nfc_scan_service.dart';
import '../../services/offline_qr_service.dart';
import '../../services/api_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with WidgetsBindingObserver {
  final _groupService = GroupService();
  final _uniService = UniversityScanService(ApiService());
  final _nfcService = NfcScanService();
  late final MobileScannerController _controller;
  StreamSubscription<List<ConnectivityResult>>? _connectSub;

  bool _isProcessing = false;
  bool _nfcMode = false;
  bool _nfcWaiting = false; // NFC session is active, waiting for tap
  bool _isOffline = false;

  // QR debounce state
  Timer? _debounce;
  String? _pendingValue;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(autoStart: true);
    WidgetsBinding.instance.addObserver(this);
    // Defer until after the first frame so the camera surface attaches cleanly
    WidgetsBinding.instance.addPostFrameCallback((_) => _initConnectivity());
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateOfflineState(results);
      _connectSub = Connectivity().onConnectivityChanged.listen((results) {
        final wasOffline = _isOffline;
        _updateOfflineState(results);
        if (wasOffline && !_isOffline) _syncOfflineQueue();
      });
    } catch (_) {
      // connectivity unavailable — stay online-assumed, camera unaffected
    }
  }

  void _updateOfflineState(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (mounted) setState(() => _isOffline = offline);
  }

  Future<void> _syncOfflineQueue() async {
    final count = await _groupService.syncOfflineScans();
    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synced $count offline ride${count == 1 ? '' : 's'}'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_nfcMode) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isProcessing) _controller.start();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _controller.stop();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _connectSub?.cancel();
    _controller.dispose();
    if (_nfcWaiting) _nfcService.stopSession();
    super.dispose();
  }

  // ── Mode switch ────────────────────────────────────────────────────────────

  Future<void> _switchMode(bool nfc) async {
    if (_isProcessing) return;
    if (nfc == _nfcMode) return;

    _debounce?.cancel();
    if (nfc) {
      _controller.stop();
      setState(() { _nfcMode = true; _pendingValue = null; _isLocked = false; });
      // Start NFC session immediately so Android doesn't intercept the tag
      await _startNfcScan();
    } else {
      if (_nfcWaiting) {
        await _nfcService.stopSession();
        setState(() => _nfcWaiting = false);
      }
      _controller.start();
      setState(() { _nfcMode = false; _pendingValue = null; _isLocked = false; });
    }
  }

  // ── QR flow ────────────────────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _nfcMode) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    if (rawValue != _pendingValue) {
      _debounce?.cancel();
      setState(() {
        _pendingValue = rawValue;
        _isLocked = false;
      });
      _debounce = Timer(const Duration(milliseconds: 900), () {
        if (!mounted || _isProcessing) return;
        setState(() => _isLocked = true);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted || _isProcessing) return;
          _processQr(rawValue);
        });
      });
    }
  }

  Future<void> _processQr(String rawValue) async {
    setState(() {
      _isProcessing = true;
      _isLocked = false;
      _pendingValue = null;
    });
    _debounce?.cancel();
    _controller.stop();

    if (rawValue.startsWith('UB-')) {
      await _handleUniversityScan(rawValue);
    } else {
      await _handlePackageScan(rawValue);
    }
  }

  Future<void> _handleUniversityScan(String rawValue) async {
    final bookingCode = rawValue.split('|').first;
    try {
      final preview = await _uniService.previewScan(bookingCode);
      if (!mounted) return;
      setState(() => _isProcessing = false);
      context.pushReplacement('/scan/university-result', extra: preview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
      _controller.start();
    }
  }

  Future<void> _handlePackageScan(String rawValue) async {
    if (_isOffline) {
      final purchaseId = OfflineQrService.verify(rawValue);
      if (!mounted) return;
      setState(() => _isProcessing = false);
      if (purchaseId != null) {
        context.pushReplacement('/scan/offline-result', extra: purchaseId);
      } else {
        _showError('Invalid or expired QR code (offline)');
        _controller.start();
      }
      return;
    }

    final response = await _groupService.previewScan(rawValue);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (response.success && response.data != null) {
      context.pushReplacement('/scan/result', extra: response.data!);
    } else {
      _showError(response.error?.message ?? 'QR scan failed');
      _controller.start();
    }
  }

  // ── NFC flow ───────────────────────────────────────────────────────────────

  // Starts NFC reader mode and awaits its registration before returning.
  // This guarantees Android's dispatch is suppressed before any card arrives.
  Future<void> _startNfcScan() async {
    if (_isProcessing || _nfcWaiting) return;

    setState(() { _nfcWaiting = true; _isProcessing = false; });

    // await ensures enableReaderMode() is registered on the Android NfcAdapter
    // before this function returns — no more race with Android's system dispatch.
    await _nfcService.startListening(
      onTagRead: (uid) async {
        if (!mounted || _isProcessing) return;
        setState(() { _nfcWaiting = false; _isProcessing = true; });

        // Stop session while we look up the package — restart after if needed
        await _nfcService.stopSession();

        final response = await _nfcService.previewScan(uid);
        if (!mounted) return;
        setState(() => _isProcessing = false);

        if (response.success && response.data != null) {
          context.pushReplacement('/scan/result', extra: response.data!);
        } else {
          _showError(response.error?.message ?? 'Card not recognised');
          if (mounted && _nfcMode) _startNfcScan();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() { _nfcWaiting = false; _isProcessing = false; });
        _showError(error);
        // Brief pause then restart so the driver can try again
        if (mounted && _nfcMode) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted && _nfcMode) _startNfcScan();
          });
        }
      },
    );
  }

  void _cancelNfc() {
    _nfcService.stopSession();
    setState(() { _nfcWaiting = false; _isProcessing = false; });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.error_outline, color: AppColors.error),
          SizedBox(width: 8),
          Text('Scan Failed'),
        ]),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_nfcMode ? 'Scan — NFC Card' : 'Scan — QR Code'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildModeToggle(),
        ),
      ),
      body: _nfcMode ? _buildNfcView() : _buildQrView(),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _toggleTab(label: 'QR Code', icon: Icons.qr_code_scanner, selected: !_nfcMode, onTap: () => _switchMode(false)),
            _toggleTab(label: 'NFC Card', icon: Icons.credit_card, selected: _nfcMode, onTap: () => _switchMode(true)),
          ],
        ),
      ),
    );
  }

  Widget _toggleTab({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? Colors.white : Colors.white54),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  // ── QR View ────────────────────────────────────────────────────────────────

  Widget _buildQrView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error, child) => ColoredBox(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  const Text('Camera failed to start', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _controller.start(),
                    child: const Text('Tap to retry', style: TextStyle(color: AppColors.primaryLight)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Builder(builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final frameSize = screenWidth < 360 ? 220.0 : 260.0;
            final frameColor = _isLocked ? Colors.greenAccent : AppColors.primaryLight;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: frameSize,
              height: frameSize,
              decoration: BoxDecoration(
                border: Border.all(color: frameColor, width: _isLocked ? 4 : 3),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ),
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Column(children: [
            if (_isOffline)
              Container(
                margin: const EdgeInsets.only(bottom: 10, left: 32, right: 32),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('Offline — local QR verification', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            if (!_isProcessing)
              Text(
                _isLocked ? 'QR code detected…' : _pendingValue != null ? 'Hold steady…' : 'Point camera at the passenger\'s QR code',
                textAlign: TextAlign.center,
                style: TextStyle(color: _isLocked ? Colors.greenAccent : Colors.white70, fontSize: 14),
              ),
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppColors.primaryLight),
              const SizedBox(height: 8),
              const Text('Processing...', style: TextStyle(color: Colors.white70)),
            ],
          ]),
        ),
        ..._buildCorners(),
      ],
    );
  }

  // ── NFC View ───────────────────────────────────────────────────────────────

  Widget _buildNfcView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _nfcWaiting
                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                    : Colors.white12,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _nfcWaiting ? AppColors.primaryLight : Colors.white24,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.credit_card,
                size: 72,
                color: _nfcWaiting ? AppColors.primaryLight : Colors.white54,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _isProcessing
                  ? 'Looking up student…'
                  : _nfcWaiting
                      ? 'Hold card to back of phone'
                      : 'Ready — tap card to phone',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _nfcWaiting ? AppColors.primaryLight : Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            if (!_isProcessing && !_nfcWaiting)
              const Text(
                'For physical UGO NFC cards only.\nTo scan a QR code, use the QR Code tab.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            const SizedBox(height: 36),
            if (_isProcessing)
              const CircularProgressIndicator(color: AppColors.primaryLight)
            else if (_nfcWaiting)
              TextButton.icon(
                onPressed: _cancelNfc,
                icon: const Icon(Icons.close, color: Colors.white54),
                label: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              )
            else
              // Session stopped (e.g. after cancel) — let driver restart manually
              TextButton.icon(
                onPressed: _startNfcScan,
                icon: const Icon(Icons.refresh, color: Colors.white70),
                label: const Text('Tap to listen again', style: TextStyle(color: Colors.white70)),
              ),
          ],
        ),
      ),
    );
  }

  // ── Corner decorations (QR mode only) ─────────────────────────────────────

  List<Widget> _buildCorners() {
    const size = 30.0;
    const thick = 4.0;
    const color = AppColors.primaryLight;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final frameSize = screenWidth < 360 ? 220.0 : 260.0;
    final frameLeft = (screenWidth - frameSize) / 2 - 2;
    // subtract appBar height (56 default) + toggle bar (48)
    final frameTop = (screenHeight - frameSize) / 2 - 2 - 104;
    final frameRight = frameLeft + frameSize;
    final frameBottom = frameTop + frameSize;

    Widget corner({required double left, required double top, required bool isTop, required bool isLeft}) =>
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border(
                top: isTop ? const BorderSide(color: color, width: thick) : BorderSide.none,
                bottom: !isTop ? const BorderSide(color: color, width: thick) : BorderSide.none,
                left: isLeft ? const BorderSide(color: color, width: thick) : BorderSide.none,
                right: !isLeft ? const BorderSide(color: color, width: thick) : BorderSide.none,
              ),
            ),
          ),
        );

    return [
      corner(left: frameLeft, top: frameTop, isTop: true, isLeft: true),
      corner(left: frameRight - size, top: frameTop, isTop: true, isLeft: false),
      corner(left: frameLeft, top: frameBottom - size, isTop: false, isLeft: true),
      corner(left: frameRight - size, top: frameBottom - size, isTop: false, isLeft: false),
    ];
  }
}
