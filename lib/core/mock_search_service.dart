import 'dart:convert';
import 'package:http/http.dart' as http;

class MockSearchService {
  static const String _baseUrl = 'http://192.168.52.92:8000/products';

  // enable/disable stores
  static final Map<String, bool> enabledStores = {
    'walmart': true,
    'jd': false, // JD API not ready yet
    'ebay': true,
  };

  static Future<List<Map<String, dynamic>>> searchMockStores(String className) async {
    final List<Map<String, dynamic>> allProducts = [];
    for (final entry in enabledStores.entries) {
      if (!entry.value) continue;
      final store = entry.key;
      try {
        final uri = Uri.parse(_baseUrl).replace(queryParameters: {
          'store': store,
          'class_name': className,
        });
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          // print("Response from $store: ${response.body}");
          final data = json.decode(response.body);
          if (data is Map && data.containsKey('error')) {
            // Store not found or error
            continue;
          }
          final products = data['products'] as List?;
          if (products != null) {
            allProducts.addAll(products.map((item) => {
              'title': item['title'],
              'price': _parsePrice(item['price']),
              'raw_price': item['price'],
              'image': item['image'],
              'store': item['store'] ?? store,
              'url': item['url'],
            }));
          }
        }
      } catch (e) {
        // 
      }
    }
    // Sort by price 
    allProducts.sort((a, b) {
      final priceA = (a['price'] is num) ? (a['price'] as num).toDouble() : 999999.0;
      final priceB = (b['price'] is num) ? (b['price'] as num).toDouble() : 999999.0;
      return priceA.compareTo(priceB);
    });
    return allProducts;
  }

  static double _parsePrice(String? priceString) {
    if (priceString == null) return 999999.0;
    final clean = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 999999.0;
  }
}
