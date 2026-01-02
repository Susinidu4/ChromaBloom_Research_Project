import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ChildRoutinePlanService {
  static final String _base = ApiConfig.baseUrl;

  // GET or CREATE starter plan (5 easy) for 14-day cycle
  static Future<Map<String, dynamic>> getOrCreateStarterPlan({
    required String caregiverId,
    required String childId,
    required String ageGroup,
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/systemActivities/getOrCreateStarterSystemActivity",
    );

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "caregiverId": caregiverId,
        "childId": childId,
        "ageGroup": ageGroup,
      }),
    );

    //debugPrint("getOrCreateStarterPlan response: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      try {
        final parsed = jsonDecode(res.body);
        throw Exception(parsed["error"] ?? parsed["message"] ?? res.body);
      } catch (_) {
        throw Exception(res.body);
      }
    }
  }

  // Save a routine run (one day) for a child's plan.
  static Future<Map<String, dynamic>> saveRoutineRun({
    required String caregiverId,
    required String childId,
    required String planMongoId,
    required String activityMongoId,
    required DateTime runDate,
    required List<Map<String, dynamic>> stepsProgress,
    required int completedDurationMinutes,
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/systemActivities/updateSystemActivityProgress",
    );

final dateStr  =
    "${runDate.year.toString().padLeft(4, '0')}-"
    "${runDate.month.toString().padLeft(2, '0')}-"
    "${runDate.day.toString().padLeft(2, '0')}";

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "caregiverId": caregiverId,
        "childId": childId,
        "planId": planMongoId,
        "activityId": activityMongoId,
        "run_date": dateStr,
        "steps_progress": stepsProgress,
        "completed_duration_minutes": completedDurationMinutes,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      final parsed = jsonDecode(res.body);
      throw Exception(parsed["error"] ?? parsed["message"] ?? res.body);
    }
  }

  // GET routine run progress by planId and activityId
  static Future<Map<String, dynamic>?> getRoutineRunProgress({
    required String caregiverId,
    required String childId,
    required String planMongoId,
    required String activityMongoId,
    required DateTime runDate,
  }) async {

    final dateStr  =
    "${runDate.year.toString().padLeft(4, '0')}-"
    "${runDate.month.toString().padLeft(2, '0')}-"
    "${runDate.day.toString().padLeft(2, '0')}";

    final uri = Uri.parse(
      "$_base/chromabloom/systemActivities/getRoutineRunProgress/$planMongoId/$activityMongoId",
    ).replace(queryParameters: {"caregiverId": caregiverId, "childId": childId, "run_date": dateStr });

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return decoded["data"] == null
          ? null
          : (decoded["data"] as Map<String, dynamic>);
    } else {
      try {
        final parsed = jsonDecode(res.body);
        throw Exception(parsed["error"] ?? parsed["message"] ?? res.body);
      } catch (_) {
        throw Exception(res.body);
      }
    }
  }
}
