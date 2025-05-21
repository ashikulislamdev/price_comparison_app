import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final File? imageFile;

  const ImageDisplay({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return imageFile == null
        ? const Text("No image selected")
        : Image.file(imageFile!, height: 200);
  }
}
