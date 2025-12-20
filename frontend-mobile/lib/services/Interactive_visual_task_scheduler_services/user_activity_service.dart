import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import '../api_config.dart';

class UserActivityService {
  static final String _base = ApiConfig.baseUrl;

  static const String _createPath =
      "/chromabloom/userActivities/createUserActivity";

  static const String _getByDatePath = 
      "/chromabloom/userActivities/getByDate";

  // CREATE USER ACTIVITY
  static Future<Map<String, dynamic>> createUserActivity({
    required String createdBy,
    required String title,
    required String description,
    required String ageGroup,
    required String developmentArea,
    required DateTime scheduledDate,
    required int estimatedDurationMinutes,
    required String difficultyLevel,
    required List<Map<String, dynamic>> steps,
    File? mediaImage,
  }) async {
    final uri = Uri.parse("$_base$_createPath");
    final request = http.MultipartRequest("POST", uri);

    request.fields["created_by"] = createdBy;
    request.fields["title"] = title;
    request.fields["description"] = description;
    request.fields["age_group"] = ageGroup;
    request.fields["development_area"] = developmentArea;
    request.fields["scheduled_date"] = scheduledDate.toIso8601String();
    request.fields["estimated_duration_minutes"] = estimatedDurationMinutes
        .toString();
    request.fields["difficulty_level"] = difficultyLevel;
    request.fields["steps"] = jsonEncode(steps);

    if (mediaImage != null) {
      final mimeType = lookupMimeType(mediaImage.path) ?? "image/jpeg";
      final parts = mimeType.split("/"); // ["image","png"] etc.

      request.files.add(
        await http.MultipartFile.fromPath(
          "media_image",
          mediaImage.path,
          filename: p.basename(mediaImage.path),
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      try {
        final parsed = jsonDecode(response.body);
        throw Exception(parsed["error"] ?? parsed["message"] ?? response.body);
      } catch (_) {
        throw Exception(response.body);
      }
    }
  }

  // FETCH ACTIVITIES FOR A CAREGIVER + DATE
  static Future<List<Map<String, dynamic>>> getByDate({
    required String caregiverId,
    required DateTime date,
  }) async {
    final uri = Uri.parse("$_base/chromabloom/userActivities/getByDate");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "caregiverId": caregiverId,
        "date": date.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (decoded["data"] as List).cast<Map<String, dynamic>>();
      return list;
    } else {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          decoded["error"] ?? decoded["message"] ?? response.body,
        );
      } catch (_) {
        throw Exception(response.body);
      }
    }
  }

  // DELETE USER ACTIVITY
  static Future<Map<String, dynamic>> deleteUserActivity({
    required String mongoId, // ✅ must be _id
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/userActivities/deleteUserActivity/$mongoId",
    );

    final res = await http.delete(uri);

    if (res.statusCode == 200) {
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

  // UPDATE USER ACTIVITY
  static Future<Map<String, dynamic>> updateUserActivity({
    required String activityId,
    required String createdBy,
    required String title,
    required String description,
    required String ageGroup,
    required String developmentArea,
    required DateTime scheduledDate,
    required int estimatedDurationMinutes,
    required String difficultyLevel,
    required List<Map<String, dynamic>> steps,
    String? mediaImageBase64, // optional
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/userActivities/updateUserActivity/$activityId",
    );

    final body = {
      "created_by": createdBy,
      "title": title,
      "description": description,
      "age_group": ageGroup,
      "development_area": developmentArea,
      "steps": steps,
      "scheduled_date": scheduledDate.toIso8601String(),
      "estimated_duration_minutes": estimatedDurationMinutes,
      "difficulty_level": difficultyLevel,
      if (mediaImageBase64 != null) "media_image_base64": mediaImageBase64,
    };

    final res = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
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

  // PATCH update progress
  static Future<Map<String, dynamic>> updateUserActivityProgress({
    required String mongoId,
    required List<Map<String, dynamic>> steps,
    required int completedDurationMinutes,
  }) async {
    final uri = Uri.parse(
      "$_base/chromabloom/userActivities/updateProgress/$mongoId",
    );

    final res = await http.patch(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "steps": steps,
        "completed_duration_minutes": completedDurationMinutes,
      }),
    );

    if (res.statusCode == 200) {
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
}
