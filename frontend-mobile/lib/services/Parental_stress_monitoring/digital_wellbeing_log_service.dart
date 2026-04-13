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

 
   // get logs by caregiver id 
 Future<List<Map<String, dynamic>>> getLogsByCaregiverId(String caregiverId) async {
  final uri = Uri.parse('$_base/chromabloom/digitalWellbeingLog/caregiver/$caregiverId');

  final res = await http.get(uri);

  if (res.statusCode >= 200 && res.statusCode < 300) {
    final decoded = jsonDecode(res.body);

    // API returns: { "logs": [ ... ] }
    final logsRaw = (decoded is Map && decoded["logs"] is List)
        ? decoded["logs"] as List
        : <dynamic>[];

    return logsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } else {
    throw Exception('Get wellbeing logs failed: ${res.statusCode} ${res.body}');
  }
}

}
