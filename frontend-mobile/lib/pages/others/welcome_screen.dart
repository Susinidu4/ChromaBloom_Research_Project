import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF386884), // Background color

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ================== TOP CONTAINER ==================
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 140,
                height: 400,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 62, 162, 216), // top
                      Color(0xFF386884), // bottom
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(12, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // -------- chromabloom1.png --------
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset(
                        "assets/chromabloom1.png",
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // -------- Text --------
                    const Text(
                      "Hello! Welcome to",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBD9A6B),
                      ),
                    ),

                    const SizedBox(height: 0),

                    // -------- chromabloom2.png --------
                    Transform.translate(
                      offset: Offset(0, -20), // Move upward
                      child: SizedBox(
                        width: 150,
                        height: 130,
                        child: Image.asset(
                          "assets/chromabloom2.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================== BOTTOM TAGLINE ==================
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                "WHERE CARE MEETS INTELLIGENCE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w100, // Thin
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Color(0xFFBD9A6B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
