import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlResultDetail extends StatelessWidget {
  final Map<String, dynamic> result;

  const UrlResultDetail({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final String url = result['url'] ?? 'N/A';
    final String finalRisk = result['finalRisk'] ?? 'unknown';
    final int finalScore = result['finalScore'] ?? 0;

    final structure = result['structure'] ?? {};
    final whois = result['whois'] ?? {};
    final safeBrowsing = result['safeBrowsing'] ?? {};
    Color riskColor = {
      'safe': Colors.green,
      'suspicious': Colors.orange,
      'dangerous': Colors.red,
      'unknown': Colors.grey,
      'error': Colors.black
    }[finalRisk] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(title: const Text("URL Analysis Result")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text("Analyzed URL:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(url, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 20),
            Text("Risk Level: $finalRisk",
                style: TextStyle(fontSize: 18, color: riskColor)),
            Text("Final Score: $finalScore", style: const TextStyle(fontSize: 16)),
            const Divider(),
            const Text("🛡️ Google Safe Browsing:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ..._buildList(safeBrowsing['reasons']),
            const Text("🔍 Structure Analysis:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ..._buildList(structure['reasons']),
            const Divider(),
            const Text("🌐 WHOIS Analysis:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ..._buildList(whois['reasons']),
            const SizedBox(height: 10),
            Text('📌 Domain: ${whois['domain'] ?? 'Unknown'}'),
            Text('🌍 Country: ${whois['country'] ?? 'Unknown'}'),
            Text('📅 Created: ${whois['creationDate'] ?? 'Unknown'}'),
            Text('📅 Expires: ${whois['expiresDate'] ?? 'Unknown'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text("Open URL"),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList(dynamic reasons) {
    if (reasons is List && reasons.isNotEmpty) {
      return reasons
          .map<Widget>((reason) => ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(reason.toString()),
      ))
          .toList();
    }

    // Nếu rỗng → hiện thông báo mặc định
    return [
      const ListTile(
        leading: Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text("No issues detected."),
      )
    ];
  }
}