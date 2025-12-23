import 'dart:convert';
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
    required List<Map<String, dynamic>> stepsProgress,
    required int completedDurationMinutes,
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/systemActivities/updateSystemActivityProgress",
    );

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "caregiverId": caregiverId,
        "childId": childId,
        "planId": planMongoId,
        "activityId": activityMongoId,
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
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/systemActivities/getRoutineRunProgress/$planMongoId/$activityMongoId",
    ).replace(queryParameters: {"caregiverId": caregiverId, "childId": childId});

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
