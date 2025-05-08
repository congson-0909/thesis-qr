import 'package:flutter/material.dart';
import 'package:thesis_qr/pages/home_screen.dart';
import 'package:thesis_qr/pages/splash.dart';
import 'pages/scan_code_page.dart';
import 'pages/result.dart';
import 'pages/scan_code_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/scan': (context) => const ScanCodePage(),
        '/scan_gallery': (context) => const ScanCodeGalleryPage(),
        '/result': (context) => Result(),
      },
    );
  }
}
