import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../config/theme.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final _service = GroupService();
  final _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    final response = await _service.scanQr(rawValue);

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

          // Overlay frame
          Center(
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final frameSize = screenWidth < 360 ? 220.0 : 260.0;
                return Container(
                  width: frameSize,
                  height: frameSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryLight, width: 3),
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
                const Text('Point camera at the passenger\'s QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
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
    final color = AppColors.primaryLight;

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
                top: isTop ? BorderSide(color: color, width: thick) : BorderSide.none,
                bottom: !isTop ? BorderSide(color: color, width: thick) : BorderSide.none,
                left: isLeft ? BorderSide(color: color, width: thick) : BorderSide.none,
                right: !isLeft ? BorderSide(color: color, width: thick) : BorderSide.none,
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
