import 'mock_search_service.dart';
import 'amazon_search_service.dart';

class MultiStoreService {
  static Future<List<Map<String, dynamic>>> searchAllStores(String query) async {
    List<Map<String, dynamic>> allResults = [];

    // 1. Amazon
    try {
      final amazonResults = await AmazonSearchService.searchProducts(query);
      allResults.addAll(amazonResults.map((item) => {
        'title': item['title'],
        'price': item['price']?['value'] ?? 999999.0,
        'raw_price': item['price']?['raw'] ?? 'No price',
        'image': item['image'],
        'store': 'Amazon',
        'url': item['link'],
      }));
    } catch (e) {
      print("Amazon API failed: $e");
    }

    // 2. Mock stores
    try {
      final mockResults = await MockSearchService.searchMockStores(query);
      allResults.addAll(mockResults);
    } catch (e) {
      print("Mock API failed: $e");
    }

    // Sort by price ascending
    allResults.sort((a, b) {
      final priceA = (a['price'] is num) ? (a['price'] as num).toDouble() : 999999.0;
      final priceB = (b['price'] is num) ? (b['price'] as num).toDouble() : 999999.0;
      return priceA.compareTo(priceB);
    });

    return allResults;
  }
}
