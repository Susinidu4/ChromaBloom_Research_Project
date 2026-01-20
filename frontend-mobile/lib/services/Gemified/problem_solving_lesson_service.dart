import 'dart:convert';
import 'package:http/http.dart' as http;

/// Problem Solving Lesson Service
/// Matches backend:
/// POST   /chromabloom/problem-solving-lessons
/// GET    /chromabloom/problem-solving-lessons
/// GET    /chromabloom/problem-solving-lessons/:id
/// PUT    /chromabloom/problem-solving-lessons/:id
/// DELETE /chromabloom/problem-solving-lessons/:id
class ProblemSolvingLessonService {
  ProblemSolvingLessonService._();

  // TODO: change to your server IP / domain
  static const String _baseUrl = "http://localhost:5000"; // Android emulator
  // static const String _baseUrl = "http://localhost:5000"; // Flutter web
  // static const String _baseUrl = "http://192.168.x.x:5000"; // real device WiFi

  static const String _path = "/chromabloom/problem-solving-lessons";

  static Map<String, String> _headers() => const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  // -----------------------------
  // Helpers
  // -----------------------------
  static Exception _errFromResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final msg = body is Map && body["message"] != null
          ? body["message"].toString()
          : "Request failed (${res.statusCode})";
      return Exception(msg);
    } catch (_) {
      return Exception("Request failed (${res.statusCode})");
    }
  }

  /// Mini tutorial item builder
  /// tip_number: Number (required)
  /// tip_content: String (required)
  static Map<String, dynamic> miniTutorial({
    required int tipNumber,
    required String tipContent,
  }) {
    return {
      "tip_number": tipNumber,
      "tip_content": tipContent,
    };
  }

  // -----------------------------
  // CRUD
  // -----------------------------

  /// Create a lesson
  /// Backend expects:
  /// { title, description, difficulty_level, miniTutorialsName, miniTutorials }
  ///
  /// miniTutorials can be an array OR JSON string (your controller supports both).
  static Future<Map<String, dynamic>> createLesson({
    required String title,
    required String description,
    required String difficultyLevel, // Beginner | Intermediate | Advanced
    String? miniTutorialsName,
    List<Map<String, dynamic>>? miniTutorials,
    bool sendMiniTutorialsAsString = false, // optional
  }) async {
    final uri = Uri.parse("$_baseUrl$_path");

    final payload = <String, dynamic>{
      "title": title,
      "description": description,
      "difficulty_level": difficultyLevel,
      if (miniTutorialsName != null) "miniTutorialsName": miniTutorialsName,
      if (miniTutorials != null)
        "miniTutorials": sendMiniTutorialsAsString
            ? jsonEncode(miniTutorials)
            : miniTutorials,
    };

    final res = await http
        .post(uri, headers: _headers(), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }

  /// Get all lessons
  static Future<List<dynamic>> getAllLessons() async {
    final uri = Uri.parse("$_baseUrl$_path");

    final res = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return (body["data"] as List<dynamic>? ?? []);
    }
    throw _errFromResponse(res);
  }

  /// Get lesson by ID (LP-0001)
  static Future<Map<String, dynamic>> getLessonById(String id) async {
    final uri = Uri.parse("$_baseUrl$_path/$id");

    final res = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }

  /// Update lesson by ID
  /// Any field can be updated (send only what you want to change)
  static Future<Map<String, dynamic>> updateLesson({
    required String id,
    String? title,
    String? description,
    String? difficultyLevel, // Beginner | Intermediate | Advanced
    String? miniTutorialsName,
    List<Map<String, dynamic>>? miniTutorials,
    bool sendMiniTutorialsAsString = false,
  }) async {
    final uri = Uri.parse("$_baseUrl$_path/$id");

    final payload = <String, dynamic>{
      if (title != null) "title": title,
      if (description != null) "description": description,
      if (difficultyLevel != null) "difficulty_level": difficultyLevel,
      if (miniTutorialsName != null) "miniTutorialsName": miniTutorialsName,
      if (miniTutorials != null)
        "miniTutorials": sendMiniTutorialsAsString
            ? jsonEncode(miniTutorials)
            : miniTutorials,
    };

    final res = await http
        .put(uri, headers: _headers(), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }

  /// Delete lesson by ID
  static Future<Map<String, dynamic>> deleteLesson(String id) async {
    final uri = Uri.parse("$_baseUrl$_path/$id");

    final res = await http
        .delete(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }
}
