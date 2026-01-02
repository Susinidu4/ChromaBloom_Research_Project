import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class DrawingPredictService {
  // ✅ Change this to your backend base URL
  // Android emulator: http://10.0.2.2:5000
  // Real device (same WiFi): http://YOUR_PC_IP:5000
  // Flutter web: http://localhost:5000
  static const String _baseUrl = "http://10.0.2.2:5000";

  // Node route base
  static const String _path = "/api/gamified/drawing";

  /// GET: /health
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

  /// POST: /predict
  /// Sends image as multipart/form-data with field name: "file"
  static Future<Map<String, dynamic>> predictDrawing(File imageFile) async {
    final url = Uri.parse("$_baseUrl$_path/predict");

    final request = http.MultipartRequest("POST", url);

    // ✅ IMPORTANT: field name must be "file" (matches FastAPI + Node)
    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        imageFile.path,
      ),
    );

    // If you need auth later:
    // request.headers["Authorization"] = "Bearer $token";

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);

    final Map<String, dynamic> data = jsonDecode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Node returns: { message, data: { top1, top3 } }
      return data;
    } else {
      throw Exception(data["error"] ?? "Prediction failed");
    }
  }
}
