import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class UnitStartPage extends StatelessWidget {
  const UnitStartPage({super.key});

  static const Color pageBg = Color(0xFFF3E8E8);

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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    _BackCircleButton(
                      onTap: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          const Text(
                            "Okay ! Let's start with Learning",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA07E6A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 26),

                          Image.asset(
                            "assets/unit_start.png",
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              height: 220,
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                "Illustration Missing",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          _PrimaryButton(
                            label: "Continue",
                            onTap: () {
                              // ✅ Go to drawing unit 1
                              Navigator.pushReplacementNamed(context, '/drawingUnit1');
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F2E8),
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
            size: 28,
            color: Color(0xFFB0896E),
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
          width: 110,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFB89A76),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
