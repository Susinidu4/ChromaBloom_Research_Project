import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class WellnessRecommendationDetailPage extends StatelessWidget {
  const WellnessRecommendationDetailPage({super.key});

  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color gold = Color(0xFFBD9A6B);

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
              notificationCount: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                child: Center(
                  child: _RecommendationCard(
                    title: "Deep Breath Pause",
                    durationText: "1 min",
                    description:
                        "Take a few deep breaths to clear\nyour mind and calm your body\nbefore reacting.",
                    steps: const [
                      "Inhale slowly for 4s",
                      "Exhale for 4s",
                      "Repeat 4 – 5 times",
                    ],
                    imagePath:
                        "assets/recomendation_1.png", // change to your asset
                    onDone: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 0),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String title;
  final String durationText;
  final String description;
  final List<String> steps;
  final String imagePath;
  final VoidCallback onDone;

  const _RecommendationCard({
    required this.title,
    required this.durationText,
    required this.description,
    required this.steps,
    required this.imagePath,
    required this.onDone,
  });

  static const Color gold = Color(0xFFBD9A6B);
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color innerBg = Color(0xFFE9DDCC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: innerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold, width: 1.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // title row + duration
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: gold,
                    ),
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.timer_outlined, size: 18, color: gold),
                    SizedBox(width: 6),
                  ],
                ),
                Text(
                  durationText,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: gold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              description,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: gold,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "STEPS:",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: gold,
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 20), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(steps.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${i + 1}. ",
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: gold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            steps[i],
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: gold,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // illustration row (bubble + character)
            SizedBox(
              height: 170,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: 50,
                    bottom: 0,
                    child: SizedBox(
                      width: 153,
                      height: 153,
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Center(
              child: SizedBox(
                width: 105,
                height: 38,
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    elevation: 22,
                    shadowColor: const Color(0x55000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

