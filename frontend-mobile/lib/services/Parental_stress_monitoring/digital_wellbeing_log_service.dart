import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class DigitalWellbeingService {
  static final String _base = ApiConfig.baseUrl;

  Future<void> createLog(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_base/chromabloom/digitalWellbeingLog/create');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Create wellbeing log failed: ${res.statusCode} ${res.body}');
    }
  }
}
