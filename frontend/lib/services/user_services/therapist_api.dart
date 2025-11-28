// lib/services/therapist_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class TherapistApi {
  static final String _base = ApiConfig.baseUrl;

  /// POST /api/therapists/register
  static Future<Map<String, dynamic>> registerTherapist(
      Map<String, dynamic> data) async {
    final url = Uri.parse("$_base/api/therapists/register");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode == 201 || res.statusCode == 200) {
      return {
        "success": true,
        "data": body,
      };
    } else {
      return {
        "success": false,
        "message": body["message"] ?? "Registration failed",
      };
    }
  }

  /// POST /api/therapists/login
  static Future<Map<String, dynamic>> loginTherapist(
      String email, String password) async {
    final url = Uri.parse("$_base/api/therapists/login");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return {
        "success": true,
        "data": body,
      };
    } else {
      return {
        "success": false,
        "message": body["message"] ?? "Login failed",
      };
    }
  }
}
