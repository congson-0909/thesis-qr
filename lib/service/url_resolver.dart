import 'dart:convert';
import 'package:http/http.dart' as http;

class UrlResolverService {
  static const String apiUrl = 'https://urlresolver-production.up.railway.app/resolve';

  static Future<String?> resolveShortenedUrl(String inputUrl) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': inputUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['resolved'] as String?;
      } else {
        print('API returned error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error resolving URL: $e');
      return null;
    }
  }
}
