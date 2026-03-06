import 'dart:convert';
import 'package:http/http.dart' as http;

/// Problem Solving Level Service
/// Matches backend:
/// POST   /chromabloom/problem-solving-levels
/// GET    /chromabloom/problem-solving-levels
/// GET    /chromabloom/problem-solving-levels/user/:userId
/// PUT    /chromabloom/problem-solving-levels/:id
/// PUT    /chromabloom/problem-solving-levels/user/:userId
class ProblemSolvingLevelService {
  ProblemSolvingLevelService._();

  static const String _baseUrl = "http://localhost:5000"; 
  static const String _path = "/chromabloom/problem-solving-levels";

  static Map<String, String> _headers() => const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

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

  // -----------------------------
  // CRUD
  // -----------------------------

  /// Create a problem solving level
  static Future<Map<String, dynamic>> createLevel({
    required String userId,
    required String level,
  }) async {
    final uri = Uri.parse("$_baseUrl$_path");

    final payload = {
      "userId": userId,
      "level": level,
    };

    final res = await http
        .post(uri, headers: _headers(), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }

  /// Get all problem solving levels
  static Future<List<dynamic>> getAllLevels() async {
    final uri = Uri.parse("$_baseUrl$_path");

    final res = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw _errFromResponse(res);
  }

  /// Get problem solving level by user ID
  static Future<Map<String, dynamic>> getLevelByUserId(String userId) async {
    final uri = Uri.parse("$_baseUrl$_path/user/$userId");

    final res = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }

  /// Update problem solving level by Entry ID (_id)
  static Future<Map<String, dynamic>> updateLevel({
    required String id,
    required String level,
  }) async {
    final uri = Uri.parse("$_baseUrl$_path/$id");

    final payload = {
      "level": level,
    };

    final res = await http
        .put(uri, headers: _headers(), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }

  /// Update problem solving level by user ID
  static Future<Map<String, dynamic>> updateLevelByUserId({
    required String userId,
    required String level,
  }) async {
    final uri = Uri.parse("$_baseUrl$_path/user/$userId");

    final payload = {
      "level": level,
    };

    final res = await http
        .put(uri, headers: _headers(), body: jsonEncode(payload))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw _errFromResponse(res);
  }
}
