import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'result.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // keep the same 1–10 range as before
  static const double _minZoom = 1.0;
  static const double _maxZoom = 10.0;

  double zoomLevel = _minZoom;
  bool isTorchOn = false;
  bool _isProcessing = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() => _isProcessing = true);
    await cameraController.stop();

    final data = barcodes.first.rawValue ?? 'No data';
    if (!mounted) return;

    await Navigator.pushNamed(context, '/result', arguments: data);

    setState(() => _isProcessing = false);
    await cameraController.start();
  }

  void _toggleTorch() {
    cameraController.toggleTorch();
    setState(() => isTorchOn = !isTorchOn);
  }

  void _switchCamera() {
    cameraController.switchCamera();
    // after switching, re‑apply zoom
    cameraController.setZoomScale(zoomLevel);
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
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          Center(
            child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: BarcodeOverlayPainter(
                borderColor: Colors.blueAccent.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: zoomLevel.clamp(_minZoom, _maxZoom),
                  min: _minZoom,
                  max: _maxZoom,
                  divisions: (_maxZoom - _minZoom).toInt(),
                  label: '${zoomLevel.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    setState(() => zoomLevel = value);
                    // guard against out‑of‑range
                    final z = value.clamp(_minZoom, _maxZoom);
                    cameraController.setZoomScale(z);
                  },
                ),
                Text(
                  'Zoom: ${zoomLevel.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class BarcodeOverlayPainter extends CustomPainter {
  final Color borderColor;
  BarcodeOverlayPainter({this.borderColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.6,
      height: size.width * 0.6,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
