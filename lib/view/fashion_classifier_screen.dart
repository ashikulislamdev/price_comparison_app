import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:price_comparison_app/core/utils/image_utils.dart';
import 'package:price_comparison_app/model/interpreter_service.dart';

class ClassifierScreen extends StatefulWidget {
  const ClassifierScreen({Key? key}) : super(key: key);

  @override
  State<ClassifierScreen> createState() => _ClassifierScreenState();
}

class _ClassifierScreenState extends State<ClassifierScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _predictionLabel;
  bool _isLoading = false;

  late InterpreterService _interpreterService;
  List<String> labels = []; 

  @override
  void initState() {
    super.initState();
    _loadInterpreter();
  }

  Future<void> _loadInterpreter() async {
    _interpreterService = InterpreterService();
    await _interpreterService.loadModel();

    labels = await _interpreterService.loadLabels();

    setState(() {});
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });

      await _classifyImage(image);
    }
  }

  Future<void> _classifyImage(XFile imageFile) async {
    setState(() {
      _isLoading = true;
    });

    final file = File(imageFile.path);

    final inputShape = _interpreterService.getInputShape();
    final height = inputShape[1];
    final width = inputShape[2];

    final inputBuffer = await ImageUtils.preprocess(
      file,
      height,
      width,
    );

    final predictions = await _interpreterService.predict(inputBuffer, labels);

    setState(() {
      _predictionLabel = predictions.isNotEmpty ? predictions.first.label : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classifier'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_selectedImage != null)
                Image.file(
                  File(_selectedImage!.path),
                  height: 250,
                )
              else
                const Placeholder(
                  fallbackHeight: 250,
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      _predictionLabel != null
                          ? 'Prediction: $_predictionLabel'
                          : 'No prediction yet.',
                      style: const TextStyle(fontSize: 20),
                    ),
              const Spacer(),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick an Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
