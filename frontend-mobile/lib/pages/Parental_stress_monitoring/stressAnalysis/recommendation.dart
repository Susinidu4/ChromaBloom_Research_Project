import 'package:flutter/material.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import 'package:quickalert/quickalert.dart';
import '../../../services/Parental_stress_monitoring/recommendation_service.dart';
import '../journalEntry/create_journalEntry.dart';

class WellnessRecommendationDetailPage extends StatefulWidget {
  final String caregiverId;

  const WellnessRecommendationDetailPage({
    super.key,
    required this.caregiverId,
  });

  static const Color pageBg = Color(0xFFF3E8E8);

  @override
  State<WellnessRecommendationDetailPage> createState() =>
      _WellnessRecommendationDetailPageState();
}

class _WellnessRecommendationDetailPageState
    extends State<WellnessRecommendationDetailPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = WellnessRecommendationService.fetchRecommendation(
      widget.caregiverId,
    );
  }

  bool _handledError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WellnessRecommendationDetailPage.pageBg,
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
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    if (!_handledError) {
                      _handledError = true;

                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (!mounted) return;

                        await QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: "Journal Needed",
                          text:
                              "You haven't created a journal entry for today.\nPlease create it to get recommendations.",
                          confirmBtnText: "Create Journal",
                          cancelBtnText: "Cancel",
                          showCancelBtn: true,
                          confirmBtnColor: const Color(0xFFBD9A6B),
                          barrierDismissible: false,

                          // ✅ IMPORTANT: do navigation AFTER closing dialog
                          onConfirmBtnTap: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(); // close alert

                            // ✅ Navigate directly (avoids named-route + nested navigator issues)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateJournalEntryScreen(),
                              ),
                            );
                          },

                          onCancelBtnTap: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(); // close alert
                            Navigator.pop(
                              context,
                            ); // go back from recommendation page
                          },
                        );
                      });
                    }

                    return const Center(
                      child: Text(
                        "Unable to load recommendation",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  final data = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                    child: Center(
                      child: _RecommendationCard(
                        title: data["title"],
                        durationText: "${data["duration"]} min",
                        description: data["message"],
                        steps: List<String>.from(data["steps"]),
                        imagePath: "assets/recomendation_1.png",
                        onDone: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
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
