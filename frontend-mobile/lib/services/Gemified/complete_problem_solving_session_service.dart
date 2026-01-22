import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart'; // adjust path if needed

class CompleteProblemSolvingSessionService {
  static final String _base = ApiConfig.baseUrl;
  static const String _path = "/chromabloom/complete-problem-solving-sessions";

  static Map<String, dynamic> _decode(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {"data": decoded};
  }

  static Exception _err(http.Response res) {
    Map<String, dynamic> data;
    try {
      data = _decode(res.body);
    } catch (_) {
      data = {};
    }
    return Exception(data["message"] ?? "Request failed (${res.statusCode})");
  }

  // -----------------------------
  // ✅ CREATE
  // POST: /chromabloom/completeProblemSolvingSessions
  // -----------------------------
  static Future<Map<String, dynamic>> create({
    required String childId,
    required String lessonId, // backend field is "lessons"
    num correctnessScore = 0,
  }) async {
    final uri = Uri.parse("$_base$_path");

    final res = await http
        .post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "childId": childId,
            "lessons": lessonId,
            "correctness_score": correctnessScore,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decode(res.body);
  }

  // -----------------------------
  // ✅ GET BY ID
  // GET: /chromabloom/completeProblemSolvingSessions/:id
  // -----------------------------
  static Future<Map<String, dynamic>> getById(String id) async {
    final uri = Uri.parse("$_base$_path/$id");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decode(res.body);
  }

  // -----------------------------
  // ✅ GET BY CHILD + LESSON
  // GET: /chromabloom/completeProblemSolvingSessions/by-child-lesson/:childId/:lessonId
  // -----------------------------
  static Future<Map<String, dynamic>> getByChildAndLesson({
    required String childId,
    required String lessonId,
  }) async {
    final uri = Uri.parse("$_base$_path/by-child-lesson/$childId/$lessonId");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      // keep the error (often 404 if not found)
      throw _err(res);
    }
    return _decode(res.body);
  }

  // -----------------------------
  // ✅ UPDATE
  // PUT: /chromabloom/completeProblemSolvingSessions/:id
  // -----------------------------
  static Future<Map<String, dynamic>> update({
    required String id,
    String? childId,
    String? lessonId,
    num? correctnessScore,
  }) async {
    final uri = Uri.parse("$_base$_path/$id");

    final Map<String, dynamic> payload = {};
    if (childId != null) payload["childId"] = childId;
    if (lessonId != null) payload["lessons"] = lessonId;
    if (correctnessScore != null) payload["correctness_score"] = correctnessScore;

    final res = await http
        .put(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decode(res.body);
  }

  // -----------------------------
  // ✅ DELETE
  // DELETE: /chromabloom/completeProblemSolvingSessions/:id
  // -----------------------------
  static Future<Map<String, dynamic>> delete(String id) async {
    final uri = Uri.parse("$_base$_path/$id");

    final res = await http.delete(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decode(res.body);
  }
}
