import 'dart:convert';
import 'package:http/http.dart' as http;
import 'safe_browsing_service.dart';

class UrlAnalyzerService {
  static Future<Map<String, dynamic>> analyzeUrl(String url) async {
    try {
      // Gọi Google Safe Browsing
      final isMalicious = await SafeBrowsingService.isMalicious(url);
      final safeBrowsingResult = {
        'risk': isMalicious ? 'dangerous' : 'safe',
        'score': isMalicious ? 10 : 0,
        'reasons': isMalicious
            ? ['⚠️ Detected as MALICIOUS by Google Safe Browsing']
            : ['✅ Not flagged by Google Safe Browsing'],
      };

      // Gọi API server để phân tích cấu trúc + WHOIS
      final response = await http.post(
        Uri.parse('https://servermobileapp-production.up.railway.app/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final serverResult = jsonDecode(response.body);
        final structure = serverResult['structure'] ?? {};
        final whois = serverResult['whois'] ?? {};

        // Tính tổng điểm từ 3 phần
        final int totalScore = (safeBrowsingResult['score'] as int? ?? 0) +
            (structure['score'] as int? ?? 0) +
            (whois['score'] as int? ?? 0);
        // Gộp Risk Level
        final risks = [
          safeBrowsingResult['risk'],
          structure['risk'],
          whois['risk'],
        ];

        String finalRisk = _calculateFinalRisk(risks.cast<String>());

        return {
          'url': url,
          'finalScore': totalScore,
          'finalRisk': finalRisk,
          'safeBrowsing': safeBrowsingResult,
          'structure': structure,
          'whois': {
            ...whois,
            'domain': whois['domain'] ?? 'Unknown',
            'country': whois['country'] ?? 'Unknown',
            'creationDate': whois['creationDate'] ?? 'Unknown',
            'expiresDate': whois['expiresDate'] ?? 'Unknown',
          },
        };
      } else {
        throw Exception('Failed to analyze URL');
      }
    } catch (e) {
      return {
        'url': url,
        'finalRisk': 'error',
        'error': e.toString(),
      };
    }
  }

  static String _calculateFinalRisk(List<String> risks) {
    if (risks.contains('dangerous')) return 'dangerous';
    if (risks.contains('suspicious')) return 'suspicious';
    if (risks.contains('safe')) return 'safe';
    return 'unknown';
  }
}
