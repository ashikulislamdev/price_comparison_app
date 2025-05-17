import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

class ImageUtils {
  static const int imgSize = 96; // or your model's input size (adjust if needed)

  static Uint8List _imageToByteBuffer(img.Image image, int height, int width) {
    final resizedImage = img.copyResize(image, width: width, height: height);
    final buffer = Float32List(height * width * 3);

    int index = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = resizedImage.getPixel(x, y);

        buffer[index++] = pixel.r / 255.0;
        buffer[index++] = pixel.g / 255.0;
        buffer[index++] = pixel.b / 255.0;
      }
    }
    return buffer.buffer.asUint8List();
  }

  static Future<Uint8List> preprocess(File imageFile, int height, int width) async {
    final imageBytes = await imageFile.readAsBytes();
    final decodeImage = img.decodeImage(imageBytes);
    if (decodeImage == null) {
      throw Exception("Failed to decode image");
    }

    return _imageToByteBuffer(decodeImage, height, width);
  }
}


