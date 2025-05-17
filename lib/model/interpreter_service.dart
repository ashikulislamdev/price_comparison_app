// In InterpreterService.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:price_comparison_app/model/result_info.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class InterpreterService {
  late Interpreter _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/mobilenetv2_fashion_mnist.tflite');
      print('Interpreter loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
      rethrow; // Rethrow to be caught by the UI
    }
  }

  Future<List<String>> loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/labels/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
      print('Labels loaded successfully: $_labels');
      return _labels!;
    } catch (e) {
      print('Error loading labels: $e');
      rethrow; 
    }
  }

  List<int> getInputShape() {
    // return something like [1, 96, 96, 3]
    return _interpreter.getInputTensor(0).shape;
  }

  Future<List<ResultInfo>> predict(Uint8List inputImageBytes, List<String> labels) async {
    // inputImageBytes is the Uint8List from ImageUtils.preprocess,
    // which is the byte representation of a Float32List.

    final inputTensor = _interpreter.getInputTensor(0);
    final outputTensor = _interpreter.getOutputTensor(0);

    // Expected shape, e.g., [1, 96, 96, 3]
    final inputShape = inputTensor.shape;
    // Expected shape, e.g., [1, 10]
    final outputShape = outputTensor.shape;

    // Convert the Uint8List (byte buffer of floats) back to Float32List
    Float32List float32Input = inputImageBytes.buffer.asFloat32List();

    // Reshape the flat Float32List into the model's expected input shape.
    // For [1, 96, 96, 3], we need a List<List<List<List<double>>>>.
    // The `run` method is flexible; often a List containing the reshaped single image works.
    if (inputShape.length != 4 || inputShape[0] != 1) {
      throw Exception(
          "This reshaping logic assumes input shape [1, H, W, C]. Actual: $inputShape");
    }
    final int height = inputShape[1];
    final int width = inputShape[2];
    final int channels = inputShape[3];

    // Create the 3D image structure [height, width, channels]
    List<List<List<double>>> reshapedImage = List.generate(
      height,
      (h) => List.generate(
        width,
        (w) => List.generate(
          channels,
          (c) {
            // Calculate index in the flat float32Input list
            // Assumes HWC order from ImageUtils.preprocess
            int index = (h * width * channels) + (w * channels) + c;
            return float32Input[index];
          },
        ),
      ),
    );

    // The `run` method typically expects a List of inputs, even if batch size is 1.
    // So, wrap the reshapedImage in another list: [[[[...]]]]
    var finalInput = [reshapedImage]; // This is now effectively [1, H, W, C]

    // Prepare output buffer according to the model's output shape
    // For [1, 10], this will be List<List<double>>
    var outputBuffer = List.generate(
      outputShape[0], // batch_size (e.g., 1)
      (_) => List<double>.filled(outputShape[1], 0.0), // num_classes (e.g., 10)
    );

    // Run inference
    try {
      _interpreter.run(finalInput, outputBuffer);
    } catch (e) {
      print("Error during interpreter.run: $e");
      // This might be where the "Bad state: failed precondition" is re-thrown
      // if allocateTensors was not called or if preparation failed internally.
      // Some versions of the plugin might require allocateTensors to be called explicitly.
      // Let's try adding it here if it wasn't called after loading the model.
      try {
        _interpreter.allocateTensors(); // Attempt to allocate if not done already
        _interpreter.run(finalInput, outputBuffer);
      } catch (e2) {
        print("Error during interpreter.run (after trying allocateTensors): $e2");
        return []; // Return empty or throw
      }
    }

    // Process the output (outputBuffer is now List<List<double>>)
    // We take the first (and only, for batch size 1) list of probabilities
    final List<double> probabilities = outputBuffer[0];

    final results = List<ResultInfo>.generate(
      probabilities.length,
      (index) => ResultInfo(
        confidence: probabilities[index],
        label: labels.length > index ? labels[index] : 'Unknown', // Safety check
      ),
    );

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }
}