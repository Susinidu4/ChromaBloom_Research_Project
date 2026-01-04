import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../services/Interactive_visual_task_scheduler_services/system_activity_service.dart';
import '../../../services/Interactive_visual_task_scheduler_services/tts_service.dart';

class DetailedSystemActivityScreen extends StatefulWidget {
  final String planMongoId;
  final DateTime selectedDate;

  const DetailedSystemActivityScreen({
    super.key,
    required this.activity,
    required this.planMongoId,
    required this.selectedDate,
  });

  final Map<String, dynamic> activity;

  @override
  State<DetailedSystemActivityScreen> createState() =>
      _DetailedSystemActivityScreenState();
}

class _DetailedSystemActivityScreenState
    extends State<DetailedSystemActivityScreen> {
  // UI Colors (match your theme)
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x22000000);

  // Themed alert dialog
  Future<void> showThemedAlert({
    required QuickAlertType type,
    required String title,
    required String text,
  }) async {
    await QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
      confirmBtnText: 'OK',
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      titleColor: const Color(0xFFBD9A6B),
      textColor: const Color(0xFFBD9A6B),
      confirmBtnColor: const Color(0xFFBD9A6B),
    );
  }

  final TextEditingController completedCtrl = TextEditingController();

  late List<Map<String, dynamic>> steps;
  //late List<bool> stepDone;

  List<bool> stepDone = [];
  bool loadingProgress = true;

  int completedMinutes = 0;

  @override
  void initState() {
    super.initState();

    TtsService.init();

    // 1) Build steps FIRST
    final rawSteps = (widget.activity["steps"] as List?) ?? [];
    steps = rawSteps.map<Map<String, dynamic>>((s) {
      final m = Map<String, dynamic>.from(s as Map);
      return {
        "step_number": m["step_number"],
        "instruction": (m["instruction"] ?? "").toString(),
      };
    }).toList();

    // 2) Then create checkbox list
    stepDone = List<bool>.filled(steps.length, false);

    // 3) Load saved progress from RoutineRun collection
    _loadSavedProgress();
  }

  @override
  void dispose() {
    TtsService.stop();
    completedCtrl.dispose();
    super.dispose();
  }

  int _calcPercent() {
    if (steps.isEmpty) return 0;
    final done = stepDone.where((x) => x).length;
    return ((done / steps.length) * 100).round();
  }

  void onIncCompleted() {
    setState(() {
      completedMinutes = (completedMinutes + 1).clamp(0, 60);
      completedCtrl.text = completedMinutes.toString();
    });
  }

  void onDecCompleted() {
    setState(() {
      completedMinutes = (completedMinutes - 1).clamp(0, 60);
      completedCtrl.text = completedMinutes.toString();
    });
  }

  String _title() => (widget.activity["title"] ?? "").toString();
  String _desc() =>
      (widget.activity["description"] ?? widget.activity["desc"] ?? "")
          .toString();

  Future<void> _speakTitle() async => TtsService.speak(_title());
  Future<void> _speakDescription() async => TtsService.speak(_desc());

  Future<void> _speakStep(int index) async {
    await TtsService.stop(); // stop speaking before speaking next step
    final n = (steps[index]["step_number"] ?? (index + 1)).toString();
    final instruction = (steps[index]["instruction"] ?? "").toString().trim();
    if (instruction.isEmpty) return;
    await TtsService.speak("Step $n. $instruction");
  }

  Future<void> _speakAllSteps() async {
    if (steps.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln("Steps.");
    for (int i = 0; i < steps.length; i++) {
      final n = (steps[i]["step_number"] ?? (i + 1)).toString();
      final instruction = (steps[i]["instruction"] ?? "").toString().trim();
      if (instruction.isEmpty) continue;
      buffer.writeln("Step $n. $instruction.");
    }
    await TtsService.speak(buffer.toString());
  }

  Future<void> _loadSavedProgress() async {
    try {
      const caregiverId = "p-0001";
      const childId = "c-0001";

      final planId = widget.planMongoId;
      final activityId = _getActivityMongoId();

      if (planId.isEmpty || activityId.isEmpty) {
        if (mounted) setState(() => loadingProgress = false);
        return;
      }

      final run = await ChildRoutinePlanService.getRoutineRunProgress(
        caregiverId: caregiverId,
        childId: childId,
        planMongoId: widget.planMongoId,
        activityMongoId: widget.activity["_id"],
        runDate: widget.selectedDate, // ✅ calendar date
      );

      if (run != null) {
        final saved = (run["steps_progress"] as List?) ?? [];
        for (final s in saved) {
          final stepNo = int.tryParse("${s["step_number"]}") ?? 0;
          final status = (s["status"] ?? false) == true;
          final idx = stepNo - 1;
          if (idx >= 0 && idx < stepDone.length) {
            stepDone[idx] = status;
          }
        }
        completedMinutes =
            int.tryParse("${run["completed_duration_minutes"] ?? 0}") ?? 0;
        completedCtrl.text = completedMinutes.toString();
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => loadingProgress = false);
    }
  }

  String _getActivityMongoId() {
    // if you passed the pure activity object:
    final direct = (widget.activity["_id"] ?? "").toString();
    if (direct.isNotEmpty) return direct;

    // if you passed {activityId: {...}, order: ...}
    final nested = widget.activity["activityId"];
    if (nested is Map) {
      return (nested["_id"] ?? "").toString();
    }

    return "";
  }

  Map<String, dynamic> _getActivityObj() {
    final nested = widget.activity["activityId"];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    final activity = _getActivityObj();

    final title = (widget.activity["title"] ?? "").toString();
    final description =
        (widget.activity["description"] ?? widget.activity["desc"] ?? "")
            .toString();

    final est = (widget.activity["estimated_duration_minutes"] ?? 0);
    final percent = _calcPercent();

    final img =
        (widget.activity["img"] ??
                (widget.activity["media_links"] is List &&
                        (widget.activity["media_links"] as List).isNotEmpty
                    ? widget.activity["media_links"][0]
                    : "assets/brushing_teeth.png"))
            .toString();

    final bool isNetwork = img.startsWith("http");

    final activityId = _getActivityMongoId();

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 0,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  children: [
                    // Back button (top-left like your UI)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(26),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF6F0EC),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: shadow,
                                blurRadius: 14,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: stroke.withOpacity(0.85),
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // MAIN CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: shadow,
                            blurRadius: 14,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress bar row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      percent == 100
                                          ? "Completed"
                                          : (percent == 0
                                                ? "Pending"
                                                : "In Progress"),
                                      style: TextStyle(
                                        color: stroke.withOpacity(0.55),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: percent / 100.0,
                                        minHeight: 6,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.65),
                                        color: stroke,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "$percent%",
                                style: TextStyle(
                                  color: stroke.withOpacity(0.75),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Title
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: stroke,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _speakTitle,
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.volume_up_rounded,
                                    color: stroke,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Estimated Duration row
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: stroke.withOpacity(0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Estimated Duration: $est minutes",
                                style: TextStyle(
                                  color: stroke.withOpacity(0.85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Big image
                          Center(
                            child: SizedBox(
                              height: 190,
                              child: isNetwork
                                  ? Image.network(img, fit: BoxFit.contain)
                                  : Image.asset(img, fit: BoxFit.contain),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  description,
                                  style: TextStyle(
                                    color: stroke.withOpacity(0.65),
                                    fontSize: 14,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _speakDescription,
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.volume_up_rounded,
                                    color: stroke,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "STEPS:",
                            style: TextStyle(
                              color: stroke,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Steps list
                          ...List.generate(steps.length, (i) {
                            final instruction = (steps[i]["instruction"] ?? "")
                                .toString();

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${i + 1}. $instruction",
                                      style: TextStyle(
                                        color: stroke.withOpacity(0.8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // ✅ step speaker
                                  InkWell(
                                    onTap: () => _speakStep(i),
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
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        checkboxTheme: CheckboxThemeData(
                                          fillColor:
                                              MaterialStateProperty.resolveWith(
                                                (states) {
                                                  // ✅ unchecked bg white
                                                  if (!states.contains(
                                                    MaterialState.selected,
                                                  )) {
                                                    return Colors.white;
                                                  }
                                                  return stroke; // checked bg
                                                },
                                              ),
                                          checkColor: MaterialStateProperty.all(
                                            Colors.white,
                                          ),
                                          side:
                                              MaterialStateBorderSide.resolveWith(
                                                (states) => BorderSide(
                                                  color: stroke.withOpacity(
                                                    0.9,
                                                  ),
                                                  width: 1.2,
                                                ),
                                              ),
                                        ),
                                      ),
                                      child: Checkbox(
                                        value: stepDone[i],
                                        onChanged: (v) async {
                                          await TtsService.stop();

                                          if (completedMinutes <= 0) {
                                            showThemedAlert(
                                              type: QuickAlertType.warning,
                                              title: "Duration Required",
                                              text:
                                                  "Please enter completed duration (1–60 minutes) first.",
                                            );
                                            return;
                                          }

                                          setState(() {
                                            stepDone[i] = v ?? false;
                                          });
                                        },

                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 18),

                          // Completed Duration input
                          Row(
                            children: [
                              Text(
                                "Completed Duration :",
                                style: TextStyle(
                                  color: stroke.withOpacity(0.75),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // number box
                              Container(
                                width: 56,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9DDCC),
                                  border: Border.all(
                                    color: stroke.withOpacity(0.65),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: shadow,
                                      blurRadius: 10,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: completedCtrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    final n = int.tryParse(v) ?? 0;
                                    final clamped = n.clamp(0, 60);
                                    setState(() => completedMinutes = clamped);
                                    completedCtrl.text = clamped.toString();
                                    completedCtrl.selection =
                                        TextSelection.collapsed(
                                          offset: completedCtrl.text.length,
                                        );
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              // up/down buttons
                              // ⬆⬇ Minute adjuster (matches UI)
                              Container(
                                width: 26,
                                height:
                                    40, // 🔽 reduced height (try 32–36 if needed)
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0E8DA),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: stroke.withOpacity(0.9),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: onIncCompleted,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
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
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(10),
                                            ),
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

                              const SizedBox(width: 10),

                              Text(
                                "min",
                                style: TextStyle(
                                  color: stroke.withOpacity(0.75),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Save button
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final caregiverId = "p-0001";
                                  final childId = "c-0001";
                                  final planId = widget.planMongoId;
                                  final activityId = _getActivityMongoId();

                                  // ❌ missing ids
                                  if (planId.isEmpty || activityId.isEmpty) {
                                    showThemedAlert(
                                      type: QuickAlertType.error,
                                      title: "Error",
                                      text:
                                          "Missing plan or activity information.",
                                    );
                                    return;
                                  }

                                  // ❌ completed duration REQUIRED
                                  if (completedMinutes <= 0) {
                                    showThemedAlert(
                                      type: QuickAlertType.error,
                                      title: "Duration Required",
                                      text:
                                          "Please enter completed duration (1–60 minutes).",
                                    );
                                    return;
                                  }

                                  // ❌ at least one step checkbox REQUIRED
                                  final anyChecked = stepDone.any(
                                    (x) => x == true,
                                  );
                                  if (!anyChecked) {
                                    showThemedAlert(
                                      type: QuickAlertType.error,
                                      title: "Steps Required",
                                      text:
                                          "Please tick at least one step before saving.",
                                    );
                                    return;
                                  }

                                  final stepsProgress = List.generate(
                                    stepDone.length,
                                    (i) {
                                      return {
                                        "step_number": i + 1,
                                        "status": stepDone[i],
                                      };
                                    },
                                  );

                                  try {
                                    final res =
                                        await ChildRoutinePlanService.saveRoutineRun(
                                          caregiverId: caregiverId,
                                          childId: childId,
                                          planMongoId: planId,
                                          activityMongoId: activityId,
                                          runDate: widget.selectedDate,
                                          stepsProgress: stepsProgress,
                                          completedDurationMinutes:
                                              completedMinutes,
                                        );

                                    if (!mounted) return;

                                    await showThemedAlert(
                                      type: QuickAlertType.success,
                                      title: "Saved",
                                      text:
                                          res["message"] ??
                                          "Progress saved successfully.",
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    if (!mounted) return;

                                    await showThemedAlert(
                                      type: QuickAlertType.error,
                                      title: "Save Failed",
                                      text: e.toString(),
                                    );
                                  }
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB79C6B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 10,
                                  shadowColor: shadow,
                                ),
                                child: const Text(
                                  "Save",
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
}

/* Small square button like your UI */
class _MiniSquareIconButton extends StatelessWidget {
  const _MiniSquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x22000000);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 28,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F0EC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: stroke.withOpacity(0.65), width: 1.2),
          boxShadow: const [
            BoxShadow(color: shadow, blurRadius: 10, offset: Offset(0, 6)),
          ],
        ),
        child: Icon(icon, color: stroke, size: 18),
      ),
    );
  }
}
