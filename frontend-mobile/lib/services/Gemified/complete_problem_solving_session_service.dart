import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart'; // adjust path if needed

class CompleteProblemSolvingSessionService {
  static final String _base = ApiConfig.baseUrl;
  static const String _path = "/chromabloom/completeProblemSolvingSessions";

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
      throw Exception("Create session failed (${res.statusCode}): ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // -----------------------------
  // ✅ GET BY ID
  // GET: /chromabloom/completeProblemSolvingSessions/:id
  // -----------------------------
  static Future<Map<String, dynamic>> getById(String id) async {
    final uri = Uri.parse("$_base$_path/$id");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Get by id failed (${res.statusCode}): ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
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
      throw Exception(
          "Get by child+lesson failed (${res.statusCode}): ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // -----------------------------
  // ✅ UPDATE
  // PUT: /chromabloom/completeProblemSolvingSessions/:id
  // Send only fields you want to update
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
      throw Exception("Update failed (${res.statusCode}): ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // -----------------------------
  // ✅ DELETE
  // DELETE: /chromabloom/completeProblemSolvingSessions/:id
  // -----------------------------
  static Future<Map<String, dynamic>> delete(String id) async {
    final uri = Uri.parse("$_base$_path/$id");

    final res = await http.delete(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Delete failed (${res.statusCode}): ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
