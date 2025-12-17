// lib/services/caregiver_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class CaregiverApi {
  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chromabloom/caregivers/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return data; // expect { caregiver, token, message, ... }
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  // REGISTER CAREGIVER
  static Future<Map<String, dynamic>> registerCaregiver({
    required String fullName,
    required String dob,
    required String gender,
    required int numberOfChildren,
    required String mobile,
    required String email,
    required String address,

    // TODO: you should collect password from UI later;
    // for now you can pass a default or add a password field.
    required String password,
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/chromabloom/caregivers/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        // adjust keys to match your caregiver.model.js
        'fullName': fullName,
        'dateOfBirth': dob,
        'gender': gender,
        'numberOfChildren': numberOfChildren,
        'phoneNumber': mobile,
        'email': email,
        'address': address,
        'password': password,
      }),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data; // expect { caregiver: {...}, message: '...' }
    } else {
      throw Exception(data['message'] ?? 'Caregiver registration failed');
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
