import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/URL_Detect/url_analyzer.dart';
import 'url_result_detail.dart';
import '../service/url_resolver.dart';

class Result extends StatefulWidget {
  const Result({super.key});

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  late String scannedData;
  String? resolvedUrl;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scannedData =
        ModalRoute.of(context)!.settings.arguments as String? ?? "No data";
    _resolveUrl();
  }

  Future<void> _resolveUrl() async {
    final resolved =
        await UrlResolverService.resolveShortenedUrl(scannedData) ??
            scannedData;
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
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const Center(child: LoadingIndicator(textColor: Colors.white));
      },
    );

    try {
      final result =
          await UrlAnalyzerService.analyzeUrl(resolvedUrl ?? scannedData);
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
      appBar: AppBar(
        title: Text("Scan Result",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        constraints: const BoxConstraints(minHeight: double.infinity),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? const LoadingIndicator()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildUrlCard(
                        title: "Original URL",
                        content: scannedData,
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 20),
                      _buildUrlCard(
                        title: "Resolved URL",
                        content: resolvedUrl ?? "Resolving...",
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 30),
                      if (isValidUrl(resolvedUrl ?? scannedData))
                        _buildActionButton(
                          text: "Analyze & Open Link",
                          icon: Icons.security,
                          onPressed: () => _analyzeAndShowResult(context),
                          color: const Color(0xFF2196F3),
                        ),
                      const SizedBox(height: 15),
                      _buildActionButton(
                        text: "Scan Again",
                        icon: Icons.replay,
                        onPressed: () => Navigator.pop(context),
                        color: const Color(0xFF757575),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildUrlCard(
      {required String title, required String content, required Color color}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Divider(),
            SelectableText(
              content,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required String text,
      required IconData icon,
      required Function onPressed,
      required Color color}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final dynamic textColor;
  const LoadingIndicator({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/loading.json',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing URL...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: textColor ?? Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
