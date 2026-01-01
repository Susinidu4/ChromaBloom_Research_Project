import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../others/header.dart';
import '../../others/navBar.dart';
import '../../../services/Gemified/drawing_lesson_service.dart';

// ✅ one import works on both platforms (conditional)
import '../../../widgets/hybrid_video_player/hybrid_video_player.dart';

class DrawingLessonDetailPage extends StatefulWidget {
  const DrawingLessonDetailPage({super.key});

  static const Color pageBg = Color(0xFFF5ECEC);

  static const Color topRowBlue = Color(0xFF3D6B86);

  static const Color bubbleBg = Color(0xFFF8F2E8);
  static const Color bubbleIcon = Color(0xFFB0896E);

  static const Color tipCardBg = Color(0xFFE9DDCC);
  static const Color titleColor = Color(0xFFA07E6A);
  static const Color bodyColor = Color(0xFFB79B86);

  static const Color buttonBg = Color(0xFFB89A76);

  @override
  State<DrawingLessonDetailPage> createState() => _DrawingLessonDetailPageState();
}

class _DrawingLessonDetailPageState extends State<DrawingLessonDetailPage> {
  late final DrawingLessonService _service;
  Future<Map<String, dynamic>>? _futureLesson;

  @override
  void initState() {
    super.initState();

    // ✅ baseUrl depends on platform
    final apiBase = kIsWeb
        ? "http://localhost:5000/chromabloom/drawing-lessons"
        : "http://localhost:5000/chromabloom/drawing-lessons";

    _service = DrawingLessonService(
      baseUrl: apiBase,
      // token: "YOUR_JWT_IF_NEEDED",
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    final lessonId = args?.toString() ?? "";

    if (lessonId.isNotEmpty && _futureLesson == null) {
      _futureLesson = _service.getLessonById(lessonId);
    }
  }

  String _tipsToText(dynamic tips) {
    if (tips == null) return "No tips available.";
    if (tips is List) {
      if (tips.isEmpty) return "No tips available.";
      final lines = <String>[];
      for (int i = 0; i < tips.length; i++) {
        lines.add("${i + 1}. ${tips[i].toString()}");
      }
      return lines.join("\n\n");
    }
    return tips.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrawingLessonDetailPage.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 5,
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _futureLesson,
                builder: (context, snapshot) {
                  if (_futureLesson == null) {
                    return const Center(child: Text("Lesson ID not provided."));
                  }
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
                              "Failed to load lesson.\n${snapshot.error}",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final lesson = snapshot.data ?? {};
                  final title = (lesson["title"] ?? "Untitled").toString();
                  final description = (lesson["description"] ?? "").toString();
                  final videoUrl = (lesson["video_url"] ?? "").toString();
                  final tipsText = _tipsToText(lesson["tips"]);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _BackCircleButton(
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: DrawingLessonDetailPage.topRowBlue,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              height: 1.25,
                            ),
                          ),

                        const SizedBox(height: 12),

                        // ✅ Hybrid player: web uses <video>, mobile uses video_player
                        HybridVideoPlayer(videoUrl: videoUrl, height: 180),

                        const SizedBox(height: 14),

                        _TipCard(
                          tipText: tipsText,
                          onContinue: () {},
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 2),
    );
  }
}

/* ===================== BACK BUTTON ===================== */

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: DrawingLessonDetailPage.bubbleBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 26,
            color: DrawingLessonDetailPage.bubbleIcon,
          ),
        ),
      ),
    );
  }
}

/* ===================== TIP CARD ===================== */

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tipText,
    required this.onContinue,
  });

  final String tipText;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: DrawingLessonDetailPage.tipCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tip",
            style: TextStyle(
              color: DrawingLessonDetailPage.titleColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Image.asset(
              "assets/tip_illustration.png",
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Tip illustration missing",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tipText,
            style: const TextStyle(
              color: DrawingLessonDetailPage.bodyColor,
              fontSize: 9.6,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: _PrimaryButton(
              label: "Continue",
              onTap: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== BUTTON ===================== */

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: DrawingLessonDetailPage.buttonBg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
