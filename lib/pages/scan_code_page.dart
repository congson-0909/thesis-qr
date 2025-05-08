import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'result.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final MobileScannerController cameraController = MobileScannerController();
  double zoomLevel = 1.0;
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      _isProcessing = true;
      await cameraController.stop(); // Dừng camera để không quét tiếp

      final String scannedData = barcodes.first.rawValue ?? "No data";

      // Chuyển sang màn hình kết quả
      await Navigator.pushNamed(
        context,
        "/result",
        arguments: scannedData,
      );

      // Sau khi quay lại, resume camera
      _isProcessing = false;
      await cameraController.start();
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          CustomPaint(
            painter: BarcodeOverlayPainter(),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Slider(
              value: zoomLevel,
              min: 1.0,
              max: 10.0,
              onChanged: (value) {
                setState(() {
                  zoomLevel = value;
                });
                cameraController.setZoomScale(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BarcodeOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.6,
      height: size.height * 0.3,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}