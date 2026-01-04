// services/gamified_knowledge_builder/complete_drawing_lesson_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompleteDrawingLessonService {
  // ✅ Change this based on platform:
  // Android emulator: http://10.0.2.2:5000
  // Real device: http://YOUR_PC_IP:5000
  // Flutter web: http://localhost:5000
  static const String _baseUrl = "http://localhost:5000";

  // ✅ Your route
  static const String _path = "/chromabloom/completed-drawing-lessons";

  static Map<String, String> _headers() => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  static Exception _errorFromResponse(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      final msg = data["message"] ?? data["error"] ?? "Request failed";
      return Exception(msg);
    } catch (_) {
      return Exception("Request failed (${res.statusCode})");
    }
  }

  /// ✅ POST: Create or update completion (backend prevents duplicates by lesson_id + user_id)
  /// Body: { lesson_id, user_id, correctness_rate }  correctness_rate = 0.0 - 1.0
  static Future<Map<String, dynamic>> createCompletedLesson({
    required String lessonId,
    required String userId,
    double? correctnessRate, // 0..1 (ex: 0.76)
  }) async {
    final url = Uri.parse("$_baseUrl$_path");

    final body = <String, dynamic>{
      "lesson_id": lessonId,
      "user_id": userId,
      if (correctnessRate != null) "correctness_rate": correctnessRate,
    };

    final res = await http
        .post(url, headers: _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errorFromResponse(res);
  }

  /// ✅ GET: All completed drawing lessons
  static Future<Map<String, dynamic>> getAllCompletedLessons() async {
    final url = Uri.parse("$_baseUrl$_path");

    final res = await http
        .get(url, headers: _headers())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errorFromResponse(res);
  }

  /// ✅ GET: One completed record by ID (Mongo _id)
  static Future<Map<String, dynamic>> getCompletedLessonById(
      String recordId) async {
    final url = Uri.parse("$_baseUrl$_path/$recordId");

    final res = await http
        .get(url, headers: _headers())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errorFromResponse(res);
  }

  /// ✅ GET: Completed lessons for a user
  static Future<Map<String, dynamic>> getCompletedLessonsByUser(
      String userId) async {
    final url = Uri.parse("$_baseUrl$_path/user/$userId");

    final res = await http
        .get(url, headers: _headers())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errorFromResponse(res);
  }

  /// ✅ PUT: Update completed record by ID
  /// You can update lesson_id / user_id / correctness_rate
  static Future<Map<String, dynamic>> updateCompletedLesson({
    required String recordId,
    String? lessonId,
    String? userId,
    double? correctnessRate, // 0..1
  }) async {
    final url = Uri.parse("$_baseUrl$_path/$recordId");

    final body = <String, dynamic>{
      if (lessonId != null) "lesson_id": lessonId,
      if (userId != null) "user_id": userId,
      if (correctnessRate != null) "correctness_rate": correctnessRate,
    };

    final res = await http
        .put(url, headers: _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errorFromResponse(res);
  }

  /// ✅ DELETE: Remove completed record by ID
  static Future<Map<String, dynamic>> deleteCompletedLesson(
      String recordId) async {
    final url = Uri.parse("$_baseUrl$_path/$recordId");

    final res = await http
        .delete(url, headers: _headers())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errorFromResponse(res);
  }

  /// Small helper: convert model output like 76% into correctness_rate 0.76 (if needed)
  static double percentToRate(num percent) {
    final p = percent.toDouble();
    return (p <= 1.0) ? p : (p / 100.0);
  }
}
