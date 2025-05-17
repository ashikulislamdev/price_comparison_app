import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final File? imageFile;

  const ImageDisplay({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return const Placeholder(fallbackHeight: 200);
    } else {
      return Image.file(imageFile!, height: 200);
    }
  }
}
