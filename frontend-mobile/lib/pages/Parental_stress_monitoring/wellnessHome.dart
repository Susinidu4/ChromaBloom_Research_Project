import 'package:flutter/material.dart';

// ✅ import your shared widgets (update paths to match your folders)
import '../../pages/others/header.dart';
import '../../pages/others/navBar.dart';

/// File: wellnessHome.dart
/// Screen: Wellness Home (WITH header + bottom nav bar)

class WellnessHomeScreen extends StatelessWidget {
  const WellnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UiColors.pageBg,

      body: SafeArea(
        child: Column(
          children: [
            // ✅ HEADER (no gradient here)
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 5,
            ),

            
            // ✅ CONTENT AREA WITH GRADIENT
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _UiColors.bgTop,
                      _UiColors.pageBg,
                      _UiColors.pageBg,
                      _UiColors.pageBg,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Quote section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              _UiAssets.brainIcon,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "“It’s okay not be okay, as long\nas you are not giving up”",
                              style: _UiText.quote.copyWith(
                                color: _UiColors.textSoft,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      _SuggestionCard(onView: () {}),

                      const SizedBox(height: 28),

                      Text(
                        "Let’s dive more...",
                        style: _UiText.sectionTitle.copyWith(
                          color: _UiColors.sectionText,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              title: "Your Stress\nAnalysis",
                              imageAsset: _UiAssets.stressCardImg,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _FeatureCard(
                              title: "Journal\nEntry",
                              imageAsset: _UiAssets.journalCardImg,
                              onTap: () {
                                Navigator.pushNamed(context, '/displayJournalEntry');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ Bottom NavBar (stays fixed)
      bottomNavigationBar: const MainNavBar(currentIndex: 0),
    );
  }
}

/* ===================== WIDGETS ===================== */

class _SuggestionCard extends StatelessWidget {
  final VoidCallback onView;

  const _SuggestionCard({required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: _UiColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _UiColors.cardBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 8),
            color: Color(0x1A000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today’s Suggestion\nto release your\nheavy mind",
                  style: _UiText.cardTitle.copyWith(
                    color: _UiColors.cardTitleText,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _UiColors.btnBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: _UiColors.btnBg,
                    ),
                    child: Text(
                      "View",
                      style: _UiText.button.copyWith(color: _UiColors.btnText),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 0,
            child: SizedBox(
              width: 150,
              child: Image.asset(
                _UiAssets.suggestionIllustration,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.favorite_rounded,
                  size: 72,
                  color: _UiColors.blueGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: const Color(0xFFE9DDCC),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              spreadRadius: 1,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: _UiText.featureTitle.copyWith(
                color: _UiColors.featureTitleText,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: 120,
                child: Image.asset(imageAsset, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== STYLES ===================== */

class _UiColors {
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color bgTop = Color(0xFFF7EAD7);

  static const Color blueGrey = Color(0xFF6B8192);
  static const Color textSoft = Color(0xFFBD9A6B);

  static const Color cardBg = Color(0xFFF3E8E8);
  static const Color cardBorder = Color(0xFFBD9A6B);
  static const Color cardTitleText = Color(0xFFC6A477);

  static const Color btnBorder = Color(0xFFBD9A6B);
  static const Color btnBg = Color(0xFFF3E8E8);
  static const Color btnText = Color(0xFFBD9A6B);

  static const Color sectionText = Color(0xFFBD9A6B);

  static const Color featureBg = Color(0xFFE9DDCC);
  static const Color featureTitleText = Color(0xFFBD9A6B);
}

class _UiText {
  static const TextStyle quote = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle featureTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );
}

/* ===================== ASSETS ===================== */

class _UiAssets {
  static const String brainIcon = "assets/wellness_banner.png";
  static const String suggestionIllustration = "assets/recomendation_card.png";
  static const String stressCardImg = "assets/stress_analyze_card.png";
  static const String journalCardImg = "assets/Journal_card.png";
}
