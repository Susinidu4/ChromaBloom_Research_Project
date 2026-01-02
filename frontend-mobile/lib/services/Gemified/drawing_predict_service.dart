import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class DrawingPredictService {
  // ✅ Change this to your backend base URL
  // Android emulator: http://10.0.2.2:5000
  // Real device (same WiFi): http://YOUR_PC_IP:5000
  // Flutter web: http://localhost:5000
  static const String _baseUrl = "http://localhost:5000";

  // Node route base
  static const String _path = "/chromabloom/gamified/drawing";

  static Future<Map<String, dynamic>> health() async {
    final url = Uri.parse("$_baseUrl$_path/health");
    final res = await http.get(url).timeout(const Duration(seconds: 15));

    final data = jsonDecode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Health check failed");
    }
  }

  static Future<Map<String, dynamic>> predictDrawing(File imageFile) async {
    final url = Uri.parse("$_baseUrl$_path/predict");

    final request = http.MultipartRequest("POST", url);

    // ✅ Detect MIME type properly (fallback to jpeg)
    final mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";
    final parts = mimeType.split("/");
    final mediaType = (parts.length == 2)
        ? MediaType(parts[0], parts[1])
        : MediaType("image", "jpeg");

    // ✅ IMPORTANT: field name must be "file"
    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        imageFile.path,
        contentType: mediaType, // ✅ THIS FIXES multer rejecting it
      ),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);

    final Map<String, dynamic> data = jsonDecode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Prediction failed");
    }
  }
}
