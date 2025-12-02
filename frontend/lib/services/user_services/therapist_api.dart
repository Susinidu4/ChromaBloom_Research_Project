// lib/services/user_services/therapist_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class TherapistApi {
  static final String _base = ApiConfig.baseUrl;

  // =========================
  // Helpers
  // =========================

  static Map<String, dynamic> _handleResponse(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      body = {"message": "Unexpected server response"};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return {
        "success": true,
        "data": body,
      };
    } else {
      return {
        "success": false,
        "message": body["message"] ?? "Request failed (${res.statusCode})",
        "data": body,
      };
    }
  }

  // =========================
  // REGISTER THERAPIST
  // POST /chromabloom/therapists/register
  // Body: JSON (+ optional base64 profile picture)
  // =========================

  static Future<Map<String, dynamic>> registerTherapist(
      Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("$_base/chromabloom/therapists/register");

      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      return _handleResponse(res);
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  // =========================
  // LOGIN THERAPIST
  // POST /chromabloom/therapists/login
  // =========================

  static Future<Map<String, dynamic>> loginTherapist(
      String email, String password) async {
    try {
      final url = Uri.parse("$_base/chromabloom/therapists/login");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      return _handleResponse(res);
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  // =========================
  // GET ALL THERAPISTS
  // GET /chromabloom/therapists
  // =========================

  static Future<Map<String, dynamic>> getAllTherapists() async {
    try {
      final url = Uri.parse("$_base/chromabloom/therapists");

      final res = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      // Backend returns an array
      if (res.statusCode >= 200 && res.statusCode < 300) {
        List<dynamic> list;
        try {
          list = jsonDecode(res.body) as List<dynamic>;
        } catch (_) {
          list = [];
        }
        return {
          "success": true,
          "data": list,
        };
      } else {
        Map<String, dynamic> body;
        try {
          body = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {
          body = {};
        }
        return {
          "success": false,
          "message": body["message"] ?? "Failed to fetch therapists",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  // =========================
  // GET THERAPIST BY ID (t-0001)
  // GET /chromabloom/therapists/:id
  // =========================

  static Future<Map<String, dynamic>> getTherapistById(String id) async {
    try {
      final url = Uri.parse("$_base/chromabloom/therapists/$id");

      final res = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      return _handleResponse(res);
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  // =========================
  // UPDATE THERAPIST
  // PUT /chromabloom/therapists/:id
  // Body: JSON (+ optional profile_picture_base64)
  // =========================

  static Future<Map<String, dynamic>> updateTherapist(
      String id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("$_base/chromabloom/therapists/$id");

      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      return _handleResponse(res);
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  // =========================
  // DELETE THERAPIST
  // DELETE /chromabloom/therapists/:id
  // =========================

  static Future<Map<String, dynamic>> deleteTherapist(String id) async {
    try {
      final url = Uri.parse("$_base/chromabloom/therapists/$id");

      final res = await http.delete(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      return _handleResponse(res);
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }

  // =========================
  // Helper: build dropdown labels
  // => "Dr. A (Speech Therapist) - t-0001"
  // =========================

  static Future<List<String>> getTherapistDropdownItems() async {
    final res = await getAllTherapists();
    if (!res["success"]) return [];

    final List<dynamic> list = res["data"] as List<dynamic>;

    return list.map((t) {
      final map = t as Map<String, dynamic>;

      final name =
          (map["full_name"] ?? map["fullName"] ?? "Unknown").toString();

      final specialization = (map["specialization"] ??
              map["speciality"] ??
              map["therapyType"] ??
              "Therapist")
          .toString();

      final id = (map["_id"] ?? map["id"] ?? "").toString();

      if (id.isNotEmpty) {
        // Name + specialization + id (still parsable by " - ")
        return "$name ($specialization) - $id";
      } else {
        // Fallback if no id
        return "$name ($specialization)";
      }
    }).toList();
  }
}
