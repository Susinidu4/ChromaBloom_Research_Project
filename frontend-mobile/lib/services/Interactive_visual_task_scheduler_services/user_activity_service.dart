import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class UserActivityService {
  static const String _baseUrl = "http://10.0.2.2:5000";
  static const String _createPath =
      "/chromabloom/userActivities/createUserActivity";

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
    final uri = Uri.parse("$_baseUrl$_createPath");
    final request = http.MultipartRequest("POST", uri);

    request.fields["created_by"] = createdBy;
    request.fields["title"] = title;
    request.fields["description"] = description;
    request.fields["age_group"] = ageGroup;
    request.fields["development_area"] = developmentArea;
    request.fields["scheduled_date"] = scheduledDate.toIso8601String();
    request.fields["estimated_duration_minutes"] =
        estimatedDurationMinutes.toString();
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
}
