import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplayWidget extends StatelessWidget {
  final File? imageFile;
  final double height;

  const ImageDisplayWidget({
    super.key,
    required this.imageFile,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Ensures the child (Image) respects the border radius
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: imageFile != null
            ? Image.file(
                File(imageFile!.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text("Could not load image", textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera_back_outlined, size: 70, color: Colors.grey[500]),
                    const SizedBox(height: 16),
                    Text(
                      'Upload an image to get started',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}