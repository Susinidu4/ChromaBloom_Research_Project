import 'package:flutter/material.dart';

class OnboardScreen1 extends StatelessWidget {
  const OnboardScreen1({super.key});

  // Colors close to your screenshot
  static const Color bgBlue = Color(0xFF386884);
  static const Color cardBlue = Color(0xFF386884);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // White curved wave background
            Positioned.fill(
              child: CustomPaint(
                painter: _TopWavePainter(waveColor: Colors.white),
              ),
            ),

            // Family image (center-top)
            Positioned(
              top: h * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: w * 0.65,
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.asset(
                      "assets/onboard_1.png",
                      fit: BoxFit.contain,

                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          "Missing asset:\nassets/onboard_1.png",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom card area
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                decoration: const BoxDecoration(
                  color: cardBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      "What is ChromaBloom ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF3E8E8),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "ChromaBloom is a personalized AI-\npowered mobile platform designed\n"
                      "to support children with Down\nsyndrome and empower their\ncaregivers.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF3E8E8),
                        fontSize: 16,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Dots (3 dots, middle active like screenshot)
                    const _DotsIndicator(
                      count: 3,
                      activeIndex: 0,
                      activeColor: Color(0xFFD3E7EE),
                      inactiveColor: Color(0xFF1D2B34),
                    ),

                    const SizedBox(height: 26),

                    // Skip + Next
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/get_started');
                          },
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: Color(0xFFF3E8E8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/onboard2');
                          },
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD3E7EE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 34,
                            ),
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
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.activeIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int activeIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _TopWavePainter extends CustomPainter {
  _TopWavePainter({required this.waveColor});
  final Color waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    // White wave shape
    final wavePath = Path()
      ..moveTo(0, size.height * 0.26)
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.001,
        size.width ,
        size.height * 0.26,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // 1) Draw the white area first
    canvas.drawPath(wavePath, Paint()..color = waveColor);

    // 2) INNER shadow: clip to white area and draw a blurred stroke on the curve
    canvas.save();
    canvas.clipPath(wavePath);

    final curveOnly = Path()
      ..moveTo(0, size.height * 0.26)
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.001,
        size.width,
        size.height * 0.26,
      );

    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20 // thickness of the soft shadow band
      ..color = Colors.black.withOpacity(0.90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    // move the shadow slightly DOWN so it appears just under the curve (inside white)
    canvas.translate(0, 6);
    canvas.drawPath(curveOnly, innerShadowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

