import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Gamified_Knowlage_Builder/problemSolving/problemSComplete.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';
import '../../../services/Gemified/problem_solving_lesson_service.dart';
import '../../../services/Gemified/quize_service.dart';

class ProblemSolvingMatchPage extends StatefulWidget {
  const ProblemSolvingMatchPage({super.key});

  @override
  State<ProblemSolvingMatchPage> createState() => _ProblemSolvingMatchPageState();
}

class _ProblemSolvingMatchPageState extends State<ProblemSolvingMatchPage> {
  // UI palette
  static const Color pageBg = Color(0xFFF5ECEC);
  static const Color topRowBlue = Color(0xFF3D6B86);

  static const Color track = Color(0xFFD8D1C7);
  static const Color fill = Color(0xFFB89A76);

  static const Color titleBlack = Color(0xFF111111);
  static const Color wordBlue = Color(0xFF3D6B86);

  static const Color optionBorder = Color(0xFFCDB9A7);
  static const Color optionBg = Color(0xFFF8F2E8);
  static const Color optionShadow = Color(0x22000000);

  static const Color btnBg = Color(0xFFB89A76);

  // state
  bool _loading = true;
  String? _error;

  String _lessonTitle = "Lesson Title";
  String? _lessonId;

  // quiz flow
  final List<String> _levels = const ["Beginner", "Intermediate", "Advanced"];
  int _stepIndex = 0; // 0->Beginner, 1->Intermediate, 2->Advanced
  int _correctCount = 0;

  QuizItem? _currentQuiz;

  /// answers have image_no 1..4 in your backend
  int? _selectedImageNo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_lessonId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args["lessonId"] != null) {
        _lessonId = args["lessonId"].toString();
        _init();
      } else {
        setState(() {
          _loading = false;
          _error = "Lesson ID not provided";
        });
      }
    }
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
      _stepIndex = 0;
      _correctCount = 0;
      _selectedImageNo = null;
      _currentQuiz = null;
    });

    try {
      await _loadLessonTitle();
      await _loadQuizForStep();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadLessonTitle() async {
    final res = await ProblemSolvingLessonService.getLessonById(_lessonId!);
    final data = res["data"] as Map<String, dynamic>?;
    if (data == null) throw Exception("Lesson data not found");

    final title = (data["title"] ?? "").toString().trim();
    _lessonTitle = title.isEmpty ? "Lesson Title" : title;
  }

  Future<void> _loadQuizForStep() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedImageNo = null;
      _currentQuiz = null;
    });

    final list = await QuizeService.getQuizeByLessonId(_lessonId!);
    final quizzes =
        list.map((e) => QuizItem.fromJson(e as Map<String, dynamic>)).toList();

    final level = _levels[_stepIndex];

    // filter by difficulty (case-insensitive)
    final candidates = quizzes
        .where((q) => q.difficultyLevel.toLowerCase() == level.toLowerCase())
        .toList();

    if (candidates.isEmpty) {
      throw Exception("No quiz found for level: $level (lesson: $_lessonId)");
    }

    final rnd = Random();
    final picked = candidates[rnd.nextInt(candidates.length)];

    setState(() {
      _currentQuiz = picked;
      _loading = false;
    });
  }

  double _progressValue() {
    final v = (_stepIndex + 1) / 3.0;
    return v.clamp(0.0, 1.0);
  }

  String _safeUpper(String s) => s.trim().isEmpty ? "" : s.trim().toUpperCase();

  String? _correctImageUrl() {
    final q = _currentQuiz;
    if (q == null) return null;

    final url = (q.correctImgUrl ?? "").trim();
    if (url.isNotEmpty) return url;

    // fallback (if correct_img_url is missing for some reason)
    final correctNo = q.correctAnswer;
    final match = q.answers.firstWhere(
      (a) => a.imageNo == correctNo,
      orElse: () => QuizAnswer(imageNo: -1, imgUrl: ""),
    );
    if (match.imageNo == -1 || match.imgUrl.trim().isEmpty) return null;
    return match.imgUrl;
  }

  Future<void> _onContinue() async {
    final q = _currentQuiz;
    if (q == null) return;

    if (_selectedImageNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an answer first.")),
      );
      return;
    }

    // check correctness
    if (_selectedImageNo == q.correctAnswer) {
      _correctCount++;
    }

    // next step or finish
    if (_stepIndex < 2) {
      setState(() => _stepIndex++);
      await _loadQuizForStep();
      return;
    }

    // finished (3rd answered)
    final correctness = _correctCount / 3.0;

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProblemSolvingLessonCompletePage(
          lessonId: _lessonId!, 
          correctness: correctness,
          improvement: 0.62, // replace later if needed
          
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final quiz = _currentQuiz;
    final levelLabel = _levels[_stepIndex];
    final correctUrl = _correctImageUrl();

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top line
                    Row(
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
                        const SizedBox(width: 22),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Lesson title + level label
                    Text(
                      _lessonTitle,
                      style: const TextStyle(
                        color: titleBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Level: $levelLabel",
                      style: const TextStyle(
                        color: topRowBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Progress bar
                    Center(
                      child: SizedBox(
                        width: w * 0.52,
                        child: _ThinProgressBar(value: _progressValue()),
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _PrimaryButton(label: "Retry", onTap: _init),
                        ],
                      )
                    else if (quiz == null)
                      const Text("No quiz loaded.")
                    else
                      Column(
                        children: [
                          // big word (name_tag)
                          Center(
                            child: Text(
                              _safeUpper(quiz.nameTag),
                              style: const TextStyle(
                                color: wordBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // question
                          Center(
                            child: Text(
                              quiz.question.trim(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: titleBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: _NetworkMainImage(
                              url: correctUrl,
                              height: 170,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Options = all answers below in a 2x2 grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.25,
                            children: quiz.answers.map((a) {
                              return _OptionTileNetwork(
                                url: a.imgUrl,
                                isSelected: _selectedImageNo == a.imageNo,
                                onTap: () => setState(
                                    () => _selectedImageNo = a.imageNo),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 18),

                          Center(
                            child: _PrimaryButton(
                              label: "Continue",
                              onTap: _onContinue,
                            ),
                          ),
                        ],
                      ),
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

/* MODELS */


class QuizItem {
  final String id;
  final String question;
  final String lessonId;
  final String nameTag;
  final String difficultyLevel;

  final String? correctImgUrl;

  final int correctAnswer;
  final List<QuizAnswer> answers;

  QuizItem({
    required this.id,
    required this.question,
    required this.lessonId,
    required this.nameTag,
    required this.difficultyLevel,
    required this.correctAnswer,
    required this.answers,
    this.correctImgUrl,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    final ans = (json["answers"] as List<dynamic>? ?? [])
        .map((e) => QuizAnswer.fromJson(e as Map<String, dynamic>))
        .toList();

    return QuizItem(
      id: (json["_id"] ?? "").toString(),
      question: (json["question"] ?? "").toString(),
      lessonId: (json["lesson_id"] ?? "").toString(),
      nameTag: (json["name_tag"] ?? "").toString(),
      difficultyLevel: (json["difficulty_level"] ?? "").toString(),
      correctImgUrl: (json["correct_img_url"] ?? "").toString(),
      correctAnswer: int.tryParse((json["correct_answer"] ?? 0).toString()) ?? 0,
      answers: ans,
    );
  }
}

class QuizAnswer {
  final int imageNo;
  final String imgUrl;

  QuizAnswer({required this.imageNo, required this.imgUrl});

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      imageNo: int.tryParse((json["image_no"] ?? 0).toString()) ?? 0,
      imgUrl: (json["img_url"] ?? "").toString(),
    );
  }
}

/* PROGRESS */

class _ThinProgressBar extends StatelessWidget {
  const _ThinProgressBar({required this.value});
  final double value;

  static const Color track = _ProblemSolvingMatchPageState.track;
  static const Color fill = _ProblemSolvingMatchPageState.fill;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return SizedBox(
      height: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(widthFactor: v, child: Container(color: fill)),
          ],
        ),
      ),
    );
  }
}

class _NetworkMainImage extends StatelessWidget {
  const _NetworkMainImage({required this.url, required this.height});
  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "Correct image missing",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url!,
        height: height,
        width: double.infinity,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            "Failed to load image",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}


class _OptionTileNetwork extends StatelessWidget {
  const _OptionTileNetwork({
    required this.url,
    required this.onTap,
    required this.isSelected,
  });

  final String url;
  final VoidCallback onTap;
  final bool isSelected;

  static const Color border = _ProblemSolvingMatchPageState.optionBorder;
  static const Color bg = _ProblemSolvingMatchPageState.optionBg;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFB89A76) : border,
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0x33B89A76)
                    : _ProblemSolvingMatchPageState.optionShadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            },
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              size: 30,
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const Color btnBg = _ProblemSolvingMatchPageState.btnBg;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 30,
          width: 92,
          decoration: BoxDecoration(
            color: btnBg,
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
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
