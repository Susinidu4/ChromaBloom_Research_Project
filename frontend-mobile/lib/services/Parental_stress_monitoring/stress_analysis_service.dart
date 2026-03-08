import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';

class StressAnalysisService {
  static final String _base = ApiConfig.baseUrl;

  // Compute stress and recommendation for a caregiver
  static Future<StressComputeResponse> compute({
    required String caregiverId,
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/stressAnalysis/compute/$caregiverId",
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Compute failed (${res.statusCode}): ${res.body}");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StressComputeResponse.fromJson(data);
  }

  // get stress history by caregiverId
  static Future<List<StressDto>> getHistoryByCaregiver({
    required String caregiverId,
  }) async {
    final uri = Uri.parse("$_base/chromabloom/stressAnalysis/$caregiverId");

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Get history failed (${res.statusCode}): ${res.body}");
    }

    final decoded = jsonDecode(res.body);

    // Expected:
    // { "scores": [ {..}, {..} ] }
    if (decoded is Map<String, dynamic>) {
      final list = (decoded["scores"] as List?) ?? [];
      return list
          .map((e) => StressDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // fallback: if backend ever returns List directly
    if (decoded is List) {
      return decoded
          .map((e) => StressDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Unexpected stress history response shape: ${res.body}");
  }

  // Get last N stress score history (default 10)

  static Future<StressHistoryResponse> getHistory({
    required String caregiverId,
    int limit = 10,
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/stressAnalysis/history/$caregiverId",
    ).replace(queryParameters: {"limit": "$limit"});
    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("History failed (${res.statusCode}): ${res.body}");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return StressHistoryResponse.fromJson(data);
  }
}

class StressComputeResponse {
  final StressDto stress;
  final RecommendationDto? recommendation;

  StressComputeResponse({required this.stress, required this.recommendation});

  factory StressComputeResponse.fromJson(Map<String, dynamic> json) {
    return StressComputeResponse(
      stress: StressDto.fromJson(
        (json["stress"] ?? {}) as Map<String, dynamic>,
      ),
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
  final List<double>? raw;
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
    this.raw,
  });

  factory StressDto.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? s) =>
        (s == null || s.isEmpty) ? null : DateTime.tryParse(s);

    return StressDto(
      stressLevel: (json["stress_level"] ?? "Low").toString(),
      stressScore: (json["stress_score"] is num)
          ? (json["stress_score"] as num).toInt()
          : 0,
      stressProbability: (json["stress_probability"] is num)
          ? (json["stress_probability"] as num).toDouble()
          : 0.0,
      raw: (json['raw'] as List?)?.map((e) => (e as num).toDouble()).toList(),
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

/* ===================== HISTORY DTOs ===================== */

class StressHistoryResponse {
  final String caregiverId;
  final int count;
  final List<StressHistoryItem> items;

  StressHistoryResponse({
    required this.caregiverId,
    required this.count,
    required this.items,
  });

  factory StressHistoryResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json["items"] as List?) ?? [];
    return StressHistoryResponse(
      caregiverId: (json["caregiverId"] ?? "").toString(),
      count: (json["count"] is num)
          ? (json["count"] as num).toInt()
          : raw.length,
      items: raw
          .map((e) => StressHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StressHistoryItem {
  final String stressLevel;
  final double stressProbability;
  final int? consecutiveHighDays;
  final bool? escalationTriggered;
  final DateTime? scoreDate;
  final DateTime? computedAt;

  StressHistoryItem({
    required this.stressLevel,
    required this.stressProbability,
    this.consecutiveHighDays,
    this.escalationTriggered,
    this.scoreDate,
    this.computedAt,
  });

  factory StressHistoryItem.fromJson(Map<String, dynamic> json) {
    DateTime? tryParse(String? s) =>
        (s == null || s.isEmpty) ? null : DateTime.tryParse(s);

    return StressHistoryItem(
      stressLevel: (json["stress_level"] ?? "Low").toString(),
      stressProbability: (json["stress_probability"] is num)
          ? (json["stress_probability"] as num).toDouble()
          : 0.0,
      consecutiveHighDays: (json["consecutive_high_days"] is num)
          ? (json["consecutive_high_days"] as num).toInt()
          : null,
      escalationTriggered: json["escalation_triggered"] == null
          ? null
          : (json["escalation_triggered"] == true),
      scoreDate: tryParse(json["score_date"]?.toString())?.toLocal(),
      computedAt: tryParse(json["computed_at"]?.toString())?.toLocal(),
    );
  }
}
