import 'package:flutter/material.dart';
import 'package:thesis_qr/pages/loading.dart';
import 'pages/scan_code_page.dart';
import 'pages/result.dart';
import 'pages/scan_code_gallery.dart';
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "/loading": (context) => const Loading(),
        "/scan": (context) => const ScanCodePage(),
        "/result": (context) => Result(),
        "/scan_gallery": (context) => const ScanCodeGalleryPage(),
      },
      initialRoute: "/loading",
    );
  }
}
