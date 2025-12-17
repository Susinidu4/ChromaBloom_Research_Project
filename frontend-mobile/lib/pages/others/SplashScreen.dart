import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ---- Background Image ----
          Positioned.fill(
            child: Image.asset(
              "assets/splash_screen_image.png",
              fit: BoxFit.cover,
            ),
          ),

          /// ---- Center Logo ----
          Center(
            child: Image.asset(
              "assets/chromabloom1.png",
              width: 200,
              height: 200,
            ),
          ),

          /// ---- Bottom Center Image ----
          Positioned(
            bottom: -15, // adjust as needed
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/chromabloom2.png",
                width: 150,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
