import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../state/session_provider.dart'; // adjust path
import '../../../services/user_services/child_api.dart';

import '../../../services/Gemified/problem_solving_lesson_service.dart';
import '../../../services/Gemified/complete_problem_solving_session_service.dart';
import '../../../services/Gemified/problem_solving_level.dart';

import './lessonDetails.dart';

class ProblemSolvingUnit1Page extends StatefulWidget {
  const ProblemSolvingUnit1Page({super.key});

  @override
  State<ProblemSolvingUnit1Page> createState() => _ProblemSolvingUnit1PageState();
}

class _ProblemSolvingUnit1PageState extends State<ProblemSolvingUnit1Page> {
  static const Color pageBg = Color(0xFFF3E8E8);

  // Card palette
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color leftShade = Color(0xFFDFC7A7);
  static const Color titleColor = Color(0xFFA07E6A);
  static const Color descColor = Color(0xFFBD9A6B);

  // Top row
  static const Color topRowBlue = Color(0xFF386884);
  static const Color actionBtnBg = Color(0xFFF8F2E8);
  static const Color actionBtnBorder = Color(0xFFD8C6B4);
  static const Color actionIcon = Color(0xFFB0896E);

  bool loading = true;
  String? error;

  List<_LessonItem> lessons = [];

  // store progress by lessonId (0..1)

  final Map<String, double> _progressByLesson = {};

  @override
  void initState() {
    super.initState();
    _loadLessonsAndProgress();
  }

  Future<void> _loadLessonsAndProgress() async {
    setState(() {
      loading = true;
      error = null;
      _progressByLesson.clear();
    });

    try {
      // 1) get caregiver & child
      final session = context.read<SessionProvider>();
      final caregiverId =
          (session.caregiver?['_id'] ?? session.caregiver?['id'] ?? '').toString();

      if (caregiverId.isEmpty) {
        throw Exception("Caregiver ID not found. Please log in again.");
      }

      final children = await ChildApi.getChildrenByCaregiver(caregiverId);
      if (children.isEmpty) {
        throw Exception("No children found for this caregiver.");
      }

      final childId =
          ((children.first as Map<String, dynamic>)['_id'] ?? '').toString();
      
      // 2) Get skill level from backend
      String targetDifficulty = "Beginner";
      try {
        final levelData = await ProblemSolvingLevelService.getLevelByUserId(childId);
        targetDifficulty = (levelData['level'] ?? "Beginner").toString();
      } catch (e) {
        // Fallback to SharedPreferences if backend fetch fails
        final prefs = await SharedPreferences.getInstance();
        final skillLevel = prefs.getString("problem_solving_skill_level_value") ?? "Beginner";
        
        if (skillLevel == "new" || skillLevel == "some_common" || skillLevel == "Beginner") {
          targetDifficulty = "Beginner";
        } else if (skillLevel == "basic" || skillLevel == "Intermediate") {
          targetDifficulty = "Intermediate";
        } else if (skillLevel == "most" || skillLevel == "Advanced") {
          targetDifficulty = "Advanced";
        }
      }

      // 3) load all lessons and filter by difficulty
      final data = await ProblemSolvingLessonService.getAllLessons();

      final filtered = (data as List).where((e) {
        final m = (e as Map<String, dynamic>);
        final diff = (m["difficulty_level"] ?? "").toString();
        return diff.toLowerCase() == targetDifficulty.toLowerCase();
      }).toList();

      // Sort by createdAt ascending (oldest first - 1st record first)
      filtered.sort((a, b) {
        final ma = (a as Map<String, dynamic>);
        final mb = (b as Map<String, dynamic>);
        final da = DateTime.tryParse(ma["createdAt"]?.toString() ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = DateTime.tryParse(mb["createdAt"]?.toString() ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      });

      final mapped = filtered.map((e) {
        final m = (e as Map<String, dynamic>);
        return _LessonItem(
          id: (m["_id"] ?? "").toString(),
          title: (m["title"] ?? "").toString(),
          desc: (m["description"] ?? "").toString(),
        );
      }).toList();

      setState(() {
        lessons = mapped;
      });

      // 4) load progress for each lesson
      for (final l in mapped) {
        double p = 0.0;
        try {
          final res = await CompleteProblemSolvingSessionService.getByChildAndLesson(
            childId: childId,
            lessonId: l.id,
          );
          p = CompleteProblemSolvingSessionService.extractCorrectnessScore(res);
        } catch (_) {

          p = 0.0; // no completion found

        }

        // clamp 0..1
        p = p.clamp(0.0, 1.0);

        if (!mounted) return;
        setState(() {
          _progressByLesson[l.id] = p;
        });
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(
                children: [
                  Image.asset(
                    "assets/problem-solving.png",
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.psychology_alt_rounded,
                      size: 22,
                      color: topRowBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Problem Solving UNIT 1",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: topRowBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _CircleActionButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pushNamed(context, '/skillSelection'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLessonsAndProgress,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 3),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Failed to load lessons",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: const TextStyle(fontSize: 10.5, color: descColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: _loadLessonsAndProgress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionBtnBg,
                      foregroundColor: actionIcon,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: const BorderSide(color: actionBtnBorder, width: 1),
                      ),
                    ),
                    child: const Text("Retry"),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (lessons.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        children: const [
          Center(
            child: Text(
              "No lessons available",
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = lessons[index];
        final progress = (_progressByLesson[item.id] ?? 0.0).clamp(0.0, 1.0);

        return _LessonCard(
          title: item.title,
          desc: item.desc,

          progress: progress, // ✅ correctness_score shown here

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProblemSolvingMiniTutorialPage(lessonId: item.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _LessonItem {
  final String id;
  final String title;
  final String desc;

  const _LessonItem({
    required this.id,
    required this.title,
    required this.desc,
  });
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  static const Color bg = _ProblemSolvingUnit1PageState.actionBtnBg;
  static const Color border = _ProblemSolvingUnit1PageState.actionBtnBorder;
  static const Color iconColor = _ProblemSolvingUnit1PageState.actionIcon;

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
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.title,
    required this.desc,
    required this.onTap,
    this.progress = 0.0,
  });

  final String title;
  final String desc;
  final VoidCallback onTap;
  final double progress;

  static const Color cardBg = _ProblemSolvingUnit1PageState.cardBg;
  static const Color leftShade = _ProblemSolvingUnit1PageState.leftShade;
  static const Color titleColor = _ProblemSolvingUnit1PageState.titleColor;
  static const Color descColor = _ProblemSolvingUnit1PageState.descColor;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3A000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                decoration: const BoxDecoration(
                  color: leftShade,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(),
                    SizedBox(height: 4),
                    _Dot(),
                    SizedBox(height: 4),
                    _Dot(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.6,
                          fontWeight: FontWeight.w500,
                          color: descColor,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ProgressPill(progress: p),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3.8,
      height: 3.8,
      decoration: const BoxDecoration(
        color: Color(0xFFB89A76),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.progress});
  final double progress;

  static const Color track = Color(0xFFD8C6B4);
  static const Color fill = Color(0xFFB89A76);

  @override
  Widget build(BuildContext context) {
    final int percentage = (progress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(color: track),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: fill),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$percentage%",
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB89A76),
          ),
        ),
      ],
    );
  }
}
