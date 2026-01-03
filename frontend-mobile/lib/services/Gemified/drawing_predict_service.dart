import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class DrawingPredictService {
  /// ✅ IMPORTANT:
  /// - Android emulator: use http://10.0.2.2:5000
  /// - Real device: use http://YOUR_PC_IP:5000  (PC + phone same WiFi)
  /// - Flutter web: use http://localhost:5000
  static const String _baseUrl = "http://localhost:5000";

  /// Node route base
  static const String _path = "/chromabloom/gamified/drawing";

  static Future<Map<String, dynamic>> health() async {
    final url = Uri.parse("$_baseUrl$_path/health");

    final res = await http.get(url).timeout(const Duration(seconds: 15));

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      // if backend returns non-json
      throw Exception("Health failed: Invalid JSON response");
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Health check failed");
    }
  }

  /// ✅ Node returns:
  /// {
  ///   "message": "Prediction success",
  ///   "top1": { "label": "...", "confidence": 21.5 }
  /// }
  static Future<Map<String, dynamic>> predictDrawing(File imageFile) async {
    final url = Uri.parse("$_baseUrl$_path/predict");
    final request = http.MultipartRequest("POST", url);

    // Guess mime type from file path
    final mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";
    final parts = mimeType.split("/");
    final mediaType = (parts.length == 2)
        ? MediaType(parts[0], parts[1])
        : MediaType("image", "jpeg");

    request.files.add(
      await http.MultipartFile.fromPath(
        "file", // ✅ MUST be "file"
        imageFile.path,
        contentType: mediaType,
      ),
    );

    // Send
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);

    // Parse JSON safely
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception("Prediction failed: Invalid JSON response");
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // ✅ Validate expected structure
      if (data["top1"] is! Map) {
        throw Exception("Prediction failed: 'top1' missing in response");
      }
      return data;
    } else {
      throw Exception(data["error"] ?? "Prediction failed");
    }
  }
}
