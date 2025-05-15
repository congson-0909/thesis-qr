import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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

    final riskColor = {
      'safe': Colors.green,
      'suspicious': Colors.orange,
      'dangerous': Colors.red,
      'unknown': Colors.grey,
      'error': Colors.black
    }[finalRisk] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text("URL Analysis Result"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: riskColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // URL & Actions
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Analyzed URL",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  SelectableText(
                    url,
                    style: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Open"),
                        onPressed: () => _launchUrl(url),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy"),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("URL copied!")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Risk & Score
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  finalRisk.toUpperCase(),
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: riskColor,
                  radius: 14,
                  child: Text(
                    finalScore.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Safe Browsing
          _buildSectionCard(
            title: "🛡️ Google Safe Browsing",
            icon: Icons.shield,
            reasons: safeBrowsing['reasons'],
          ),

          const SizedBox(height: 12),

          // Structure Analysis
          _buildSectionCard(
            title: "🔍 Structure Analysis",
            icon: Icons.code,
            reasons: structure['reasons'],
          ),

          const SizedBox(height: 12),

          // WHOIS Info
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              leading: const Icon(Icons.public),
              title: const Text("🌐 WHOIS Analysis",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ..._buildList(whois['reasons']),
                const Divider(),
                _buildKeyValue("Domain", whois['domain']),
                _buildKeyValue("Country", whois['country']),
                _buildKeyValue("Created", whois['creationDate']),
                _buildKeyValue("Expires", whois['expiresDate']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionCard({
    required String title,
    required IconData icon,
    dynamic reasons,
  }) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _buildList(reasons),
      ),
    );
  }

  static List<Widget> _buildList(dynamic reasons) {
    if (reasons is List && reasons.isNotEmpty) {
      return reasons
          .map<Widget>((r) => ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(r.toString()),
              ))
          .toList();
    }

    return const [
      ListTile(
        leading: Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text("No issues detected."),
      )
    ];
  }

  static Widget _buildKeyValue(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label:",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 8),
          Text(value?.toString() ?? 'Unknown',
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  static Future<void> _launchUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
