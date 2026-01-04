import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _routeNext();
  }

  Future<void> _routeNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isFirstInstall = prefs.getBool('isFirstInstall') ?? true;

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/caregiver_login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /* ================= BACKGROUND IMAGE ================= */
          Positioned.fill(
            child: Image.asset(
              "assets/images/welcome_screen.png",
              fit: BoxFit.cover,
            ),
          ),

          /* ================= CONTENT ================= */
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 50),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Image.asset("assets/chromabloom1.png"),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Hello! Welcome to",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBD9A6B),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: SizedBox(
                            width: 150,
                            height: 130,
                            child: Image.asset("assets/chromabloom2.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    "WHERE CARE MEETS INTELLIGENCE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w100,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: Color(0xFFBD9A6B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
