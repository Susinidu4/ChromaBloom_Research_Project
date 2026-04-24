// services/Gamified_Knowlage_Builder/quize_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class QuizeService {
  /// IMPORTANT:
  /// - Android emulator: use 10.0.2.2 instead of localhost
  /// - Real device: use your PC IP (same WiFi), e.g. http://192.168.1.20:5000
  /// - iOS simulator: localhost usually works
  static const String _base = "http://localhost:5000"; // <-- change if needed
  static const String _path = "/chromabloom/quizes";

  // ----------------------------
  // Helpers
  // ----------------------------
  static Uri _uri(String subPath) {
    return Uri.parse("$_base$_path$subPath");
  }

  static Map<String, dynamic> _decode(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {
        "message": "Invalid server response (not JSON object)",
        "raw": res.body
      };
    } catch (_) {
      return {"message": "Invalid server response", "raw": res.body};
    }
  }

  static MediaType _guessMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith(".png")) return MediaType("image", "png");
    if (lower.endsWith(".webp")) return MediaType("image", "webp");
    if (lower.endsWith(".jpg")) return MediaType("image", "jpeg");
    if (lower.endsWith(".jpeg")) return MediaType("image", "jpeg");
    return MediaType("image", "jpeg");
  }

  // ============================================================
  // NOTE:
  // As you requested: DO NOT add create/update (edit) methods.
  // Only updated the "GET" + "DELETE" methods to match new backend.
  // ============================================================

  // ----------------------------
  // GET ALL QUIZZES  UPDATED (no lesson_id query anymore)
  // GET /chromabloom/quizes
  // ----------------------------
  static Future<List<dynamic>> getAllQuizes() async {
    final res = await http.get(_uri("")).timeout(const Duration(seconds: 20));

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (body["data"] as List<dynamic>? ?? []);
    }
    throw Exception(body["message"] ?? "Failed to load quizzes");
  }

  // ----------------------------
  // GET QUIZ BY LESSON ID UPDATED (route-based filter)
  // GET /chromabloom/quizes/lesson/:lessonId
  // ----------------------------
  static Future<List<dynamic>> getQuizeByLessonId(String lessonId) async {
    final safeLessonId = Uri.encodeComponent(lessonId);

    final res = await http
        .get(_uri("/lesson/$safeLessonId"))
        .timeout(const Duration(seconds: 20));

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (body["data"] as List<dynamic>? ?? []);
    }
    throw Exception(body["message"] ?? "Failed to load quizzes for lesson");
  }

  // ----------------------------
  // GET ONE BY ID (same)
  // GET /chromabloom/quizes/:id
  // ----------------------------
  static Future<Map<String, dynamic>> getQuizeById(String id) async {
    final safeId = Uri.encodeComponent(id);

    final res =
        await http.get(_uri("/$safeId")).timeout(const Duration(seconds: 20));

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body["message"] ?? "Failed to load quiz");
  }

  // ----------------------------
  // DELETE QUIZ (same)
  // DELETE /chromabloom/quizes/:id
  // ----------------------------
  static Future<Map<String, dynamic>> deleteQuize(String id) async {
    final safeId = Uri.encodeComponent(id);

    final res = await http
        .delete(_uri("/$safeId"))
        .timeout(const Duration(seconds: 20));

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body["message"] ?? "Failed to delete quiz");
  }
}

