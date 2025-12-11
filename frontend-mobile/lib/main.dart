import 'package:flutter/material.dart';
import 'package:frontend/pages/others/SplashScreen.dart';
import 'package:frontend/pages/others/home.dart';
import 'package:frontend/pages/others/welcome_screen.dart';
import 'pages/Interactive_visual_task_scheduler/Caregiver_Routine/create_routine.dart';
import 'pages/Interactive_visual_task_scheduler/Caregiver_Routine/display_routine.dart';
import 'pages/auth/signup/signup_screen.dart';
import 'pages/auth/signup/caregiver_login_screen.dart';
import 'pages/auth/signup/therapist_login_screen.dart';
import 'pages/auth/signup/therapist_register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChromaBloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue,),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        
        '/createRoutine': (context) => const FormScreen(),
        '/displayRoutines': (context) => const DisplayRoutinesScreen(),
        
        '/caregiver_signup': (_) => const SignUpScreen(),
        '/caregiver_login': (_) => const CaregiverLoginScreen(),
        '/therapistLogin': (_) => const TherapistLoginScreen(),
        '/therapistRegister': (_) => const TherapistRegisterScreen(),
        '/splash': (context) => const SplashScreen(),
        '/welcome_screen': (context) => const WelcomePage()
      },
    );
  }
}