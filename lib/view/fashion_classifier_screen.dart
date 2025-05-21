import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/utils/image_utils.dart';
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
    } catch (e) {
      setState(() => _prediction = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
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
          ],
        ),
      ),
    );
  }
}
