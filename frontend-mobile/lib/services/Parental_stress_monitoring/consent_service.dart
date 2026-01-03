import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ConsentService {
  static final String _base = ApiConfig.baseUrl;

  Future<Map<String, dynamic>?> getConsent(String caregiverId) async {
    final uri = Uri.parse('$_base/chromabloom/consent/$caregiverId');
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET consent failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['consent'] as Map<String, dynamic>?;
  }

  Future<void> saveDecision({
    required String caregiverId,
    required String decision, // allow | cancel
  }) async {
    final uri = Uri.parse('$_base/chromabloom/consent/createConsent');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'caregiverId': caregiverId, 'decision': decision}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('POST consent failed: ${res.statusCode} ${res.body}');
    }
  }
}
