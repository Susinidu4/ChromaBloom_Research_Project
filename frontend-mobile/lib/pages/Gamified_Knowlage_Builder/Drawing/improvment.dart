import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../services/Gemified/drawing_predict_service.dart';
import '../../../services/Gemified/complete_drawing_lesson_service.dart';

import '../../../state/session_provider.dart';

class LessonCompletePage extends StatefulWidget {
  const LessonCompletePage({
    super.key,
    required this.lessonId,
    required this.imageFile,
    required this.previousCorrectness, // (kept, but DB-based improvement is used)
  });

  final String lessonId;
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
  bool _saving = false;
  bool _savedOnce = false;

  String _predictedLabel = "-";
  double _confidencePercent = 0;

  // 0..1
  double _correctness = 0;

  // 0..1  (currentCorrectness - lastDbCorrectness)
  double _improvement = 0;

  // previous saved correctness from DB (0..1)
  double _prevDbCorrectness = 0;

  @override
  void initState() {
    super.initState();
    _predictOnLoad();
  }

  String _prettyLabel(String label) {
    final parts = label.split('.');
    final last = parts.isNotEmpty ? parts.last : label;
    if (last.isEmpty) return label;
    return last[0].toUpperCase() + last.substring(1);
  }

  String? _getCaregiverIdFromSession() {
    final session = context.read<SessionProvider>();

    final caregiver = session.caregiver;
    if (caregiver == null) return null;

    final id = (caregiver['_id'] ?? caregiver['id'] ?? caregiver['caregiverId'])
        ?.toString();

    if (id == null || id.isEmpty) return null;
    return id;
  }

  /* ===================== DB HELPERS (extract list + last record) ===================== */

  List<Map<String, dynamic>> _extractList(dynamic json) {
    // common response shapes
    if (json is Map<String, dynamic>) {
      final candidates = [
        json["data"],
        json["items"],
        json["results"],
        json["lessons"],
        json["completedLessons"],
      ];

      for (final c in candidates) {
        if (c is List) {
          return c
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList(growable: false);
        }

        // sometimes: data = { items: [] }
        if (c is Map && c["items"] is List) {
          return (c["items"] as List)
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList(growable: false);
        }
      }
    }

    // fallback if API returns raw list
    if (json is List) {
      return json
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(growable: false);
    }

    return const [];
  }

  double _extractCorrectnessFromRecord(Map<String, dynamic> r) {
    final v = r["correctness_rate"] ?? r["correctnessRate"] ?? r["correctness"];
    if (v == null) return 0.0;

    final numVal = (v is num) ? v : num.tryParse(v.toString()) ?? 0.0;

    // normalize 0..100 -> 0..1
    final rate = (numVal > 1.0) ? (numVal.toDouble() / 100.0) : numVal.toDouble();
    return rate.clamp(0.0, 1.0);
  }

  DateTime _extractCreatedAt(Map<String, dynamic> r) {
    final v = r["createdAt"] ?? r["created_at"] ?? r["timestamp"];
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<double> _fetchLastCorrectnessFromDb(String userId) async {
    try {
      final res = await CompleteDrawingLessonService.getCompletedLessonsByUser(userId);
      final list = _extractList(res);

      if (list.isEmpty) return 0.0;

      // Prefer createdAt sorting if present; else just use list.last
      // We'll sort anyway; if createdAt missing, all become epoch and order stays stable-ish.
      final sorted = [...list];
      sorted.sort((a, b) => _extractCreatedAt(a).compareTo(_extractCreatedAt(b)));
      final last = sorted.isNotEmpty ? sorted.last : list.last;

      return _extractCorrectnessFromRecord(last);
    } catch (_) {
      // if fetch fails, assume no previous record
      return 0.0;
    }
  }

  /* ===================== SAVE COMPLETED LESSON ===================== */

  Future<void> _saveCompletedLesson() async {
    if (_savedOnce) return;
    if (widget.lessonId.isEmpty) return;

    final caregiverId = _getCaregiverIdFromSession();
    if (caregiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Caregiver session not found. Please login again."),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await CompleteDrawingLessonService.createCompletedLesson(
        lessonId: widget.lessonId,
        userId: caregiverId,
        correctnessRate: _correctness, // 0..1
      );

      _savedOnce = true;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saving completion failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /* ===================== PREDICT + COMPUTE IMPROVEMENT (DB-LAST) ===================== */

  Future<void> _predictOnLoad() async {
    setState(() => _loading = true);

    try {
      final caregiverId = _getCaregiverIdFromSession();
      if (caregiverId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Caregiver session not found. Please login again.")),
        );
        setState(() => _loading = false);
        return;
      }

      // ✅ 1) get last saved correctness from DB BEFORE saving current record
      final prevDb = await _fetchLastCorrectnessFromDb(caregiverId);

      // ✅ 2) predict current drawing
      final res = await DrawingPredictService.predictDrawing(widget.imageFile);

      final top1 = (res["top1"] as Map?)?.cast<String, dynamic>();
      final rawLabel = top1?["label"]?.toString() ?? "-";
      final conf = (top1?["confidence"] as num?)?.toDouble() ?? 0.0;

      final pretty = _prettyLabel(rawLabel);

      // conf 0..100 => correctness 0..1
      final currentCorrectness = (conf.clamp(0, 100) / 100.0);

      // ✅ 3) improvement = current - lastDb (0..1)
      final improvement = (currentCorrectness - prevDb).clamp(0.0, 1.0);

      if (!mounted) return;
      setState(() {
        _predictedLabel = pretty;
        _confidencePercent = conf;
        _correctness = currentCorrectness;
        _prevDbCorrectness = prevDb;
        _improvement = improvement;
      });

      // ✅ 4) save current completion AFTER computing improvement
      await _saveCompletedLesson();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prediction failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                            "Lesson Complete",
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
                          onTap: () {
                            Navigator.pushNamed(context, '/drawingUnit1');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                                const Spacer(),
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

                    const SizedBox(height: 10),

                    if (_saving)
                      const Text(
                        "Saving completion...",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Improvement",
                          style: TextStyle(
                            color: LessonCompletePage.labelColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${(_improvement * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: LessonCompletePage.labelColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(value: _loading ? 0 : _improvement),

                    // optional small helper text (remove if you don't want)
                    const SizedBox(height: 6),
                    if (!_loading)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Previous: ${(_prevDbCorrectness * 100).toStringAsFixed(0)}%   |   Now: ${(_correctness * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Correctness Score",
                          style: TextStyle(
                            color: LessonCompletePage.labelColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${(_correctness * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: LessonCompletePage.labelColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
