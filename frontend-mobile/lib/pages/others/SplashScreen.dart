import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/welcome_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/splash_screen.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Image.asset(
              "assets/chromabloom1.png",
              width: 200,
              height: 200,
            ),
          ),
          Positioned(
            bottom: -15,
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
