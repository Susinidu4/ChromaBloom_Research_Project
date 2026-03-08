import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../state/session_provider.dart';
import '../../../services/Gemified/drawing_level_service.dart';
import '../../../services/Gemified/complete_drawing_lesson_service.dart';
import '../../../services/user_services/child_api.dart';
import '../../../services/api_config.dart';

import '../../../services/Gemified/problem_solving_level.dart';
import '../../../services/Gemified/complete_problem_solving_session_service.dart';
import '../../../services/Gemified/problem_solving_lesson_service.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

class SkillSelectionPage extends StatefulWidget {
  const SkillSelectionPage({super.key});

  static const Color pageBg = Color(0xFFF3E8E8);

  @override
  State<SkillSelectionPage> createState() => _SkillSelectionPageState();
}

class _SkillSelectionPageState extends State<SkillSelectionPage> {
  // Existing drawing key
  static const String _prefKeyDrawingLevelSet = "drawing_skill_level_set";

  // ✅ New problem solving keys
  static const String _prefKeyProblemLevelSet = "problem_solving_skill_level_set";

  Future<void> _handleDrawingTap() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final session = Provider.of<SessionProvider>(context, listen: false);
      final caregiverProps = session.caregiver;
      if (caregiverProps == null) throw Exception("No caregiver session found");

      final caregiverId = (caregiverProps['_id'] ?? caregiverProps['id'] ?? "").toString();
      if (caregiverId.isEmpty) throw Exception("Caregiver ID not found");

      // 1. Get child ID
      final List<dynamic> children = await ChildApi.getChildrenByCaregiver(caregiverId);
      if (children.isEmpty) {
        Navigator.pushNamed(context, '/skillKnowlageLevel');
        return;
      }
      final childId = (children[0]['_id'] ?? children[0]['id'] ?? "").toString();

      // 2. Fetch drawing level data
      final drawingLevelService = DrawingLevelService(
        baseUrl: "${ApiConfig.baseUrl}/chromabloom/drawing-levels",
        token: session.token,
      );
      final List<dynamic> levels = await drawingLevelService.getDrawingLevelByUserId(childId);
      
      if (levels.isEmpty) {
        Navigator.pushNamed(context, '/skillKnowlageLevel');
        return;
      }

      final currentLevelData = levels[0];
      final String currentLevel = (currentLevelData['level'] ?? "Beginner").toString();

      // 3. Level progression logic
      if (currentLevel != "Advanced") {
        // Fetch completed lessons for average calculation
        final res = await CompleteDrawingLessonService.getCompletedLessonsByUser(childId);
        final data = res["data"];

        if (data is List && data.isNotEmpty) {
          // Take first 10 data
          final lessonsToAverage = data.take(10).toList();
          
          if (lessonsToAverage.length == 10) {
            double totalCorrectness = 0;
            for (var lesson in lessonsToAverage) {
              final rate = lesson['correctness_rate'] ?? 0.0;
              totalCorrectness += (rate is num) ? rate.toDouble() : 0.0;
            }

            double average = (totalCorrectness / lessonsToAverage.length) * 100;

            if (average >= 60) {
              String nextLevel = "";
              if (currentLevel == "Beginner") {
                nextLevel = "Intermediate";
              } else if (currentLevel == "Intermediate") {
                nextLevel = "Advanced";
              }

              if (nextLevel.isNotEmpty) {
                // Update the drawing level
                await drawingLevelService.updateLevelByUserId(
                  userId: childId,
                  level: nextLevel,
                );
                
                // Update local preferences
                await prefs.setBool(_prefKeyDrawingLevelSet, true);
                await prefs.setString("drawing_skill_level_value", nextLevel);
                

              }
            }
          }
        }
      }

      if (!mounted) return;
      Navigator.pushNamed(context, '/drawingUnit1');

    } catch (e) {
      debugPrint("Error in handleDrawingTap: $e");
      final bool levelSet = prefs.getBool(_prefKeyDrawingLevelSet) ?? false;
      if (!mounted) return;
      if (!levelSet) {
        Navigator.pushNamed(context, '/skillKnowlageLevel');
      } else {
        Navigator.pushNamed(context, '/drawingUnit1');
      }
    }
  }

  // ✅ NEW: Problem solving logic with progression
  Future<void> _handleProblemSolvingTap() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final session = Provider.of<SessionProvider>(context, listen: false);
      final caregiverProps = session.caregiver;
      if (caregiverProps == null) throw Exception("No caregiver session found");

      final caregiverId = (caregiverProps['_id'] ?? caregiverProps['id'] ?? "").toString();
      if (caregiverId.isEmpty) throw Exception("Caregiver ID not found");

      // 1. Get child ID
      final List<dynamic> children = await ChildApi.getChildrenByCaregiver(caregiverId);
      if (children.isEmpty) {
        // No child found, fallback to initial selection screen
        Navigator.pushNamed(context, '/skillKnowlageLevel_2');
        return;
      }
      final childId = (children[0]['_id'] ?? children[0]['id'] ?? "").toString();

      // 2. Fetch current problem solving level from backend
      Map<String, dynamic> levelData;
      try {
        levelData = await ProblemSolvingLevelService.getLevelByUserId(childId);
      } catch (e) {
        // If level entry doesn't exist, go to selection screen
        Navigator.pushNamed(context, '/skillKnowlageLevel_2');
        return;
      }

      final String currentLevel = (levelData['level'] ?? "Beginner").toString();

      // 3. Level progression logic (Only if not already Advanced)
      if (currentLevel.toLowerCase() != "advanced" && currentLevel.toLowerCase() != "advance") {
        
        // Fetch all completed problem solving sessions for this child
        final res = await CompleteProblemSolvingSessionService.getCompletedSessionsByUser(childId);
        final List<dynamic> allCompletedSessions = res["data"] ?? [];

        if (allCompletedSessions.isNotEmpty) {
          // We need to know the difficulty of each lesson to filter sessions by current level
          final List<dynamic> allLessons = await ProblemSolvingLessonService.getAllLessons();
          final Map<String, String> lessonDifficultyMap = {
            for (var l in allLessons) 
              (l['_id'] ?? l['id']).toString(): (l['difficulty_level'] ?? "").toString()
          };

          // Filter sessions: Only those that match the child's CURRENT level
          final List<dynamic> sessionsAtCurrentLevel = allCompletedSessions.where((session) {
            final lessonId = (session['lessons'] is Map) 
              ? (session['lessons']['_id'] ?? session['lessons']['id']).toString()
              : session['lessons'].toString();
            final lessonDiff = lessonDifficultyMap[lessonId] ?? "";
            return lessonDiff.toLowerCase() == currentLevel.toLowerCase();
          }).toList();

          // REQUIREMENT: Must have completed at least 10 lessons (sessions) at this level
          // The backend returns sessions sorted by newest first, so we take the 10 most recent.
          final sessionsToAnalyze = sessionsAtCurrentLevel.take(10).toList();
          
          if (sessionsToAnalyze.length == 10) {
            double totalCorrectness = 0;
            for (var session in sessionsToAnalyze) {
              final score = session['correctness_score'] ?? 0.0;
              totalCorrectness += (score is num) ? score.toDouble() : 0.0;
            }

            // Calculate percentage average (assuming score is 0..1 scale)
            double averagePercent = (totalCorrectness / sessionsToAnalyze.length) * 100;

            // REQUIREMENT: Average correctness must be >= 60%
            if (averagePercent >= 60) {
              String nextLevel = "";
              if (currentLevel.toLowerCase() == "beginner") {
                nextLevel = "Intermediate";
              } else if (currentLevel.toLowerCase() == "intermediate") {
                nextLevel = "Advanced";
              }

              if (nextLevel.isNotEmpty) {
                // Update the problem solving level in backend
                await ProblemSolvingLevelService.updateLevelByUserId(
                  userId: childId,
                  level: nextLevel,
                );
                
                // Keep local preference in sync
                await prefs.setBool(_prefKeyProblemLevelSet, true);
                await prefs.setString("problem_solving_skill_level_value", nextLevel);
                

              }
            }
          }
        }
      }


      if (!mounted) return;
      // Navigate to the lessons page (will now show lessons for the potentially updated level)
      Navigator.pushNamed(context, '/problemSolvingLessons');

    } catch (e) {
      debugPrint("Error in handleProblemSolvingTap: $e");
      // Fallback navigate to lessons if preferences exist, otherwise to level selection
      final bool levelSet = prefs.getBool(_prefKeyProblemLevelSet) ?? false;
      if (!mounted) return;
      if (!levelSet) {
        Navigator.pushNamed(context, '/skillKnowlageLevel_2');
      } else {
        Navigator.pushNamed(context, '/problemSolvingLessons');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkillSelectionPage.pageBg,
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: LearnContent(
                  onTapDrawing: _handleDrawingTap,
                  onTapProblemSolving: _handleProblemSolvingTap, // ✅ changed
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

/* ===================== BODY CONTENT ===================== */

class LearnContent extends StatelessWidget {
  const LearnContent({
    super.key,
    required this.onTapDrawing,
    required this.onTapProblemSolving,
  });

  final VoidCallback onTapDrawing;
  final VoidCallback onTapProblemSolving;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(height: 6),

        // ---- Illustration + speech bubble ----
        SizedBox(
          height: 360,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 26,
                right: 72,
                child: _SpeechBubble(
                  maxWidth: w * 0.60,
                  text: "What would you like to\nLearn ?",
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "assets/GSelection.png",
                  height: 290,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 290,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "GSelection image not found",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        _LearnTile(
          width: w * 0.88,
          title: "Drawing Tutorial",
          iconAsset: "assets/drawing_palette.png",
          fallbackIcon: Icons.palette_rounded,
          onTap: onTapDrawing,
        ),

        const SizedBox(height: 14),

        _LearnTile(
          width: w * 0.88,
          title: "Problem Solving Tutorial",
          iconAsset: "assets/problem-solving.png",
          fallbackIcon: Icons.psychology_alt_rounded,
          onTap: onTapProblemSolving,
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _LearnTile extends StatelessWidget {
  const _LearnTile({
    required this.width,
    required this.title,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.onTap,
  });

  final double width;
  final String title;
  final String iconAsset;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color leftShade = Color(0xFFDFC7A7);
  static const Color textColor = Color(0xFFBD9A6B);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: width,
            height: 64,
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
            child: Stack(
              children: [
                Positioned.fill(
                  left: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 10,
                      decoration: const BoxDecoration(
                        color: leftShade,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 26),
                    Center(
                      child: Image.asset(
                        iconAsset,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          fallbackIcon,
                          size: 32,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== SPEECH BUBBLE ===================== */

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.maxWidth,
  });

  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F2E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8C6B4), width: 1.1),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 6),
                color: Color(0x1A000000),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB0896E),
              height: 1.15,
            ),
          ),
        ),
        Positioned(
          bottom: -13,
          left: 26,
          child: CustomPaint(
            size: const Size(22, 14),
            painter: _BubbleTailPainter(
              fill: const Color(0xFFF8F2E8),
              stroke: const Color(0xFFD8C6B4),
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.3, size.height)
      ..close();

    final paintFill = Paint()..color = fill;
    final paintStroke = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawPath(path, paintFill);
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
