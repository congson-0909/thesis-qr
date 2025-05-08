import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ScanCodeGalleryPage extends StatefulWidget {
  const ScanCodeGalleryPage({super.key});

  @override
  _ScanCodeGalleryPageState createState() => _ScanCodeGalleryPageState();
}

class _ScanCodeGalleryPageState extends State<ScanCodeGalleryPage> {
  final MobileScannerController galleryController = MobileScannerController();

  void _processScanResult(String scannedData) {
    Navigator.pushNamed(
      context,
      '/result',
      arguments: scannedData,
    );
  }

  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final barcodeCapture = await galleryController.analyzeImage(image.path);

      if(barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
        _processScanResult(barcodeCapture.barcodes.first.rawValue ?? "No data");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR Code detected!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR from Gallery')),
      body: Center(
        child: ElevatedButton(
          onPressed: _scanFromGallery,
          child: const Text("Select Image from Gallery"),
        ),
      ),
    );
  }
}
