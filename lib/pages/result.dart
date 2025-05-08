import 'package:flutter/material.dart';
import '../service/URL_Detect/url_analyzer.dart';
import 'url_result_detail.dart';
import '../service/url_resolver.dart';

class Result extends StatefulWidget {
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  late String scannedData;
  String? resolvedUrl; // URL sau khi resolve
  bool isLoading = true; // Đang chờ resolve

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scannedData = ModalRoute.of(context)!.settings.arguments as String? ?? "No data";

    _resolveUrl(); // Gọi luôn khi màn hình mở
  }

  Future<void> _resolveUrl() async {
    final resolved = await UrlResolverService.resolveShortenedUrl(scannedData) ?? scannedData;
    setState(() {
      resolvedUrl = resolved;
      isLoading = false;
    });
  }

  bool isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  void _analyzeAndShowResult(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final result = await UrlAnalyzerService.analyzeUrl(resolvedUrl ?? scannedData);

      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UrlResultDetail(result: result),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Result")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Scanned QR Code (Original):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SelectableText(
                scannedData,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Resolved URL (Final Destination):",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SelectableText(
                resolvedUrl ?? "Resolving...",
                style: const TextStyle(fontSize: 16, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (isValidUrl(resolvedUrl ?? scannedData))
                ElevatedButton(
                  onPressed: () => _analyzeAndShowResult(context),
                  child: const Text("Analyze & Open Link"),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Scan Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
