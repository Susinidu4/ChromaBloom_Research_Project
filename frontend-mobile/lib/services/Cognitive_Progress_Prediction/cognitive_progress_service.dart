import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgressPredictionApi {
  final String baseUrl;

  ProgressPredictionApi({required this.baseUrl});

  Future<Map<String, dynamic>> predictProgress(
      Map<String, dynamic> features) async {
    final url =
        Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2/predict-progress');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"features": features}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Prediction failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<Map<String, dynamic>> savePrediction({
    required String userId,
    required double progressPrediction,
  }) async {
    final url = Uri.parse('$baseUrl/chromabloom/cognitiveProgress_2');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": userId,
        "progress_prediction": progressPrediction,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Save failed: ${res.statusCode} ${res.body}');
    }
  }
}
