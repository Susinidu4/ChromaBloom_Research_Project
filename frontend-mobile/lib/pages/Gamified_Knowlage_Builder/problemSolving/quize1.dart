import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class ProblemSolvingMatchPage extends StatefulWidget {
  const ProblemSolvingMatchPage({super.key});

  @override
  State<ProblemSolvingMatchPage> createState() => _ProblemSolvingMatchPageState();
}

class _ProblemSolvingMatchPageState extends State<ProblemSolvingMatchPage> {
  // UI palette (match your screenshots)
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

  // Demo state
  int? selectedIndex;

  // You can replace these with your real images
  final List<String> optionAssets = const [
    "assets/options/apple.png",
    "assets/options/banana.png",
    "assets/options/leaf.png",
    "assets/options/mango.png",
  ];

  final String mainImageAsset = "assets/main/banana_big.png";

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

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
                    // ===== Top line (icon + title) =====
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
                        const SizedBox(width: 22), // keeps title centered
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ===== Lesson title =====
                    const Text(
                      "Match the Similar Objects",
                      style: TextStyle(
                        color: titleBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ===== Progress bar (short, centered) =====
                    Center(
                      child: SizedBox(
                        width: w * 0.52,
                        child: const _ThinProgressBar(value: 0.32),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== Big word =====
                    const Center(
                      child: Text(
                        "BANANA",
                        style: TextStyle(
                          color: wordBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ===== Main image =====
                    Center(
                      child: Image.asset(
                        mainImageAsset,
                        height: 170,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 170,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "Main image missing",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== Options row (4 tiles) =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (i) {
                        return _OptionTile(
                          asset: optionAssets[i],
                          isSelected: selectedIndex == i,
                          onTap: () => setState(() => selectedIndex = i),
                        );
                      }),
                    ),

                    const SizedBox(height: 18),

                    // ===== Continue button (small centered) =====
                    Center(
                      child: _PrimaryButton(
                        label: "Continue",
                        onTap: () {
                          // TODO: validate answer then go next
                          // Navigator.pushNamed(context, '/next');
                        },
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

/* ===================== PROGRESS ===================== */

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
            FractionallySizedBox(
              widthFactor: v,
              child: Container(color: fill),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== OPTION TILE ===================== */

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.asset,
    required this.onTap,
    required this.isSelected,
  });

  final String asset;
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
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 56,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? const Color(0xFFB89A76) : border,
              width: isSelected ? 1.6 : 1.1,
            ),
            boxShadow: const [
              BoxShadow(
                color: _ProblemSolvingMatchPageState.optionShadow,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Image.asset(
            asset,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              size: 22,
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== CONTINUE BUTTON ===================== */

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

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
