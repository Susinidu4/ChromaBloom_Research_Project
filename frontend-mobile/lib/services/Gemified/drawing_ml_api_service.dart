import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class MlApiService {
  // ✅ Change this depending on device:
  // Android emulator: http://10.0.2.2:8000
  // Real phone / Chrome: http://<YOUR_PC_IP>:8000  (example: http://192.168.1.5:8000)
  final String baseUrl;

  MlApiService({required this.baseUrl});

  Future<Map<String, dynamic>> predict(Uint8List bytes) async {
    final uri = Uri.parse('$baseUrl/predict');

    final req = http.MultipartRequest('POST', uri);
    req.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'image.png',
    ));

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('API error ${streamed.statusCode}: $body');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid API response');
    }
    return decoded;
  }
}
