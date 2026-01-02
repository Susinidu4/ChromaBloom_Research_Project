import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class NoTodayJournalException implements Exception {
  final String message;
  NoTodayJournalException(this.message);

  @override
  String toString() => message;
}

class WellnessRecommendationService {
  static final String _base = ApiConfig.baseUrl;
  static const String _prefix = "/chromabloom/stressAnalysis";

  static Future<Map<String, dynamic>> fetchRecommendation(String caregiverId) async {
    final url = Uri.parse("$_base$_prefix/compute/$caregiverId");

    final response = await http.get(url, headers: {"Content-Type": "application/json"});

    // Handle non-200 nicely
    if (response.statusCode != 200) {
      String msg = "Failed to fetch recommendation";
      try {
        final err = json.decode(response.body);
        msg = (err["error"] ?? msg).toString();

        // ✅ Detect the “no journal today” case
        if (response.statusCode == 404 &&
            msg.toLowerCase().contains("journalentry") &&
            msg.toLowerCase().contains("today")) {
          throw NoTodayJournalException(msg);
        }
      } catch (_) {
        // ignore json parse failures
      }

      throw Exception(msg);
    }

    final data = json.decode(response.body);
    final rec = data["recommendation"];

    if (rec == null) {
      throw Exception("No recommendation found for the predicted stress level.");
    }

    return {
      "title": rec["title"] ?? "",
      "message": rec["message"] ?? "",
      "duration": rec["duration"] ?? 0,
      "steps": (rec["steps"] as List<dynamic>? ?? [])
          .map((e) => e["instruction"].toString())
          .toList(),
      "stressLevel": data["stress"]?["stress_level"] ?? "",
    };
  }
}
