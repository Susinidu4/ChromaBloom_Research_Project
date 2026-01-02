// lib/services/user_services/child_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ChildApi {
  static Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      return {'message': 'Unexpected server response'};
    }
  }

  static Exception _err(http.Response response) {
    final data = _decodeBody(response);
    return Exception(data['message'] ?? 'Request failed (${response.statusCode})');
  }

  /// CREATE CHILD
  static Future<Map<String, dynamic>> createChild({
    required String childName,
    required String dateOfBirth, // ISO string from Flutter (e.g., 2025-12-20)
    required String gender,
    double? heightCm,
    double? weightKg,
    String? downSyndromeType,
    String? downSyndromeConfirmedBy,

    // ✅ backend requires BOTH caregiver & therapist
    required String caregiverId, // "p-0001"
    required String therapistId, // "t-0001"

    // health flags
    required bool hasHeartIssues,
    required bool hasThyroidIssues,
    required bool hasHearingProblems,
    required bool hasVisionProblems,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chromabloom/children');

    final otherHealthConditions = {
      'heartIssues': hasHeartIssues,
      'thyroid': hasThyroidIssues,
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
      'caregiver': caregiverId,
      'therapist': therapistId,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return _decodeBody(response); // { message, child }
    }
    throw _err(response);
  }

  /// GET ALL CHILDREN
  static Future<List<dynamic>> getAllChildren() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chromabloom/children');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      return [];
    }
    throw _err(response);
  }

  /// GET CHILD BY ID (c-0001)
  static Future<Map<String, dynamic>> getChildById(String childId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chromabloom/children/$childId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return _decodeBody(response);
    }
    throw _err(response);
  }

  /// GET CHILDREN BY CAREGIVER ID (p-0001)
  static Future<List<dynamic>> getChildrenByCaregiver(String caregiverId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/chromabloom/children/caregiver/$caregiverId',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      return [];
    }
    throw _err(response);
  }

  /// UPDATE CHILD (PUT /chromabloom/children/c-0001)
  /// Pass only fields you want to update.
  static Future<Map<String, dynamic>> updateChild({
    required String childId, // "c-0001"
    String? childName,
    String? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? downSyndromeType,
    String? downSyndromeConfirmedBy,
    Map<String, dynamic>? otherHealthConditions,
    String? caregiverId,
    String? therapistId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chromabloom/children/$childId');

    final Map<String, dynamic> body = {};
    if (childName != null) body['childName'] = childName;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (gender != null) body['gender'] = gender;
    if (heightCm != null) body['heightCm'] = heightCm;
    if (weightKg != null) body['weightKg'] = weightKg;
    if (downSyndromeType != null) body['downSyndromeType'] = downSyndromeType;
    if (downSyndromeConfirmedBy != null) {
      body['downSyndromeConfirmedBy'] = downSyndromeConfirmedBy;
    }
    if (otherHealthConditions != null) {
      body['otherHealthConditions'] = otherHealthConditions;
    }
    if (caregiverId != null) body['caregiver'] = caregiverId;
    if (therapistId != null) body['therapist'] = therapistId;

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return _decodeBody(response); // { message, child }
    }
    throw _err(response);
  }

  /// DELETE CHILD
  static Future<Map<String, dynamic>> deleteChild(String childId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chromabloom/children/$childId');

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      return _decodeBody(response); // { message: "Child deleted successfully" }
    }
    throw _err(response);
  }
}
