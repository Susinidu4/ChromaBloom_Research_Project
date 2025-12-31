import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/Gemified/drawing_ml_api_service.dart';

class DrawingPredictApiPage extends StatefulWidget {
  const DrawingPredictApiPage({super.key});

  @override
  State<DrawingPredictApiPage> createState() => _DrawingPredictApiPageState();
}

class _DrawingPredictApiPageState extends State<DrawingPredictApiPage> {
  final _picker = ImagePicker();

  // ✅ UPDATE THIS BASE URL
  // Emulator: "http://10.0.2.2:8000"
  // Phone/Chrome: "http://192.168.1.5:8000" (your PC IP)
  final MlApiService _api = MlApiService(baseUrl: "http://localhost:8000");

  Uint8List? _imageBytes;
  bool _loading = false;

  Map<String, dynamic>? _top1;
  List<dynamic> _top3 = [];

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source);
    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _top1 = null;
      _top3 = [];
    });
  }

  Future<void> _predict() async {
    if (_imageBytes == null) return;

    setState(() => _loading = true);
    try {
      final res = await _api.predict(_imageBytes!);

      setState(() {
        _top1 = (res["top1"] as Map?)?.cast<String, dynamic>();
        _top3 = (res["top3"] as List?) ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prediction failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _prettyLabel(String label) {
    // optional: "a.apple" -> "Apple"
    final parts = label.split('.');
    final last = parts.isNotEmpty ? parts.last : label;
    if (last.isEmpty) return label;
    return last[0].toUpperCase() + last.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drawing Prediction (API)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image preview
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: _imageBytes == null
                  ? const Center(child: Text("Select an image to predict"))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    ),
            ),

            const SizedBox(height: 12),

            // Pick buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Predict button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_imageBytes == null || _loading) ? null : _predict,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Predict"),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: ListView(
                children: [
                  if (_top1 != null) ...[
                    const Text(
                      "Top Result",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _Top1Card(
                      label: _prettyLabel(_top1!["label"]?.toString() ?? "-"),
                      confidence: (_top1!["confidence"] as num?)?.toDouble() ?? 0,
                    ),
                    const SizedBox(height: 18),
                  ],

                  if (_top3.isNotEmpty) ...[
                    const Text(
                      "Top 3 Predictions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._top3.map((item) {
                      final map = (item as Map).cast<String, dynamic>();
                      final label = _prettyLabel(map["label"]?.toString() ?? "-");
                      final conf = (map["confidence"] as num?)?.toDouble() ?? 0;

                      return _ResultTile(label: label, confidence: conf);
                    }),
                  ],

                  if (_top1 == null && _top3.isEmpty)
                    const Text("No predictions yet."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Top1Card extends StatelessWidget {
  final String label;
  final double confidence;

  const _Top1Card({required this.label, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            "${confidence.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final double confidence;

  const _ResultTile({required this.label, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final p = (confidence.clamp(0, 100) / 100.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
              Text("${confidence.toStringAsFixed(1)}%"),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: p),
        ],
      ),
    );
  }
}
