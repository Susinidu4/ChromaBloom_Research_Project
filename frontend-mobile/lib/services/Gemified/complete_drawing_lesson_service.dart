// services/gamified_knowledge_builder/complete_drawing_lesson_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CompleteDrawingLessonService {
  // ✅ Set this correctly:
  // Android emulator  : http://10.0.2.2:5000
  // Real device (WiFi): http://192.168.x.x:5000   (your PC IP)
  // Flutter web       : http://localhost:5000
  static String baseUrl = "http://localhost:5000";

  // ✅ Route base (matches your Express mount)
  static const String _path = "/chromabloom/completed-drawing-lessons";

  static const Duration _timeout = Duration(seconds: 20);

  static Map<String, String> _headers() => const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  static Exception _errorFromResponse(http.Response res) {
    try {
      final body = (res.body.isEmpty) ? {} : jsonDecode(res.body);
      if (body is Map) {
        final msg = body["message"] ?? body["error"] ?? "Request failed";
        return Exception("$msg (${res.statusCode})");
      }
      return Exception("Request failed (${res.statusCode})");
    } catch (_) {
      return Exception("Request failed (${res.statusCode})");
    }
  }

  static Exception _networkError(Object e) {
    if (e is TimeoutException) {
      return Exception("Request timeout. Check baseUrl / server / Wi-Fi.");
    }
    if (e is SocketException) {
      return Exception("Server not reachable. Check baseUrl / Wi-Fi / backend.");
    }
    return Exception("Network error: $e");
  }

  static Uri _uri(String subPath) => Uri.parse("$baseUrl$_path$subPath");

  // ✅ Normalize lessonId to avoid saving null/empty/"null"
  static String _normalizeLessonId(String lessonId) {
    final id = lessonId.trim();
    if (id.isEmpty || id.toLowerCase() == "null" || id.toLowerCase() == "undefined") {
      throw Exception("Invalid lessonId provided. (empty/null)");
    }
    return id;
  }

  /// ✅ POST /chromabloom/completed-drawing-lessons
  /// Body: { lesson_id, user_id, correctness_rate }  correctness_rate = 0..1
  static Future<Map<String, dynamic>> createCompletedLesson({
    required String lessonId,
    required String userId,
    double? correctnessRate, // 0..1
  }) async {
    final normalizedLessonId = _normalizeLessonId(lessonId);

    // ✅ Send aliases too (in case backend expects a different field name)
    final body = <String, dynamic>{
      "lesson_id": normalizedLessonId,          // ✅ your current expected key
      "lessonId": normalizedLessonId,           // ✅ common alternative
      "lesson": normalizedLessonId,             // ✅ common alternative
      "drawing_lesson_id": normalizedLessonId,  // ✅ common alternative
      "user_id": userId.trim(),
      if (correctnessRate != null)
        "correctness_rate": correctnessRate.clamp(0.0, 1.0),
    };

    try {
      final res = await http
          .post(_uri(""), headers: _headers(), body: jsonEncode(body))
          .timeout(_timeout);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// ✅ GET /chromabloom/completed-drawing-lessons
  static Future<Map<String, dynamic>> getAllCompletedLessons() async {
    try {
      final res = await http.get(_uri(""), headers: _headers()).timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// ✅ GET /chromabloom/completed-drawing-lessons/user/:userId
  static Future<Map<String, dynamic>> getCompletedLessonsByUser(String userId) async {
    try {
      final res = await http
          .get(_uri("/user/${userId.trim()}"), headers: _headers())
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// ✅ GET /chromabloom/completed-drawing-lessons/:id
  static Future<Map<String, dynamic>> getCompletedLessonById(String recordId) async {
    try {
      final res = await http
          .get(_uri("/${recordId.trim()}"), headers: _headers())
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// ✅ GET /chromabloom/completed-drawing-lessons/lesson/:lessonId/user/:userId
  static Future<Map<String, dynamic>> getCompletedByLessonAndUser({
    required String lessonId,
    required String userId,
  }) async {
    final normalizedLessonId = _normalizeLessonId(lessonId);

    try {
      final res = await http
          .get(_uri("/lesson/$normalizedLessonId/user/${userId.trim()}"), headers: _headers())
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// ✅ GET /chromabloom/completed-drawing-lessons/has-completed/lesson/:lessonId/user/:userId
  static Future<bool> hasCompletedLesson({
    required String lessonId,
    required String userId,
  }) async {
    final normalizedLessonId = _normalizeLessonId(lessonId);

    try {
      final res = await http
          .get(
            _uri("/has-completed/lesson/$normalizedLessonId/user/${userId.trim()}"),
            headers: _headers(),
          )
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json["data"];
        return data != null;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// ✅ PUT /chromabloom/completed-drawing-lessons/:id
  static Future<Map<String, dynamic>> updateCompletedLesson({
    required String recordId,
    String? lessonId,
    String? userId,
    double? correctnessRate, // 0..1
  }) async {
    final body = <String, dynamic>{
      if (lessonId != null) "lesson_id": _normalizeLessonId(lessonId),
      if (lessonId != null) "lessonId": _normalizeLessonId(lessonId),
      if (lessonId != null) "lesson": _normalizeLessonId(lessonId),
      if (lessonId != null) "drawing_lesson_id": _normalizeLessonId(lessonId),
      if (userId != null) "user_id": userId.trim(),
      if (correctnessRate != null) "correctness_rate": correctnessRate.clamp(0.0, 1.0),
    };

    try {
      final res = await http
          .put(_uri("/${recordId.trim()}"), headers: _headers(), body: jsonEncode(body))
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// ✅ DELETE /chromabloom/completed-drawing-lessons/:id
  static Future<Map<String, dynamic>> deleteCompletedLesson(String recordId) async {
    try {
      final res = await http
          .delete(_uri("/${recordId.trim()}"), headers: _headers())
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      throw _errorFromResponse(res);
    } catch (e) {
      throw _networkError(e);
    }
  }

  /// Helper: convert model output like 76 (%) into 0.76 (if needed)
  static double percentToRate(num percent) {
    final p = percent.toDouble();
    return (p <= 1.0) ? p : (p / 100.0);
  }
}
