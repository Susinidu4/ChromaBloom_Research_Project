import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class DrawingImprovementCheckPage extends StatelessWidget {
  const DrawingImprovementCheckPage({super.key});

  static const Color pageBg = Color(0xFFF5ECEC);

  static const Color topRowBlue = Color(0xFF3D6B86);
  static const Color bubbleBg = Color(0xFFF8F2E8);
  static const Color bubbleIcon = Color(0xFFB0896E);

  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color leftShade = Color(0xFFD6BFA6);
  static const Color titleColor = Color(0xFFA07E6A);

  static const Color uploadBorder = Color(0xFFD8C6B4);
  static const Color uploadIcon = Color(0xFFB0896E);

  static const Color primaryBtnBg = Color(0xFFB89A76);

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
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + centered title
                    Row(
                      children: [
                        _BackCircleButton(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Drawing UNIT 1 Lesson 1",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: topRowBlue,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Page title
                    const Center(
                      child: Text(
                        "Check Child improvement ...",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Illustration
                    Center(
                      child: Image.asset(
                        "assets/child_drawing.png",
                        height: 210,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 210,
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

                    // Upload tile (same family style)
                    _UploadTile(
                      title: "Upload child drawing",
                      onTap: () {
                        // TODO: open image picker / file picker
                      },
                    ),

                    const SizedBox(height: 18),

                    // Complete button (small centered)
                    Center(
                      child: _PrimaryButton(
                        label: "Complete",
                        onTap: () {
                          // TODO: submit + navigate
                        },
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
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
            color: DrawingImprovementCheckPage.bubbleBg,
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
            color: DrawingImprovementCheckPage.bubbleIcon,
          ),
        ),
      ),
    );
  }
}

/* ===================== UPLOAD TILE ===================== */

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  static const Color cardBg = DrawingImprovementCheckPage.cardBg;
  static const Color leftShade = DrawingImprovementCheckPage.leftShade;
  static const Color border = DrawingImprovementCheckPage.uploadBorder;
  static const Color iconColor = DrawingImprovementCheckPage.uploadIcon;
  static const Color textColor = DrawingImprovementCheckPage.titleColor;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: w * 0.88,
            height: 56,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1),
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
                // left strip
                Container(
                  width: 12,
                  decoration: const BoxDecoration(
                    color: leftShade,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                const Icon(Icons.upload_rounded, size: 20, color: iconColor),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(width: 34), // balance right side
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== PRIMARY BUTTON ===================== */

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
          width: 110, // small width like your UI
          height: 32,
          decoration: BoxDecoration(
            color: DrawingImprovementCheckPage.primaryBtnBg,
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
