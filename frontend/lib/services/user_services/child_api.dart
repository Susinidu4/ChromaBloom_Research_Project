// lib/services/user_services/child_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ChildApi {
  static Future<Map<String, dynamic>> createChild({
    required String childName,
    required String dateOfBirth,
    required String gender,
    double? heightCm,
    double? weightKg,
    String? downSyndromeType,
    String? downSyndromeConfirmedBy,
    required String caregiverId,
    String? therapistId,
    required bool hasHeartIssues,
    required bool hasThyroidIssues,
    required bool hasHearingProblems,
    required bool hasVisionProblems,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chromabloom/children');

    // 👇 KEYS UPDATED TO MATCH MONGOOSE SCHEMA
    final otherHealthConditions = {
      'heartIssues': hasHeartIssues,
      'thyroid': hasThyroidIssues,        // was `thyroidIssues`
      'hearingProblems': hasHearingProblems,
      'visionProblems': hasVisionProblems,
    };

    final body = {
      'childName': childName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'downSyndromeType': downSyndromeType,
      'downSyndromeConfirmedBy': downSyndromeConfirmedBy,
      'otherHealthConditions': otherHealthConditions,
      'caregiver': caregiverId,   // e.g. "p-0001"
      'therapist': therapistId,   // e.g. "t-0001" or null
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // { child: {...}, message: 'Child registered successfully' }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Child registration failed');
    }
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': 'Unexpected server response'};
    }
  }
}
