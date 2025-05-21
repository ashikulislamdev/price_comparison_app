import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUtils {
  static Future<String> sendToPredictionAPI(File imageFile) async {
    final uri = Uri.parse("http://192.168.1.100:8000/predict"); // pc ip to test on phone
    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        // print("Response body: $body");
        final data = json.decode(body);
        // return predicted class and confidence
        return "${data['predicted_class']} (${data['confidence']}%)";
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection error: $e");
    }
    
  }
}
