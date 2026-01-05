import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../api_config.dart';

class CaregiverApi {
  static const _base = '${ApiConfig.baseUrl}/chromabloom/caregivers';

  // -------------------------
  // LOGIN
  // -------------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_base/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Login failed');
  }

  // -------------------------
  // REGISTER (NO IMAGE)
  // -------------------------
  static Future<Map<String, dynamic>> registerCaregiver({
    required String fullName,
    required String dob, // "YYYY-MM-DD"
    required String gender,
    required int numberOfChildren,
    required String mobile,
    required String email,
    required String address,
    required String password,
  }) async {
    final uri = Uri.parse('$_base/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'dob': dob,
        'gender': gender,
        'child_count': numberOfChildren,
        'phone': mobile,
        'email': email,
        'address': address,
        'password': password,
      }),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 201 || response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Caregiver registration failed');
  }

  // -------------------------
  // GET CAREGIVER BY ID
  // -------------------------
  static Future<Map<String, dynamic>> getById({
    required String caregiverId, // p-0001
    String? token,
  }) async {
    final uri = Uri.parse('$_base/$caregiverId');

    final response = await http.get(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Failed to fetch caregiver');
  }

  // -------------------------
  // UPDATE CAREGIVER (WITH OPTIONAL IMAGE BYTES)
  // backend: PUT /chromabloom/caregivers/:id
  // form-data: fields + profile_pic(file)
  // -------------------------
  static Future<Map<String, dynamic>> updateCaregiver({
    required String caregiverId, // p-0001
    String? token,

    // optional fields
    String? fullName,
    String? dob, // "YYYY-MM-DD"
    String? gender,
    int? childCount,
    String? phone,
    String? email,
    String? address,
    String? password,

    // optional image bytes (WORKS on web/mobile/desktop)
    Uint8List? profilePicBytes,
    String? profilePicFilename,
  }) async {
    final uri = Uri.parse('$_base/$caregiverId');
    final request = http.MultipartRequest('PUT', uri);

    // headers
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // add fields only if not null (partial update)
    void addField(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        request.fields[key] = value.trim();
      }
    }

    addField('full_name', fullName);
    addField('dob', dob);
    addField('gender', gender);
    if (childCount != null) request.fields['child_count'] = childCount.toString();
    addField('phone', phone);
    addField('email', email);
    addField('address', address);
    addField('password', password);

    // image (MUST be "profile_pic")
    if (profilePicBytes != null && profilePicBytes.isNotEmpty) {
      final filename = (profilePicFilename == null || profilePicFilename.trim().isEmpty)
          ? "profile.jpg"
          : profilePicFilename.trim();

      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_pic',
          profilePicBytes,
          filename: filename,
          contentType: MediaType('image', _guessImageSubtype(filename)),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    final data = _decodeBody(response);

    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Caregiver update failed');
  }

  // Helpers
  static Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'message': 'Unexpected server response'};
    } catch (_) {
      return {'message': 'Unexpected server response'};
    }
  }

  static String _guessImageSubtype(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.gif')) return 'gif';
    return 'jpeg';
  }
}
