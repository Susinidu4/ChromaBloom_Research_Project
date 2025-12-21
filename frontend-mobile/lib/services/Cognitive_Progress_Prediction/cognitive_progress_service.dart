import 'dart:convert';
import 'package:http/http.dart' as http;

class StoredProgress {
  final String id;
  final String userId;
  final double progressPrediction;
  final DateTime createdAt;

  StoredProgress({
    required this.id,
    required this.userId,
    required this.progressPrediction,
    required this.createdAt,
  });

  factory StoredProgress.fromJson(Map<String, dynamic> json) {
    return StoredProgress(
      id: json["_id"].toString(),
      userId: json["userId"].toString(),
      progressPrediction: (json["progress_prediction"] as num).toDouble(),
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}

class PredictionResponse {
  final double predictedScore;
  final List<dynamic> topFactors;

  PredictionResponse({required this.predictedScore, required this.topFactors});

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictedScore: (json["predicted_score"] as num).toDouble(),
      topFactors: (json["top_factors"] as List<dynamic>? ?? []),
    );
  }
}

class CognitiveProgressService {
  // ⚠️ If Android emulator: use 10.0.2.2 instead of localhost
  static const String baseUrl = "http://localhost:5000";

  static Uri _uri(String path) => Uri.parse("$baseUrl$path");

  // 1) Predict
  static Future<PredictionResponse> predict(Map<String, dynamic> features) async {
    final res = await http.post(
      _uri("/chromabloom/cognitiveProgress/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(features),
    );

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 200 && jsonMap["success"] == true) {
      return PredictionResponse.fromJson(jsonMap);
    }
    throw Exception(jsonMap["error"]?.toString() ?? "Prediction failed");
  }

  // 2) Store prediction
  static Future<StoredProgress> storePrediction({
    required String userId,
    required double progressPrediction,
  }) async {
    final res = await http.post(
      _uri("/chromabloom/cognitiveProgress"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "progress_prediction": progressPrediction,
      }),
    );

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 201 && jsonMap["success"] == true) {
      return StoredProgress.fromJson(jsonMap["data"] as Map<String, dynamic>);
    }
    throw Exception(jsonMap["message"]?.toString() ?? "Store failed");
  }

  // 3) Fetch history by userId
  static Future<List<StoredProgress>> getHistory(String userId) async {
    final res = await http.get(
      _uri("/chromabloom/cognitiveProgress/user/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 200 && jsonMap["success"] == true) {
      final list = (jsonMap["data"] as List<dynamic>);
      return list
          .map((e) => StoredProgress.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(jsonMap["message"]?.toString() ?? "Fetch failed");
  }
}
