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
  static Uri _uri(String subPath, {Map<String, String>? query}) {
    final uri = Uri.parse("$_base$_path$subPath");
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  static Map<String, dynamic> _decode(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"message": "Invalid server response (not JSON object)", "raw": res.body};
    } catch (_) {
      return {"message": "Invalid server response", "raw": res.body};
    }
  }

  // ----------------------------
  // CREATE QUIZ
  // Supports:
  // 1) JSON only
  // 2) multipart/form-data with images (multiple)
  // images map to answers[i].img_url in order (backend behavior)
  // ----------------------------
  static Future<Map<String, dynamic>> createQuize({
    required String question,
    required String lessonId, // maps to lesson_id in backend
    String? nameTag,
    required String difficultyLevel,
    required int correctAnswer,
    List<Map<String, dynamic>>? answers,
    List<File>? imageFiles,
  }) async {
    // If no images -> JSON request
    if (imageFiles == null || imageFiles.isEmpty) {
      final res = await http
          .post(
            _uri(""),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "question": question,
              "lesson_id": lessonId,
              "name_tag": nameTag,
              "difficulty_level": difficultyLevel,
              "correct_answer": correctAnswer,
              "answers": answers ?? [],
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decode(res);
      if (res.statusCode >= 200 && res.statusCode < 300) return body;
      throw Exception(body["message"] ?? "Failed to create quiz");
    }

    // Multipart request with images
    final request = http.MultipartRequest("POST", _uri(""));

    request.fields["question"] = question;
    request.fields["lesson_id"] = lessonId;
    if (nameTag != null) request.fields["name_tag"] = nameTag;
    request.fields["difficulty_level"] = difficultyLevel;
    request.fields["correct_answer"] = correctAnswer.toString();

    // backend expects answers can be JSON string when form-data
    if (answers != null) {
      request.fields["answers"] = jsonEncode(answers);
    }

    for (final file in imageFiles) {
      final filename = file.path.split(Platform.pathSeparator).last;

      request.files.add(
        await http.MultipartFile.fromPath(
          "images", // must match upload.array("images", 10)
          file.path,
          filename: filename,
          contentType: _guessMediaType(filename),
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(seconds: 40));
    final res = await http.Response.fromStream(streamed);

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body["message"] ?? "Failed to create quiz (multipart)");
  }

  // ----------------------------
  // GET ALL (optional filter by lesson_id)
  // GET /chromabloom/quizes?lesson_id=LP-0001
  // ----------------------------
  static Future<List<dynamic>> getAllQuizes({String? lessonId}) async {
    final query = <String, String>{};
    if (lessonId != null && lessonId.isNotEmpty) {
      query["lesson_id"] = lessonId;
    }

    final res = await http.get(_uri("", query: query)).timeout(
          const Duration(seconds: 20),
        );

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (body["data"] as List<dynamic>? ?? []);
    }
    throw Exception(body["message"] ?? "Failed to load quizzes");
  }

  // ----------------------------
  // GET ONE BY ID
  // GET /chromabloom/quizes/:id
  // ----------------------------
  static Future<Map<String, dynamic>> getQuizeById(String id) async {
    final res = await http.get(_uri("/$id")).timeout(
          const Duration(seconds: 20),
        );

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body["message"] ?? "Failed to load quiz");
  }

  // ----------------------------
  // GET BY LESSON ID  ✅ FIXED ROUTE MATCH
  // GET /chromabloom/quizes/lesson/:lessonId
  // ----------------------------
  static Future<List<dynamic>> getQuizeByLessonId(String lessonId) async {
    final safeLessonId = Uri.encodeComponent(lessonId);

    final res = await http.get(_uri("/lesson/$safeLessonId")).timeout(
          const Duration(seconds: 20),
        );

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (body["data"] as List<dynamic>? ?? []);
    }
    throw Exception(body["message"] ?? "Failed to load quizzes for lesson");
  }

  // ----------------------------
  // UPDATE QUIZ
  // Supports:
  // 1) JSON partial update
  // 2) multipart with images -> replaces answers in order (backend behavior)
  // ----------------------------
  static Future<Map<String, dynamic>> updateQuize({
    required String id,
    String? question,
    String? lessonId,
    String? nameTag,
    String? difficultyLevel,
    int? correctAnswer,
    List<Map<String, dynamic>>? answers,
    List<File>? imageFiles,
  }) async {
    // JSON update if no images
    if (imageFiles == null || imageFiles.isEmpty) {
      final payload = <String, dynamic>{};

      if (question != null) payload["question"] = question;
      if (lessonId != null) payload["lesson_id"] = lessonId;
      if (nameTag != null) payload["name_tag"] = nameTag;
      if (difficultyLevel != null) payload["difficulty_level"] = difficultyLevel;
      if (correctAnswer != null) payload["correct_answer"] = correctAnswer;
      if (answers != null) payload["answers"] = answers;

      final res = await http
          .put(
            _uri("/$id"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decode(res);
      if (res.statusCode >= 200 && res.statusCode < 300) return body;
      throw Exception(body["message"] ?? "Failed to update quiz");
    }

    // Multipart update with images (backend replaces answers)
    final request = http.MultipartRequest("PUT", _uri("/$id"));

    if (question != null) request.fields["question"] = question;
    if (lessonId != null) request.fields["lesson_id"] = lessonId;
    if (nameTag != null) request.fields["name_tag"] = nameTag;
    if (difficultyLevel != null) request.fields["difficulty_level"] = difficultyLevel;
    if (correctAnswer != null) request.fields["correct_answer"] = correctAnswer.toString();

    // backend allows answers in body too (JSON string), but images will replace anyway
    if (answers != null) {
      request.fields["answers"] = jsonEncode(answers);
    }

    for (final file in imageFiles) {
      final filename = file.path.split(Platform.pathSeparator).last;

      request.files.add(
        await http.MultipartFile.fromPath(
          "images",
          file.path,
          filename: filename,
          contentType: _guessMediaType(filename),
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(seconds: 40));
    final res = await http.Response.fromStream(streamed);

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body["message"] ?? "Failed to update quiz (multipart)");
  }

  // ----------------------------
  // DELETE QUIZ
  // DELETE /chromabloom/quizes/:id
  // ----------------------------
  static Future<Map<String, dynamic>> deleteQuize(String id) async {
    final res = await http.delete(_uri("/$id")).timeout(
          const Duration(seconds: 20),
        );

    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body["message"] ?? "Failed to delete quiz");
  }

  // ----------------------------
  // Guess media type for images
  // ----------------------------
  static MediaType _guessMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith(".png")) return MediaType("image", "png");
    if (lower.endsWith(".webp")) return MediaType("image", "webp");
    if (lower.endsWith(".jpg")) return MediaType("image", "jpeg");
    if (lower.endsWith(".jpeg")) return MediaType("image", "jpeg");
    return MediaType("image", "jpeg");
  }
}
