import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

// ✅ Existing lesson service
import '../../../services/Gemified/drawing_lesson_service.dart';

// ✅ NEW: completed lesson service
import '../../../services/Gemified/complete_drawing_lesson_service.dart';

class DrawingUnit1Page extends StatefulWidget {
  const DrawingUnit1Page({super.key});

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

  @override
  State<DrawingUnit1Page> createState() => _DrawingUnit1PageState();
}

class _DrawingUnit1PageState extends State<DrawingUnit1Page> {
  late final DrawingLessonService _service;
  late Future<List<_LessonItem>> _futureLessons;

  // ✅ TODO: Replace with logged-in user id
  // Example: from your auth provider / storage
  final String hardcodedUserId = "u-0001";

  @override
  void initState() {
    super.initState();

    // ✅ IMPORTANT BASE URL NOTES:
    // If Android Emulator: http://10.0.2.2:5000
    // If real device: http://YOUR_PC_IP:5000
    // If web: http://localhost:5000

    // Drawing lessons service (your existing)
    _service = DrawingLessonService(
      baseUrl: "http://localhost:5000/chromabloom/drawing-lessons",
      // token: "YOUR_JWT_IF_NEEDED",
    );

    // Completed lesson service baseUrl (update once globally)
    CompleteDrawingLessonService.baseUrl = "http://localhost:5000";

    _futureLessons = _fetchLessons();
  }

  Future<List<_LessonItem>> _fetchLessons() async {
    // 1) Get all lessons
    final raw = await _service.getAllLessons(); // returns List<dynamic>

    final lessons = raw.map<_LessonItem>((e) {
      final m = (e as Map).cast<String, dynamic>();
      return _LessonItem(
        id: (m["_id"] ?? "").toString(),
        title: (m["title"] ?? "Untitled").toString(),
        desc: (m["description"] ?? "").toString(),
        progress: 0.0,
        correctnessPercent: 0, // default
      );
    }).toList();

    // 2) For each lesson, fetch completion for THIS user and attach correctness_rate
    //    Your backend returns correctness_rate as percentage (0..100)
    final updated = await Future.wait(lessons.map((lesson) async {
      try {
        final res = await CompleteDrawingLessonService.getCompletedByLessonAndUser(
          lessonId: lesson.id,
          userId: hardcodedUserId,
        );

        final data = res["data"];

        // data should be a List (possibly empty)
        if (data is List && data.isNotEmpty) {
          final latest = (data.first as Map).cast<String, dynamic>();

          final cr = latest["correctness_rate"]; // stored as percent (e.g., 76)
          final percent = (cr is num) ? cr.round() : int.tryParse("$cr") ?? 0;

          // convert to progress 0..1 for pill
          final progress = (percent / 100.0).clamp(0.0, 1.0);

          return lesson.copyWith(
            progress: progress,
            correctnessPercent: percent.clamp(0, 100),
          );
        }

        // no completion record -> 0
        return lesson;
      } catch (_) {
        // if request fails for this lesson, don't break whole screen
        return lesson;
      }
    }));

    return updated;
  }

  Future<void> _refresh() async {
    setState(() {
      _futureLessons = _fetchLessons();
    });
    await _futureLessons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrawingUnit1Page.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 5,
            ),

            // ===== Top row: palette + title + add =====
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(
                children: [
                  Image.asset(
                    "assets/drawing_palette.png",
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.palette_rounded,
                      size: 22,
                      color: DrawingUnit1Page.topRowBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Drawing UNIT 1",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DrawingUnit1Page.topRowBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _CircleActionButton(
                    icon: Icons.add,
                    onTap: () {
                      Navigator.pushNamed(context, '/skillSelection');
                    },
                  ),
                ],
              ),
            ),

            // ===== List =====
            Expanded(
              child: FutureBuilder<List<_LessonItem>>(
                future: _futureLessons,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 28),
                            const SizedBox(height: 10),
                            Text(
                              "Failed to load lessons.\n${snapshot.error}",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text("Try again"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final lessons = snapshot.data ?? [];

                  if (lessons.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 30),
                            const SizedBox(height: 10),
                            const Text(
                              "No drawing lessons found.",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text("Refresh"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      itemCount: lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = lessons[index];

                        return _LessonCard(
                          title: item.title,
                          desc: item.desc,
                          progress: item.progress,
                          correctnessPercent: item.correctnessPercent,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/drawingLessonDetail',
                              arguments: item.id,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 3),
    );
  }
}

/* ===================== DATA ===================== */

class _LessonItem {
  final String id;
  final String title;
  final String desc;

  // ✅ Progress pill uses 0..1
  final double progress;

  // ✅ Display text uses 0..100
  final int correctnessPercent;

  const _LessonItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.progress,
    required this.correctnessPercent,
  });

  _LessonItem copyWith({
    String? id,
    String? title,
    String? desc,
    double? progress,
    int? correctnessPercent,
  }) {
    return _LessonItem(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      progress: progress ?? this.progress,
      correctnessPercent: correctnessPercent ?? this.correctnessPercent,
    );
  }
}

/* ===================== TOP RIGHT BUTTON ===================== */

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  static const Color bg = DrawingUnit1Page.actionBtnBg;
  static const Color border = DrawingUnit1Page.actionBtnBorder;
  static const Color iconColor = DrawingUnit1Page.actionIcon;

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

/* ===================== LESSON CARD ===================== */

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.title,
    required this.desc,
    required this.onTap,
    required this.progress,
    required this.correctnessPercent,
  });

  final String title;
  final String desc;
  final VoidCallback onTap;

  final double progress; // 0..1
  final int correctnessPercent; // 0..100

  static const Color cardBg = DrawingUnit1Page.cardBg;
  static const Color leftShade = DrawingUnit1Page.leftShade;
  static const Color titleColor = DrawingUnit1Page.titleColor;
  static const Color descColor = DrawingUnit1Page.descColor;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final percent = correctnessPercent.clamp(0, 100);

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

              // ✅ Progress section with percent text
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProgressPill(progress: p),
                    const SizedBox(height: 4),
                    Text(
                      "$percent%",
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8C6B55),
                      ),
                    ),
                  ],
                ),
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
    return SizedBox(
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
    );
  }
}
