import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_services/caregiver_api.dart';

class SessionProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _caregiver;

  String? get token => _token;
  Map<String, dynamic>? get caregiver => _caregiver;

  bool get isLoggedIn => _token != null && _caregiver != null;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("auth_token");

    final caregiverStr = prefs.getString("caregiver_json");
    if (caregiverStr != null) {
      _caregiver = jsonDecode(caregiverStr) as Map<String, dynamic>;
    }

    notifyListeners();
  }

  Future<void> setSession({
    required String token,
    required Map<String, dynamic> caregiver,
  }) async {
    _token = token;
    _caregiver = caregiver;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    await prefs.setString("caregiver_json", jsonEncode(caregiver));

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _caregiver = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("caregiver_json");

    notifyListeners();
  }

  // ✅ Update caregiver + persist + refresh UI (supports image bytes)
  Future<Map<String, dynamic>> updateCaregiverProfile({
    String? fullName,
    String? dob, // "YYYY-MM-DD"
    String? gender,
    int? childCount,
    String? phone,
    String? email,
    String? address,
    String? password,

    Uint8List? profilePicBytes,
    String? profilePicFilename,
  }) async {
    if (_caregiver == null) {
      throw Exception("No caregiver session found");
    }

    final caregiverId = (_caregiver!['_id'] ?? _caregiver!['id'] ?? '').toString();
    if (caregiverId.isEmpty) {
      throw Exception("Caregiver ID not found in session");
    }

    final result = await CaregiverApi.updateCaregiver(
      caregiverId: caregiverId,
      token: _token,
      fullName: fullName,
      dob: dob,
      gender: gender,
      childCount: childCount,
      phone: phone,
      email: email,
      address: address,
      password: password,
      profilePicBytes: profilePicBytes,
      profilePicFilename: profilePicFilename,
    );

    // backend response shape: { message, caregiver: {...} }
    final updatedCaregiver =
        (result['caregiver'] is Map<String, dynamic>) ? result['caregiver'] as Map<String, dynamic> : null;

    if (updatedCaregiver != null) {
      _caregiver = updatedCaregiver;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("caregiver_json", jsonEncode(updatedCaregiver));

      notifyListeners();
    }

    return result;
  }
}
