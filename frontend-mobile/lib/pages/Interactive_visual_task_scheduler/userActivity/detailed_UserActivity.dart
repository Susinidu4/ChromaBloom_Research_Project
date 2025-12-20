import 'dart:io';
import 'package:flutter/material.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';
import '../../../services/Interactive_visual_task_scheduler_services/user_activity_service.dart';
import '../../../services/Interactive_visual_task_scheduler_services/tts_service.dart';
import 'edit_userActivity.dart';

class DetailedUserActivityScreen extends StatefulWidget {
  const DetailedUserActivityScreen({super.key, required this.activity});
  final Map<String, dynamic> activity;

  @override
  State<DetailedUserActivityScreen> createState() =>
      _DetailedUserActivityScreenState();
}

class _DetailedUserActivityScreenState
    extends State<DetailedUserActivityScreen> {
  // ===== Theme colors =====
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color stroke = Color(0xFFBD9A6B);

  int progressPercent = 0;
  String statusText = "In Progress";

  late List<Map<String, dynamic>> steps;
  late List<bool> stepDone;

  int completedMinutes = 0;

  @override
  void initState() {
    super.initState();

    TtsService.init();

    final rawSteps = (widget.activity["steps"] as List?) ?? [];
    steps = rawSteps.map((e) => Map<String, dynamic>.from(e as Map)).toList()
      ..sort(
        (a, b) => (a["step_number"] ?? 0).compareTo(b["step_number"] ?? 0),
      );

    // ✅ load saved step status from DB
    stepDone = steps.map((s) => (s["status"] == true)).toList();

    // ✅ load saved completed minutes from DB
    final cd = widget.activity["completed_duration_minutes"];
    if (cd is int) {
      completedMinutes = cd;
    } else if (cd is double) {
      completedMinutes = cd.toInt();
    } else if (cd is String) {
      completedMinutes = int.tryParse(cd) ?? 0;
    } else {
      completedMinutes = 0;
    }

    // ✅ compute initial progress using DB values
    final done = stepDone.where((x) => x).length;
    progressPercent = steps.isEmpty ? 0 : ((done / steps.length) * 100).round();
    statusText = (progressPercent == 100) ? "Completed" : "In Progress";
  }

  @override
  void dispose() {
    // ✅ stop speaking when leaving page
    TtsService.stop();
    super.dispose();
  }

  String _title() => (widget.activity["title"] ?? "").toString();
  String _desc() => (widget.activity["description"] ?? "").toString();

  int _estimatedMinutes() {
    final v = widget.activity["estimated_duration_minutes"];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  String? _imageUrl() {
    final links = widget.activity["media_links"];
    if (links is List && links.isNotEmpty) {
      final first = links.first?.toString();
      if (first != null && first.startsWith("http")) return first;
    }
    return null;
  }

  void _toggleStep(int i, bool? v) {
    setState(() => stepDone[i] = v ?? false);

    final done = stepDone.where((x) => x).length;
    final pct = steps.isEmpty ? 0 : ((done / steps.length) * 100).round();
    setState(() {
      progressPercent = pct;
      statusText = (pct == 100) ? "Completed" : "In Progress";
    });
  }

  void _incCompleted() =>
      setState(() => completedMinutes = (completedMinutes + 1).clamp(0, 999));
  void _decCompleted() =>
      setState(() => completedMinutes = (completedMinutes - 1).clamp(0, 999));

  // ✅ TTS
  Future<void> _speakTitle() async => TtsService.speak(_title());
  Future<void> _speakDescription() async => TtsService.speak(_desc());

  // ✅ Speak a single step (STEP BY STEP)
  Future<void> _speakStep(int index) async {
    if (index < 0 || index >= steps.length) return;
    final n = (steps[index]["step_number"] ?? (index + 1)).toString();
    final instruction = (steps[index]["instruction"] ?? "").toString().trim();
    if (instruction.isEmpty) return;
    await TtsService.speak("Step $n. $instruction");
  }

  // ✅ Optional: speak ALL steps (you already had this)
  Future<void> _speakAllSteps() async {
    if (steps.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln("Steps.");
    for (int i = 0; i < steps.length; i++) {
      final n = (steps[i]["step_number"] ?? (i + 1)).toString();
      final instruction = (steps[i]["instruction"] ?? "").toString();
      if (instruction.trim().isEmpty) continue;
      buffer.writeln("Step $n. $instruction.");
    }
    await TtsService.speak(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = _imageUrl();

    return Scaffold(
      backgroundColor: pageBg,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _CircleIconButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _DetailCard(
                      title: _title(),
                      statusText: statusText,
                      progressPercent: progressPercent,
                      estimatedMinutes: _estimatedMinutes(),
                      description: _desc(),
                      steps: steps,
                      stepDone: stepDone,
                      onStepChanged: _toggleStep,
                      imgUrl: imgUrl,
                      completedMinutes: completedMinutes,
                      onIncCompleted: _incCompleted,
                      onDecCompleted: _decCompleted,

                      // ✅ TTS callbacks
                      onSpeakTitle: _speakTitle,
                      onSpeakDescription: _speakDescription,
                      onSpeakAllSteps: _speakAllSteps,
                      onSpeakSingleStep: _speakStep, // ✅ NEW
                      onStopTts: () => TtsService.stop(),

                      onDelete: () async {
                        final mongoId = (widget.activity["_id"] ?? "")
                            .toString();
                        if (mongoId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cannot delete: missing _id"),
                            ),
                          );
                          return;
                        }

                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete this task?"),
                            content: const Text(
                              "This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (ok != true) return;

                        try {
                          final res =
                              await UserActivityService.deleteUserActivity(
                                mongoId: mongoId,
                              );

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res["message"] ?? "Deleted"),
                            ),
                          );

                          Navigator.pop(context, true);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Delete failed: $e")),
                          );
                        }
                      },

                      onSave: () async {
                        final mongoId = (widget.activity["_id"] ?? "")
                            .toString();
                        if (mongoId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cannot save: missing _id"),
                            ),
                          );
                          return;
                        }

                        try {
                          final res =
                              await UserActivityService.updateUserActivityProgress(
                                mongoId: mongoId,
                                steps: _stepsPayload(),
                                completedDurationMinutes: completedMinutes,
                              );

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res["message"] ?? "Saved")),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Save failed: $e")),
                          );
                        }
                      },

                      onEdit: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateUserActivityScreen(
                              activity: widget.activity,
                            ),
                          ),
                        );

                        if (updated == true && mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 1),
    );
  }

  List<Map<String, dynamic>> _stepsPayload() {
    return List.generate(steps.length, (i) {
      final s = steps[i];
      return {
        "step_number": s["step_number"] ?? (i + 1),
        "instruction": (s["instruction"] ?? "").toString(),
        "status": stepDone[i],
      };
    });
  }
}

// =======================================================
// DETAIL CARD
// =======================================================
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.statusText,
    required this.progressPercent,
    required this.estimatedMinutes,
    required this.description,
    required this.steps,
    required this.stepDone,
    required this.onStepChanged,
    required this.imgUrl,
    required this.completedMinutes,
    required this.onIncCompleted,
    required this.onDecCompleted,
    required this.onDelete,
    required this.onSave,
    required this.onEdit,

    // ✅ TTS
    required this.onSpeakTitle,
    required this.onSpeakDescription,
    required this.onSpeakAllSteps,
    required this.onSpeakSingleStep, // ✅ NEW
    required this.onStopTts,
  });

  final String title;
  final String statusText;
  final int progressPercent;
  final int estimatedMinutes;
  final String description;

  final List<Map<String, dynamic>> steps;
  final List<bool> stepDone;
  final void Function(int i, bool? v) onStepChanged;

  final String? imgUrl;

  final int completedMinutes;
  final VoidCallback onIncCompleted;
  final VoidCallback onDecCompleted;

  final VoidCallback onDelete;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  // ✅ TTS
  final VoidCallback onSpeakTitle;
  final VoidCallback onSpeakDescription;
  final VoidCallback onSpeakAllSteps;
  final Future<void> Function(int index) onSpeakSingleStep; // ✅ NEW
  final VoidCallback onStopTts;

  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x33000000);
  static const Color textDark = Color(0xFF2F2A22);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: shadow, blurRadius: 16, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row: edit (stop TTS optional)
          Row(
            children: [
              // InkWell(
              //   onTap: onStopTts,
              //   borderRadius: BorderRadius.circular(10),
              //   child: const Padding(
              //     padding: EdgeInsets.all(6),
              //     child: Icon(Icons.stop_circle_outlined, color: stroke, size: 26),
              //   ),
              // ),
              const Spacer(),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.mode_edit_outlined,
                    color: stroke,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: stroke.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "$progressPercent%",
                style: const TextStyle(
                  color: stroke,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (progressPercent.clamp(0, 100)) / 100.0,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.7),
              color: stroke,
            ),
          ),

          const SizedBox(height: 16),

          // title + speaker
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: stroke,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              InkWell(
                onTap: onSpeakTitle,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.volume_up_rounded, color: stroke, size: 26),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.timer_outlined, color: stroke, size: 18),
              const SizedBox(width: 8),
              Text(
                "Estimated Duration: $estimatedMinutes minutes",
                style: const TextStyle(
                  color: stroke,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Center(
            child: SizedBox(
              height: 220,
              child: imgUrl != null
                  ? Image.network(imgUrl!, fit: BoxFit.contain)
                  : Image.asset(
                      "assets/create_user_activity.png",
                      fit: BoxFit.contain,
                    ),
            ),
          ),

          const SizedBox(height: 18),

          // description + speaker
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: stroke.withOpacity(0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              InkWell(
                onTap: onSpeakDescription,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.volume_up_rounded, color: stroke, size: 24),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // steps header + speaker (all steps)
          Row(
            children: [
              const Expanded(
                child: Text(
                  "STEPS:",
                  style: TextStyle(
                    color: stroke,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // InkWell(
              //   onTap: onSpeakAllSteps,
              //   borderRadius: BorderRadius.circular(10),
              //   child: const Padding(
              //     padding: EdgeInsets.all(6),
              //     child: Icon(Icons.volume_up_rounded, color: stroke, size: 24),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ steps list with per-step speaker icon + checkbox
          ...List.generate(steps.length, (i) {
            final s = steps[i];
            final n = (s["step_number"] ?? (i + 1)).toString();
            final instruction = (s["instruction"] ?? "").toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "$n. $instruction",
                      style: TextStyle(
                        color: stroke.withOpacity(0.78),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ✅ step speaker
                  InkWell(
                    onTap: () => onSpeakSingleStep(i),
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: stroke,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: stepDone[i],
                      onChanged: (v) => onStepChanged(i, v),
                      fillColor: MaterialStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        return Colors.white; // ✅ white background
                      }),
                      side: BorderSide(
                        color: stroke.withOpacity(0.9),
                        width: 1.2,
                      ),
                      checkColor: stroke,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                "Completed Duration :",
                style: TextStyle(
                  color: stroke.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),

              Container(
                width: 52,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8DA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: stroke, width: 1.2),
                ),
                child: Text(
                  "$completedMinutes",
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Container(
                width: 28,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8DA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: stroke, width: 1.2),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onIncCompleted,
                        child: const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: stroke,
                          size: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: onDecCompleted,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: stroke,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),
              Text(
                "min",
                style: TextStyle(
                  color: stroke.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  text: "Delete",
                  bg: const Color(0xFF7B4B3A),
                  onTap: onDelete,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionButton(
                  text: "Save",
                  bg: const Color(0xFFB79C6B),
                  onTap: onSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.bg,
    required this.onTap,
  });
  final String text;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  static const Color shadow = Color(0x33000000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 12, offset: Offset(0, 8)),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFBD9A6B)),
      ),
    );
  }
}
