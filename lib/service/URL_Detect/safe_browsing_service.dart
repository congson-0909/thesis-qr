import 'dart:convert';
import 'package:http/http.dart' as http;

class SafeBrowsingService {
  static const String _apiKey = "AIzaSyBd_EX5XKA-5PqIUF0do3qW3K-ktL8PJJc";
  static const String _apiUrl = "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$_apiKey";

  static Future<String> resolveRedirect(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (response.isRedirect ||
          response.statusCode == 302 ||
          response.statusCode == 301) {
        final redirectedUrl = response.headers['location'];
        if (redirectedUrl != null && redirectedUrl.isNotEmpty) {
          return redirectedUrl;
        }
      }
    } catch (e) {
      print("Error resolving redirect: $e");
    }

    return url;
  }

  static Future<bool> isMalicious(String url) async {

    final Map<String, dynamic> requestBody = {
      "client": {
        "clientId": "your_app",
        "clientVersion": "1.0"
      },
      "threatInfo": {
        "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING"],
        "platformTypes": ["ANY_PLATFORM"],
        "threatEntryTypes": ["URL"],
        "threatEntries": [
          {"url": url}
        ]
      }
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("SafeBrowsing response: $data");
        return data.containsKey("matches");
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Something went wrong: $e");
    }

    return false;
  }
}