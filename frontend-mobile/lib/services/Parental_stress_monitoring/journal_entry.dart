import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

/// services/Parental_stress_monitoring/journal_entry.dart
class JournalEntryService {
  static final String _base = ApiConfig.baseUrl;

  static const String _prefix = "/chromabloom/journalEntries";

  static Uri _uri(String path) => Uri.parse("$_base$_prefix$path");

  /// POST: /createJournal
  /// Body: { caregiver_ID, mood, moodEmoji, text }
  Future<Map<String, dynamic>> createJournalEntry({
    required String caregiverId,
    required String mood,
    required String moodEmoji,
    required String text,
  }) async {
    final res = await http.post(
      _uri("/createJournal"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "caregiver_ID": caregiverId,
        "mood": mood,
        "moodEmoji": moodEmoji,
        "text": text,
      }),
    );

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode == 200 || res.statusCode == 201) {
      return decoded is Map<String, dynamic> ? decoded : {"data": decoded};
    }

    final errorMsg = (decoded is Map && decoded["error"] != null)
        ? decoded["error"].toString()
        : (decoded is Map && decoded["message"] != null)
        ? decoded["message"].toString()
        : res.body;

    throw Exception("Create journal failed (${res.statusCode}): $errorMsg");
  }

   // -------- GET journals by caregiver --------
  Future<List<Map<String, dynamic>>> getJournalsByCaregiver(String caregiverId) async {
    final res = await http.get(_uri('/getJournal/$caregiverId'));

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode == 200) {
      final data = (decoded is Map && decoded['data'] is List) ? decoded['data'] as List : [];
      return data.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }

    final msg = (decoded is Map && decoded['error'] != null)
        ? decoded['error'].toString()
        : res.body;

    throw Exception('Get journals failed (${res.statusCode}): $msg');
  }

  // -------- DELETE journal by entry id --------
  Future<void> deleteJournal(String entryId) async {
    final res = await http.delete(_uri('/deleteJournal/$entryId'));

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode == 200) return;

    final msg = (decoded is Map && decoded['error'] != null)
        ? decoded['error'].toString()
        : res.body;

    throw Exception('Delete failed (${res.statusCode}): $msg');
  }

  // -------- UPDATE journal by entry id --------
  Future<Map<String, dynamic>> updateJournal({
    required String entryId,
    String? mood,
    String? moodEmoji,
    String? text,
  }) async {
    final payload = <String, dynamic>{};
    if (mood != null) payload['mood'] = mood;
    if (moodEmoji != null) payload['moodEmoji'] = moodEmoji;
    if (text != null) payload['text'] = text;

    final res = await http.put(
      _uri('/updateJournal/$entryId'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode == 200) {
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }

    final msg = (decoded is Map && decoded['error'] != null)
        ? decoded['error'].toString()
        : res.body;

    throw Exception('Update failed (${res.statusCode}): $msg');
  }
}
