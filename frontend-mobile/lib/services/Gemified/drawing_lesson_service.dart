// lib/services/drawing_lesson_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class DrawingLessonService {
  final String baseUrl;
  final String? token;

  /// baseUrl example: "http://10.0.2.2:5000/chromabloom/drawing-lessons"
  DrawingLessonService({
    required this.baseUrl,
    this.token,
  });

  Map<String, String> _headers({bool isJson = true}) {
    final headers = <String, String>{};
    if (isJson) headers["Content-Type"] = "application/json";
    if (token != null && token!.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  Uri _u([String? path]) => Uri.parse(path == null ? baseUrl : "$baseUrl/$path");

  // ----------------------------
  // GET ALL
  // ----------------------------
  Future<List<dynamic>> getAllLessons() async {
    final res = await http.get(_u(), headers: _headers(isJson: false));

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (data["data"] as List<dynamic>?) ?? [];
    }
    throw Exception(data["message"] ?? "Failed to fetch lessons");
  }

  // ----------------------------
  // GET BY ID
  // ----------------------------
  Future<Map<String, dynamic>> getLessonById(String id) async {
    final res = await http.get(_u(id), headers: _headers(isJson: false));

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (data["data"] as Map<String, dynamic>?) ?? {};
    }
    throw Exception(data["message"] ?? "Lesson not found");
  }

  // ----------------------------
  // CREATE (multipart with video)
  // tips -> JSON string
  // ----------------------------
  Future<Map<String, dynamic>> createLesson({
    required String title,
    required String description,
    required String difficultyLevel,
    required File videoFile,
    List<String> tips = const [],
  }) async {
    final request = http.MultipartRequest("POST", _u());

    // headers (do NOT set Content-Type manually for multipart)
    if (token != null && token!.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }

    request.fields["title"] = title;
    request.fields["description"] = description;
    request.fields["difficulty_level"] = difficultyLevel;
    request.fields["tips"] = jsonEncode(tips); // backend expects JSON string

    request.files.add(
      await http.MultipartFile.fromPath(
        "video",
        videoFile.path,
        // contentType is optional; backend uses multer buffer
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (data["data"] as Map<String, dynamic>?) ?? {};
    }
    throw Exception(data["message"] ?? "Failed to create lesson");
  }

  // ----------------------------
  // UPDATE (multipart, video optional)
  // If no video file is passed, it updates only fields.
  // ----------------------------
  Future<Map<String, dynamic>> updateLesson({
    required String id,
    String? title,
    String? description,
    String? difficultyLevel,
    List<String>? tips,
    File? videoFile,
  }) async {
    final request = http.MultipartRequest("PUT", _u(id));

    if (token != null && token!.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }

    if (title != null && title.isNotEmpty) request.fields["title"] = title;
    if (description != null && description.isNotEmpty) {
      request.fields["description"] = description;
    }
    if (difficultyLevel != null && difficultyLevel.isNotEmpty) {
      request.fields["difficulty_level"] = difficultyLevel;
    }
    if (tips != null) {
      request.fields["tips"] = jsonEncode(tips); // JSON string
    }

    if (videoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath("video", videoFile.path),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (data["data"] as Map<String, dynamic>?) ?? {};
    }
    throw Exception(data["message"] ?? "Failed to update lesson");
  }

  // ----------------------------
  // DELETE
  // ----------------------------
  Future<bool> deleteLesson(String id) async {
    final res = await http.delete(_u(id), headers: _headers(isJson: false));

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return true;
    throw Exception(data["message"] ?? "Failed to delete lesson");
  }

  // ----------------------------
  // Helpers
  // ----------------------------
  Map<String, dynamic> _decode(http.Response res) {
    try {
      final body = res.body.isEmpty ? "{}" : res.body;
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"raw": decoded};
    } catch (_) {
      return {"message": "Invalid server response", "raw": res.body};
    }
  }
}
