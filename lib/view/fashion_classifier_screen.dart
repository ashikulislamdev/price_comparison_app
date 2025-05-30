import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/utils/image_utils.dart';
import '../core/amazon_search_service.dart';
import '../widgets/image_display.dart';

class FashionClassifierScreen extends StatefulWidget {
  const FashionClassifierScreen({super.key});

  @override
  State<FashionClassifierScreen> createState() => _FashionClassifierScreenState();
}

class _FashionClassifierScreenState extends State<FashionClassifierScreen> {
  File? _image;
  String? _prediction;
  bool _isLoading = false;
  List<Map<String, dynamic>> _amazonResults = [];
  bool _isSearching = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _prediction = null;
      });
      _sendImageToAPI(File(picked.path));
    }
  }

  Future<void> _sendImageToAPI(File imageFile) async {
    setState(() => _isLoading = true);
    try {
      final prediction = await ImageUtils.sendToPredictionAPI(imageFile);
      setState(() => _prediction = prediction);
      if (prediction.isNotEmpty) {
        _searchAmazon(prediction);
      }
    } catch (e) {
      setState(() => _prediction = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchAmazon(String query) async {
    setState(() {
      _isSearching = true;
      _amazonResults = [];
    });
    try {
      final results = await AmazonSearchService.searchProducts(query);
      setState(() => _amazonResults = results.take(10).toList());
    } catch (e) {
      // Optionally handle error
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fashion Classifier')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageDisplay(imageFile: _image),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _pickImage, child: const Text('Upload Image')),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_prediction != null) Text('Prediction: $_prediction', style: const TextStyle(fontSize: 16)),
            if (_isSearching) const CircularProgressIndicator(),
            if (_amazonResults.isNotEmpty)
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: _amazonResults.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final item = _amazonResults[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: item['image'] != null ? Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover) : null,
                        title: Text(item['title'] ?? 'No title', maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Amazon"),
                            Text(item['price']?['raw'] ?? 'No price'),
                          ],
                        ),
                        onTap: item['link'] != null ? () {
                          // Optionally, open the product link
                        } : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
