import 'dart:convert';
import 'package:http/http.dart' as http;

class DrawingLevelService {
  final String baseUrl;
  final String? token;

  /// baseUrl example: "http://10.0.2.2:5000/chromabloom/drawing-levels"
  DrawingLevelService({
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
  // CREATE
  // ----------------------------
  Future<Map<String, dynamic>> createDrawingLevel({
    required String userId,
    required String level,
    String? description,
  }) async {
    final body = jsonEncode({
      "user_id": userId,
      "level": level,
      "description": description,
    });

    final res = await http.post(
      _u("create"),
      headers: _headers(),
      body: body,
    );

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }
    throw Exception(data["message"] ?? "Failed to create drawing level");
  }

  // ----------------------------
  // UPDATE
  // ----------------------------
  Future<Map<String, dynamic>> updateDrawingLevel({
    required String id,
    required String level,
    String? description,
  }) async {
    final body = jsonEncode({
      "level": level,
      "description": description,
    });

    final res = await http.put(
      _u("update/$id"),
      headers: _headers(),
      body: body,
    );

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }
    throw Exception(data["message"] ?? "Failed to update drawing level");
  }

  // ----------------------------
  // GET BY USER ID
  // ----------------------------
  Future<List<dynamic>> getDrawingLevelByUserId(String userId) async {
    final res = await http.get(
      _u("user/$userId"),
      headers: _headers(isJson: false),
    );

    final data = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data is List ? data : [data];
    }
    
    // If 404, we might want to return an empty list or handle it as "not found"
    if (res.statusCode == 404) {
      return [];
    }
    
    throw Exception(data["message"] ?? "Failed to fetch drawing level for user");
  }

  // ----------------------------
  // Helpers
  // ----------------------------
  dynamic _decode(http.Response res) {
    try {
      final body = res.body.isEmpty ? "{}" : res.body;
      return jsonDecode(body);
    } catch (_) {
      return {"message": "Invalid server response", "raw": res.body};
    }
  }
}
