import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../config/theme.dart';
import '../../models/group_model.dart';
import '../../models/university_scan_model.dart';
import '../../services/group_service.dart';
import '../../services/university_scan_service.dart';
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
  late final MobileScannerController _controller;
  bool _isProcessing = false;

  // Debounce: hold the same QR value for 900ms before acting
  Timer? _debounce;
  String? _pendingValue;
  bool _isLocked = false; // shows the "locked on" indicator

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(autoStart: true);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isProcessing) _controller.start();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _controller.stop();
      case AppLifecycleState.inactive:
        break; // brief transition state — don't touch the camera
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    // If a different code appears, reset the timer
    if (rawValue != _pendingValue) {
      _debounce?.cancel();
      setState(() {
        _pendingValue = rawValue;
        _isLocked = false;
      });

      _debounce = Timer(const Duration(milliseconds: 900), () {
        if (!mounted || _isProcessing) return;
        setState(() => _isLocked = true);

        // Brief visual pause so the driver sees the "locked" state
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted || _isProcessing) return;
          _process(rawValue);
        });
      });
    }
  }

  Future<void> _process(String rawValue) async {
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
    // QR data is "UB-XXXXXXXX|SEAT:...|DATE:...|TIME:..." — extract just the booking code
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Passenger QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay frame — green when locked on a code, blue otherwise
          Center(
            child: Builder(
              builder: (context) {
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
              },
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!_isProcessing)
                  Text(
                    _isLocked
                        ? 'QR code detected…'
                        : _pendingValue != null
                            ? 'Hold steady…'
                            : 'Point camera at the passenger\'s QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isLocked ? Colors.greenAccent : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                if (_isProcessing) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: AppColors.primaryLight),
                  const SizedBox(height: 8),
                  const Text('Processing...', style: TextStyle(color: Colors.white70)),
                ],
              ],
            ),
          ),

          // Corner decorations
          ..._buildCorners(),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 30.0;
    const thick = 4.0;
    const color = AppColors.primaryLight;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final frameSize = screenWidth < 360 ? 220.0 : 260.0;
    final frameLeft = (screenWidth - frameSize) / 2 - 2;
    final frameTop = (screenHeight - frameSize) / 2 - 2;
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
