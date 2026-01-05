import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';

class StressAnalysisService {
    static final String _base = ApiConfig.baseUrl;

  static const String _path = "/chromabloom/stressAnalysis/compute";

  static Future<StressComputeResponse> compute({
    required String caregiverId,
  }) async {
    final uri = Uri.parse("$_base$_path/$caregiverId");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Compute failed (${res.statusCode}): ${res.body}");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StressComputeResponse.fromJson(data);
  }
}

class StressComputeResponse {
  final StressDto stress;
  final RecommendationDto? recommendation;

  StressComputeResponse({
    required this.stress,
    required this.recommendation,
  });

  factory StressComputeResponse.fromJson(Map<String, dynamic> json) {
    return StressComputeResponse(
      stress: StressDto.fromJson((json["stress"] ?? {}) as Map<String, dynamic>),
      recommendation: json["recommendation"] == null
          ? null
          : RecommendationDto.fromJson(
              json["recommendation"] as Map<String, dynamic>,
            ),
    );
  }
}

class StressDto {
  final String stressLevel; // "Low" | "Medium" | "High" | "Critical"
  final int stressScore; // 0..3
  final double stressProbability;
  final int consecutiveHighDays;
  final bool escalationTriggered;
  final DateTime? scoreDate;
  final DateTime? computedAt;

  StressDto({
    required this.stressLevel,
    required this.stressScore,
    required this.stressProbability,
    required this.consecutiveHighDays,
    required this.escalationTriggered,
    required this.scoreDate,
    required this.computedAt,
  });

  factory StressDto.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? s) => (s == null || s.isEmpty) ? null : DateTime.tryParse(s);

    return StressDto(
      stressLevel: (json["stress_level"] ?? "Low").toString(),
      stressScore: (json["stress_score"] is num) ? (json["stress_score"] as num).toInt() : 0,
      stressProbability: (json["stress_probability"] is num)
          ? (json["stress_probability"] as num).toDouble()
          : 0.0,
      consecutiveHighDays: (json["consecutive_high_days"] is num)
          ? (json["consecutive_high_days"] as num).toInt()
          : 0,
      escalationTriggered: (json["escalation_triggered"] == true),
      scoreDate: tryParse(json["score_date"]?.toString())?.toLocal(),
      computedAt: tryParse(json["computed_at"]?.toString())?.toLocal(),
    );
  }
}

class RecommendationDto {
  final String? id;
  final String? level;
  final String? category;
  final String? title;
  final String? description;

  RecommendationDto({
    required this.id,
    required this.level,
    required this.category,
    required this.title,
    required this.description,
  });

  factory RecommendationDto.fromJson(Map<String, dynamic> json) {
    return RecommendationDto(
      id: json["_id"]?.toString(),
      level: json["level"]?.toString(),
      category: json["category"]?.toString(),
      title: json["title"]?.toString(),
      description: json["description"]?.toString(),
    );
  }
}
