import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgressPredictionApi {
  final String baseUrl;

  ProgressPredictionApi({required this.baseUrl});

  /// ✅ Predict progress using ML service
  /// POST /chromabloom/cognitiveProgress_2/predict-progress
  Future<Map<String, dynamic>> predictProgress(
    Map<String, dynamic> features, {
    int topK = 10,
  }) async {
    final url =
        Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2/predict-progress');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "features": features,
        "top_k": topK,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Prediction failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ Save a prediction record to MongoDB
  /// POST /chromabloom/cognitiveProgress_2
  Future<Map<String, dynamic>> savePrediction({
    required String userId,
    required double progressPrediction,
    List<Map<String, dynamic>>? positiveFactors,
    List<Map<String, dynamic>>? negativeFactors,
  }) async {
    final url = Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": userId,
        "progress_prediction": progressPrediction,
        "positive_factors": positiveFactors ?? [],
        "negative_factors": negativeFactors ?? [],
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Save failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ Fetch all progress records
  /// GET /chromabloom/cognitiveProgress_2
  Future<Map<String, dynamic>> getAllProgress() async {
    final url = Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2');

    final res = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Fetch all failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ Fetch saved predictions by userId (childId)
  /// GET /chromabloom/cognitiveProgress_2/user/:userId
  Future<Map<String, dynamic>> getPredictionsByUserId(String userId) async {
    final url =
        Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2/user/$userId');

    final res = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Fetch failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ Fetch a single progress record by record ID
  /// GET /chromabloom/cognitiveProgress_2/:id
  Future<Map<String, dynamic>> getProgressById(String id) async {
    final url = Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2/$id');

    final res = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Fetch by ID failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ Update a progress record
  /// PUT /chromabloom/cognitiveProgress_2/:id
  Future<Map<String, dynamic>> updateProgress(
    String id, {
    String? userId,
    double? progressPrediction,
    List<Map<String, dynamic>>? positiveFactors,
    List<Map<String, dynamic>>? negativeFactors,
  }) async {
    final url = Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2/$id');

    final Map<String, dynamic> body = {};
    if (userId != null) body['userId'] = userId;
    if (progressPrediction != null) body['progress_prediction'] = progressPrediction;
    if (positiveFactors != null) body['positive_factors'] = positiveFactors;
    if (negativeFactors != null) body['negative_factors'] = negativeFactors;

    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Update failed: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ Delete a progress record
  /// DELETE /chromabloom/cognitiveProgress_2/:id
  Future<Map<String, dynamic>> deleteProgress(String id) async {
    final url = Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2/$id');

    final res = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Delete failed: ${res.statusCode} ${res.body}');
    }
  }
}
