import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:price_comparison_app/widgets/image_display_widget.dart';
import '../core/mock_search_service.dart';
import '../core/utils/image_utils.dart';
import '../widgets/prediction_chip.dart';
import '../widgets/product_card.dart';

class MockApiClassifierScreen extends StatefulWidget {
  const MockApiClassifierScreen({super.key});

  @override
  State<MockApiClassifierScreen> createState() => _MockApiClassifierScreenState();
}

class _MockApiClassifierScreenState extends State<MockApiClassifierScreen> {
  File? _image;
  String? _prediction;
  bool _isLoading = false;
  List<Map<String, dynamic>> _mockResults = [];
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
        await _searchMockStores(prediction);
      }
    } catch (e) {
      setState(() => _prediction = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchMockStores(String className) async {
    setState(() {
      _isSearching = true;
      _mockResults = [];
    });
    try {
      final results = await MockSearchService.searchMockStores(className);
      setState(() => _mockResults = results.take(15).toList());
    } catch (e) {
      print("Search failed: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // For consistent styling

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Item Finder-Mock API'),
        elevation: 1.0, // Subtle shadow
      ),
      body: SingleChildScrollView( // to scroll if it overflows
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, 
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              ImageDisplayWidget(imageFile: _image, height: 280),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload_outlined),
                onPressed: _pickImage,
                label: const Text('Upload Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Prediction
              if (_isLoading) // image classification
                const Center(child: CircularProgressIndicator())
              else if (_prediction != null && _prediction!.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Identified Item:',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    PredictionChip(
                      prediction: _prediction!,
                      textTheme: theme.textTheme,
                      colorScheme: theme.colorScheme,
                    ),
                  ],
                )
              else if (_image != null && !_isLoading) // Image selected, but error
                Center(child: Text("Ready to classify or classification failed.", style: TextStyle(color: Colors.grey[600]))),
              
              const SizedBox(height: 24),
              Divider(thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 16),

              // Search Results 
              if (_isSearching)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text("Searching for products..."),
                    ],
                  ),
                )
              else if (_mockResults.isNotEmpty)
                Builder( // Using Builder here is fine to get a context that knows about DefaultTabController
                  builder: (context) {
                    final uniqueStores = _mockResults.map((e) => e['store']?.toString() ?? 'Unknown').toSet().toList();
                    uniqueStores.sort(); // Optional: sort store names
                    
                    final allTabName = 'All (${_mockResults.length})';
                    final tabNames = [allTabName, ...uniqueStores];

                    return DefaultTabController(
                      length: tabNames.length,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding( // Title for the whole search section
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Search Results:",
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          TabBar(
                            isScrollable: true,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: theme.colorScheme.primary,
                            tabs: tabNames.map((name) => Tab(text: name.toUpperCase())).toList(),
                          ),
                          SizedBox(
                            height: 550,
                            child: TabBarView(
                              children: tabNames.map((tabName) {
                                List<Map<String, dynamic>> itemsToShow;
                                if (tabName == allTabName) {
                                  itemsToShow = _mockResults;
                                } else {
                                  itemsToShow = _mockResults.where((e) => (e['store']?.toString() ?? 'Unknown') == tabName).toList();
                                }

                                if (itemsToShow.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No products found for '${_prediction ?? 'this item'}'" + (tabName == allTabName ? "." : " in ${tabName.toUpperCase()}."),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                                    ),
                                  );
                                }

                                return ListView.builder( // Changed from ListView.separated to ListView.builder for simplicity
                                  itemCount: itemsToShow.length,
                                  itemBuilder: (context, index) {
                                    final item = itemsToShow[index]; // Handle null items
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: ProductCard(
                                        item: item,
                                        textTheme: theme.textTheme,
                                        colorScheme: theme.colorScheme,
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else if (_prediction != null && _prediction!.isNotEmpty && !_isSearching) // Prediction made, no results found after search
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey[500]),
                        const SizedBox(height: 8),
                        Text(
                          "No products found for '$_prediction'.",
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              // Optionally, a SizedBox at the bottom for some padding if content is short
              const SizedBox(height: 20), 
            ],
          ),
        ),
      ),
    );
  }
}
