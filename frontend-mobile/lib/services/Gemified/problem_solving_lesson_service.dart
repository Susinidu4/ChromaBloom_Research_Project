// lib/services/Gamified_Knowlage_Builder/problem_solving_lesson_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ProblemSolvingLessonService {
  /// ✅ Change base URL depending on platform:
  /// Android emulator: http://10.0.2.2:5000
  /// Real device:      http://<YOUR_PC_IP>:5000
  /// Flutter web:      http://localhost:5000
  static const String _baseUrl = "http://localhost:5000";

  static const String _path = "/chromabloom/problem-solving-lessons";

  // ---------------------------
  // Helpers
  // ---------------------------
  static Uri _uri(String endpoint) => Uri.parse("$_baseUrl$_path$endpoint");

  static Map<String, dynamic> _decode(http.Response res) {
    final dynamic body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {"data": body};
    }
    final msg = (body is Map && body["message"] != null)
        ? body["message"].toString()
        : "Request failed (${res.statusCode})";
    throw Exception(msg);
  }

  // ---------------------------
  // GET: all lessons
  // ---------------------------
  static Future<List<dynamic>> getAllLessons() async {
    final res = await http.get(_uri("")).timeout(const Duration(seconds: 20));
    final data = _decode(res);
    return (data["data"] as List<dynamic>? ?? []);
  }

  // ---------------------------
  // GET: lesson by id
  // ---------------------------
  static Future<Map<String, dynamic>> getLessonById(String id) async {
    final res =
        await http.get(_uri("/$id")).timeout(const Duration(seconds: 20));
    final data = _decode(res);
    return (data["data"] as Map<String, dynamic>? ?? {});
  }

  // ---------------------------
  // DELETE: lesson
  // ---------------------------
  static Future<String> deleteLesson(String id) async {
    final res =
        await http.delete(_uri("/$id")).timeout(const Duration(seconds: 20));
    final data = _decode(res);
    return data["message"]?.toString() ?? "Deleted";
  }

  // ---------------------------
  // POST: create lesson (multipart + images)
  // tips must be JSON array string if you follow your controller
  // images field name MUST be: "images"
  // ---------------------------
  static Future<Map<String, dynamic>> createLesson({
    required String title,
    String? content,
    required String difficultyLevel,
    required String correctAnswer,
    List<String>? tips,
    String? category, // your backend uses "catergory"
    List<File>? images, // up to 5
  }) async {
    final req = http.MultipartRequest("POST", _uri(""));

    // text fields
    req.fields["title"] = title;
    req.fields["difficultyLevel"] = difficultyLevel;
    req.fields["correct_answer"] = correctAnswer;

    if (content != null) req.fields["content"] = content;

    // Backend expects "tips" can be stringified JSON in multipart
    if (tips != null) req.fields["tips"] = jsonEncode(tips);

    // NOTE: backend variable name is "catergory" (typo). Keep same key.
    if (category != null) req.fields["catergory"] = category;

    // images
    if (images != null && images.isNotEmpty) {
      final limited = images.take(5).toList();
      for (final file in limited) {
        req.files.add(await http.MultipartFile.fromPath("images", file.path));
      }
    }

    final streamed =
        await req.send().timeout(const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);

    final data = _decode(res);
    return (data["data"] as Map<String, dynamic>? ?? {});
  }

  // ---------------------------
  // PUT: update lesson (multipart + optional replace images)
  // If you pass images, your controller REPLACES old images.
  // ---------------------------
  static Future<Map<String, dynamic>> updateLesson({
    required String id,
    String? title,
    String? content,
    String? difficultyLevel,
    String? correctAnswer,
    List<String>? tips,
    String? category,
    List<File>? images, // if provided -> replace images
  }) async {
    final req = http.MultipartRequest("PUT", _uri("/$id"));

    if (title != null) req.fields["title"] = title;
    if (content != null) req.fields["content"] = content;
    if (difficultyLevel != null) req.fields["difficultyLevel"] = difficultyLevel;
    if (correctAnswer != null) req.fields["correct_answer"] = correctAnswer;
    if (tips != null) req.fields["tips"] = jsonEncode(tips);
    if (category != null) req.fields["catergory"] = category;

    if (images != null && images.isNotEmpty) {
      final limited = images.take(5).toList();
      for (final file in limited) {
        req.files.add(await http.MultipartFile.fromPath("images", file.path));
      }
    }

    final streamed =
        await req.send().timeout(const Duration(seconds: 60));
    final res = await http.Response.fromStream(streamed);

    final data = _decode(res);
    return (data["data"] as Map<String, dynamic>? ?? {});
  }
}
