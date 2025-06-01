import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const ProductCard({required this.item, required this.textTheme, required this.colorScheme, super.key});

  @override
  Widget build(BuildContext context) {
    final priceString = item['raw_price']?.toString() ?? item['price']?.toString() ?? 'N/A';
    final storeName = item['store']?.toString().toUpperCase() ?? 'Store';
    
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        constraints: BoxConstraints(minHeight: 100), // Ensure minimum height
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image'] != null)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: InteractiveViewer(
                        child: Image.network(
                          item['image'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(width: 200, height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 50)),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    item['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 30)),
                  ),
                ),
              )
            else
              Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 30)),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: item['url'] != null
                  ? () {
                      final url = item['url'];
                      if (url != null) {
                        launchUrl(
                          url is String ? Uri.parse(url) : url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['title'] ?? 'No title',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceString,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Chip(
                            label: Text(storeName, style: TextStyle(fontSize: 10, color: colorScheme.onSecondaryContainer)),
                            backgroundColor: colorScheme.secondaryContainer.withOpacity(0.7),
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (item['url'] != null)
                          Icon(Icons.open_in_new, size: 18, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}