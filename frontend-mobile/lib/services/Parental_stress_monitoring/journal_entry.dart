import 'dart:convert';
import 'package:http/http.dart' as http;

class JournalEntryService {
  final String baseUrl;
  static const String _baseUrl = "http://10.0.2.2:5000";
  // static const String _baseUrl = "http://localhost:5000";

  const JournalEntryService({required this.baseUrl});

  /// POST: /createJournal
  /// Body: { caregiver_ID, mood, moodEmoji, text }
  Future<Map<String, dynamic>> createJournalEntry({
    required String caregiverId,
    required String mood, // "happy"
    required String moodEmoji, // "😃"
    required String text,
  }) async {
    final uri = Uri.parse("$baseUrl/createJournal");

    final payload = {
      "caregiver_ID": caregiverId,
      "mood": mood,
      "moodEmoji": moodEmoji,
      "text": text,
    };

    final res = await http.post(
      uri,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    final body = res.body.trim();
    final decoded = body.isNotEmpty ? jsonDecode(body) : null;

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {"data": decoded};
    }

    // return meaningful error
    final msg = (decoded is Map && decoded["error"] != null)
        ? decoded["error"].toString()
        : body;
    throw Exception("Create journal failed (${res.statusCode}): $msg");
  }
}
