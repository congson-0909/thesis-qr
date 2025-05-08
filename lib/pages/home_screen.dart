import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Spacer(),
            // Image.asset('assets/ic_home.png', height: 200),
            const SizedBox(height: 40),
            _buildScanButton(
              context: context,
              icon: Icons.camera_alt,
              label: 'Scan with Camera',
              route: '/scan',
            ),
            const SizedBox(height: 20),
            _buildScanButton(
              context: context,
              icon: Icons.photo_library,
              label: 'Scan from Gallery',
              route: '/scan_gallery',
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
    );
  }
}
