import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../state/session_provider.dart'; // adjust path
import '../../../services/user_services/child_api.dart';
import '../../../services/Gemified/complete_problem_solving_session_service.dart';

class ProblemSolvingLessonCompletePage extends StatefulWidget {
  const ProblemSolvingLessonCompletePage({
    super.key,
    required this.lessonId,
    required this.correctness,
    required this.improvement, // kept for compatibility, but we compute improvement from API now
  });

  static const Color pageBg = Color(0xFFF5ECEC);

  // Top row colors
  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color circleBg = Color(0xFFF8F2E8);
  static const Color circleBorder = Color(0xFFD8C6B4);
  static const Color circleIcon = Color(0xFFB0896E);

  // Progress colors
  static const Color track = Color(0xFFD8D1C7);
  static const Color fill = Color(0xFFB89A76);

  static const Color labelColor = Color(0xFF111111);

  final String lessonId; // ✅ REQUIRED for saving
  final double correctness; // 0.0 - 1.0
  final double improvement; // not used for UI anymore (API-based improvement)

  @override
  State<ProblemSolvingLessonCompletePage> createState() =>
      _ProblemSolvingLessonCompletePageState();
}

class _ProblemSolvingLessonCompletePageState
    extends State<ProblemSolvingLessonCompletePage> {
  bool _saving = false;
  bool _savedOnce = false;

  // ✅ computed from backend last 2 records
  double _computedImprovement = 0.0;

  // ✅ show IDs on UI
  String _caregiverId = "";
  String _childId = "";
  late final String _lessonId = widget.lessonId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _waitForSessionThenSave());
  }

  // ✅ NEW: wait until SessionProvider finishes loadFromStorage()
  Future<void> _waitForSessionThenSave() async {
    final session = context.read<SessionProvider>();

    // wait up to ~2 seconds for loadFromStorage() to finish
    for (int i = 0; i < 20; i++) {
      if (session.isLoggedIn && session.caregiver != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    if (!session.isLoggedIn || session.caregiver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session is still loading. Please try again.")),
      );
      return;
    }

    await _autoSaveCompletion();
  }

  // ----- helpers -----

  List<Map<String, dynamic>> _extractDataList(Map<String, dynamic> res) {
    final raw = res["data"];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    // if backend returns single object, wrap it
    if (raw is Map) {
      return [raw.map((k, v) => MapEntry(k.toString(), v))];
    }
    return [];
  }

  double _readScore(Map<String, dynamic> item) {
    final v = item["correctness_score"];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? "") ?? 0.0;
  }

  DateTime? _readDate(Map<String, dynamic> item) {
    // try common fields (optional)
    final s = item["createdAt"] ?? item["created_at"] ?? item["timestamp"];
    if (s == null) return null;
    try {
      return DateTime.parse(s.toString());
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _sortRecordsSmart(List<Map<String, dynamic>> list) {
    // If createdAt exists -> sort by date; else keep original order
    final hasAnyDate = list.any((e) => _readDate(e) != null);
    if (!hasAnyDate) return list;

    final copy = [...list];
    copy.sort((a, b) {
      final da = _readDate(a);
      final db = _readDate(b);
      if (da == null && db == null) return 0;
      if (da == null) return -1;
      if (db == null) return 1;
      return da.compareTo(db);
    });
    return copy;
  }

  double _computeImprovementFromLastTwo(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return 0.0;

    final sorted = _sortRecordsSmart(records);

    if (sorted.length == 1) {
      // only 1 record -> improvement can be 0 (or same as score). We'll keep 0.
      return 0.0;
    }

    final last = _readScore(sorted[sorted.length - 1]);
    final prev = _readScore(sorted[sorted.length - 2]);

    // improvement as positive delta (0..1)
    final delta = (last - prev);
    return delta.clamp(0.0, 1.0);
  }

  Future<void> _autoSaveCompletion() async {
    if (_savedOnce || _saving) return;

    setState(() {
      _saving = true;
      _savedOnce = true;
    });

    try {
      final session = context.read<SessionProvider>();

      if (!session.isLoggedIn || session.caregiver == null) {
        throw Exception("No caregiver session found. Please login again.");
      }

      final caregiverId = (session.caregiver!['_id']).toString();
      if (caregiverId.isEmpty) {
        throw Exception("Caregiver ID not found in session");
      }

      // ✅ get child list by caregiver
      final children = await ChildApi.getChildrenByCaregiver(caregiverId);
      if (children.isEmpty) throw Exception("No child found for this caregiver");

      // ✅ choose first child (replace later with selected child)
      final first = children.first;
      final childId = (first['_id'] ?? first['id'] ?? '').toString();
      if (childId.isEmpty) throw Exception("Child ID not found");

      // ✅ store for UI display
      if (mounted) {
        setState(() {
          _caregiverId = caregiverId;
          _childId = childId;
        });
      }

      final correctnessClamped = widget.correctness.clamp(0.0, 1.0);

      // 1) fetch existing records (before save)
      double prevScore = 0.0;
      try {
        final res = await CompleteProblemSolvingSessionService.getByChildAndLesson(
          childId: childId,
          lessonId: widget.lessonId,
        );
        final existingRecords = _extractDataList(res);
        if (existingRecords.isNotEmpty) {
          final sorted = _sortRecordsSmart(existingRecords);
          prevScore = _readScore(sorted.last);
        }
      } catch (_) {
        // ignore (might be 404)
      }

      // 2) Upsert the session (update existing if it exists, otherwise create)
      await CompleteProblemSolvingSessionService.upsert(
        childId: childId,
        lessonId: widget.lessonId,
        correctnessScore: correctnessClamped,
      );

      // 3) improvement as positive delta (0..1)
      final computed = (correctnessClamped - prevScore).clamp(0.0, 1.0);

      if (!mounted) return;
      setState(() {
        _computedImprovement = computed;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final correctnessClamped = widget.correctness.clamp(0.0, 1.0);
    final improvementClamped = _computedImprovement.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: ProblemSolvingLessonCompletePage.pageBg,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/problem-solving.png",
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.psychology_alt_rounded,
                            size: 24,
                            color: ProblemSolvingLessonCompletePage.topRowBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Problem Solving UNIT 1",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ProblemSolvingLessonCompletePage.topRowBlue,
                              fontSize: 13,
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

                    const SizedBox(height: 10),

                    // // ✅ ID DISPLAY CARD
                    // _IdInfoCard(
                    //   lessonId: _lessonId,
                    //   caregiverId: _caregiverId,
                    //   childId: _childId,
                    // ),

                    // const SizedBox(height: 14),

                    Row(
                      children: [
                        const Text(
                          "Lesson Complete",
                          style: TextStyle(
                            color: ProblemSolvingLessonCompletePage.labelColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (_saving)
                          const Text(
                            "Saving...",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: Image.asset(
                        "assets/win2.png",
                        height: 235,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 235,
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
                    ),

                    const SizedBox(height: 18),

                    Text(
                      "Improvement  (+${(improvementClamped * 100).round()}%)",
                      style: const TextStyle(
                        color: ProblemSolvingLessonCompletePage.labelColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ThickProgressBar(value: improvementClamped),

                    const SizedBox(height: 14),

                    Text(
                      "Correctness  (${(correctnessClamped * 100).round()}%)",
                      style: const TextStyle(
                        color: ProblemSolvingLessonCompletePage.labelColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ThickProgressBar(value: correctnessClamped),
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

class _IdInfoCard extends StatelessWidget {
  const _IdInfoCard({
    required this.lessonId,
    required this.caregiverId,
    required this.childId,
  });

  final String lessonId;
  final String caregiverId;
  final String childId;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value) {
      final v = value.trim().isEmpty ? "—" : value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                "$label:",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ProblemSolvingLessonCompletePage.topRowBlue,
                ),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ProblemSolvingLessonCompletePage.circleBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ProblemSolvingLessonCompletePage.circleBorder,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row("Lesson ID", lessonId),
          row("Caregiver ID", caregiverId),
          row("Child ID", childId),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, required this.onTap});

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
            color: ProblemSolvingLessonCompletePage.circleBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: ProblemSolvingLessonCompletePage.circleBorder,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: ProblemSolvingLessonCompletePage.circleIcon,
          ),
        ),
      ),
    );
  }
}

class _ThickProgressBar extends StatelessWidget {
  const _ThickProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: 14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Container(color: ProblemSolvingLessonCompletePage.track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(color: ProblemSolvingLessonCompletePage.fill),
            ),
          ],
        ),
      ),
    );
  }
}
