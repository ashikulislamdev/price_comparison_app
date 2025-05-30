import 'dart:convert';
import 'package:http/http.dart' as http;

class AmazonSearchService {
  static const String _apiKey = '06ED87269C5A47B292440F35DD02DE4A'; // Replace with your real API key
  static const String _baseUrl = 'https://api.rainforestapi.com/request';

  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'api_key': _apiKey,
      'type': 'search',
      'amazon_domain': 'amazon.com',
      'search_term': query,
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['search_results'] as List?;
      if (results != null) {
        return results.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }
}