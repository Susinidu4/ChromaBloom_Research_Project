import 'dart:io';

import 'package:flutter/material.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';
import '../../../services/Gemified/drawing_predict_service.dart'; // ✅ your service file

class LessonCompletePage extends StatefulWidget {
  const LessonCompletePage({
    super.key,
    required this.imageFile,
    required this.previousCorrectness, // 0.0 - 1.0
  });

  final File imageFile;
  final double previousCorrectness;

  static const Color pageBg = Color(0xFFF5ECEC);

  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color bubbleBg = Color(0xFFF8F2E8);
  static const Color bubbleIcon = Color(0xFFB0896E);

  static const Color labelColor = Color(0xFF000000);
  static const Color track = Color(0xFFD8D1C7);
  static const Color fill = Color(0xFFB89A76);

  @override
  State<LessonCompletePage> createState() => _LessonCompletePageState();
}

class _LessonCompletePageState extends State<LessonCompletePage> {
  bool _loading = true;

  String _predictedLabel = "-";
  double _confidencePercent = 0; // 0 - 100
  double _correctness = 0; // 0.0 - 1.0
  double _improvement = 0; // 0.0 - 1.0

  @override
  void initState() {
    super.initState();
    _predictOnLoad();
  }

  Future<void> _predictOnLoad() async {
    setState(() => _loading = true);

    try {
      // ✅ Node returns: { message, data: { top1, top3 } }
      final res = await DrawingPredictService.predictDrawing(widget.imageFile);

// ✅ DIRECT: { message, top1 }
final top1 = (res["top1"] as Map?)?.cast<String, dynamic>();

final rawLabel = top1?["label"]?.toString() ?? "-";
final conf = (top1?["confidence"] as num?)?.toDouble() ?? 0.0;

final pretty = _prettyLabel(rawLabel);

final correctness = (conf.clamp(0, 100) / 100.0);
final prev = widget.previousCorrectness.clamp(0.0, 1.0);
final improvement = (correctness - prev).clamp(0.0, 1.0);

if (!mounted) return;
setState(() {
  _predictedLabel = pretty;          // ✅ label shown
  _confidencePercent = conf;         // ✅ confidence shown
  _correctness = correctness;
  _improvement = improvement;
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
    // "a.apple" -> "Apple"
    final parts = label.split('.');
    final last = parts.isNotEmpty ? parts.last : label;
    if (last.isEmpty) return label;
    return last[0].toUpperCase() + last.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LessonCompletePage.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/drawing_palette.png",
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.palette_rounded,
                            size: 22,
                            color: LessonCompletePage.topRowBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Drawing UNIT 1 Lesson 1",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: LessonCompletePage.topRowBlue,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _CircleActionButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Lesson Complete",
                      style: TextStyle(
                        color: LessonCompletePage.labelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Image.asset(
                      "assets/win.png",
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          "Illustration Missing",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ✅ Prediction summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD8C6B4)),
                      ),
                      child: _loading
                          ? Row(
                              children: const [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Predicting...",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Icon(Icons.verified_rounded, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _predictedLabel,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: LessonCompletePage.topRowBlue,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${_confidencePercent.toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 18),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Improvement",
                        style: TextStyle(
                          color: LessonCompletePage.labelColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(value: _loading ? 0 : _improvement),

                    const SizedBox(height: 14),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Correctness",
                        style: TextStyle(
                          color: LessonCompletePage.labelColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(value: _loading ? 0 : _correctness),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 3),
    );
  }
}

/* ===================== TOP RIGHT CIRCLE BUTTON ===================== */

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: LessonCompletePage.bubbleBg,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD8C6B4), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: LessonCompletePage.bubbleIcon),
        ),
      ),
    );
  }
}

/* ===================== THICK PROGRESS BAR ===================== */

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: 18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Container(color: LessonCompletePage.track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(color: LessonCompletePage.fill),
            ),
          ],
        ),
      ),
    );
  }
}
