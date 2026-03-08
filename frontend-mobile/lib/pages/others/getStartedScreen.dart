import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  // Colors
  static const Color pageBg = Color(0xFFFFFFFF);
  static const Color bottomBlue = Color(0xFF386884);
  static const Color gold = Color(0xFFBD9A6B);
  static const Color goldText = Color(0xFFF3E8E8);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    // Bottom card height (tune if needed)
    final bottomPanelH = h * 0.24;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            // 1) Bottom blue panel
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: bottomPanelH,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: bottomBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
              ),
            ),

            // 2) Main content
            Column(
              children: [
                SizedBox(height: h * 0.05),

                // Logo icon + brand text (images)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/chromabloom1.png",
                      height: 160, // ✅ bigger
                      fit: BoxFit.contain,
                    ),

                    // ✅ reduce gap (even if png has padding)
                    Transform.translate(
                      offset: const Offset(
                        0,
                        -50,
                      ), // 🔥 pull UP (adjust -12 to -24)
                      child: Image.asset(
                        "assets/chromabloom2.png",
                        height: 130, // ✅ bigger
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                // Family image area MUST end above the blue panel
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomPanelH + h * 0.02),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Shadow under legs only
                          // Positioned(
                          //   bottom: 0,
                          //   child: Container(
                          //     width: w * 0.62,
                          //     height: 16,
                          //     decoration: BoxDecoration(
                          //       color: Colors.black.withOpacity(0.10),
                          //       borderRadius: BorderRadius.circular(100),
                          //     ),
                          //   ),
                          // ),

                          // Family image
                          Transform.translate(
                            offset: const Offset(
                              0,
                              -40,
                            ),
                            child: SizedBox(
                              width: w * 0.72,
                              child: Image.asset(
                                "assets/get_started.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 3) Button placed INSIDE the blue panel
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPanelH * 0.35,
              child: Center(
                child: Container(
                  width: 160,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/caregiver_login',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: goldText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
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
