import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class CompleteProblemSolvingSessionService {
  static final String _base = ApiConfig.baseUrl;
  static const String _path = "/chromabloom/complete-problem-solving-sessions";

  static Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {"data": decoded};
  }

  static Exception _err(http.Response res) {
    Map<String, dynamic> data;
    try {
      data = _decodeMap(res.body);
    } catch (_) {
      data = {};
    }
    return Exception(data["message"] ?? "Request failed (${res.statusCode})");
  }

  static Future<Map<String, dynamic>> create({
    required String childId,
    required String lessonId,
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
    return _decodeMap(res.body);
  }

  static Future<Map<String, dynamic>> getById(String id) async {
    final uri = Uri.parse("$_base$_path/$id");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decodeMap(res.body);
  }

  /// returns:
  /// { count: 1, data: [ {...} ] }
  static Future<Map<String, dynamic>> getByChildAndLesson({
    required String childId,
    required String lessonId,
  }) async {
    final uri = Uri.parse("$_base$_path/by-child-lesson/$childId/$lessonId");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decodeMap(res.body);
  }

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
    return _decodeMap(res.body);
  }

  static Future<Map<String, dynamic>> delete(String id) async {
    final uri = Uri.parse("$_base$_path/$id");

    final res = await http.delete(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decodeMap(res.body);
  }

  static Future<Map<String, dynamic>> getCompletedSessionsByUser(String childId) async {
    final uri = Uri.parse("$_base$_path/user/$childId");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _err(res);
    }
    return _decodeMap(res.body);
  }

  /// Helper: extract correctness_score safely from {count, data:[...]}
  static double extractCorrectnessScore(Map<String, dynamic> res) {
    try {
      final list = (res["data"] as List<dynamic>? ?? []);
      if (list.isEmpty) return 0.0;
      final first = list.first as Map<String, dynamic>;
      final v = first["correctness_score"];
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  static Future<Map<String, dynamic>> upsert({
    required String childId,
    required String lessonId,
    required num correctnessScore,
  }) async {
    // 1. check if exists
    List<dynamic> list = [];
    try {
      final check = await getByChildAndLesson(childId: childId, lessonId: lessonId);
      list = (check["data"] as List<dynamic>? ?? []);
    } catch (_) {
      // ignore, proceed as "not found"
    }

    if (list.isNotEmpty) {
      // 2. update existing
      final first = list.first as Map<String, dynamic>;
      final id = (first["_id"] ?? first["id"]).toString();
      return await update(
        id: id,
        correctnessScore: correctnessScore,
      );
    } else {
      // 3. create new
      return await create(
        childId: childId,
        lessonId: lessonId,
        correctnessScore: correctnessScore,
      );
    }
  }
}
