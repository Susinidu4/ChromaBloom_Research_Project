import 'package:flutter/material.dart';
import 'package:frontend/pages/Gamified_Knowlage_Builder/Selection_Screen/startG.dart';
import 'package:frontend/pages/others/SplashScreen.dart';
import 'package:frontend/pages/others/home.dart';
import 'package:frontend/pages/others/welcome_screen.dart';
import 'pages/Interactive_visual_task_scheduler/userActivity/create_userActivity.dart';
import 'pages/Interactive_visual_task_scheduler/userActivity/display_userActivity.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/Skill_Selection.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/skill_KnowlageLevel.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/startG.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/display_DrawingLesson.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/DisplayContent.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/drawingUpload.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/improvment.dart';
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
        
        '/createUserActivity': (context) => const CreateUserActivityScreen(),
        '/displayUserActivity': (context) => const DisplayUserActivityScreen(),

        '/skillSelection': (context) => const SkillSelectionPage(),
        '/skillKnowlageLevel': (context) => const SkillKnowledgeLevelPage(),
        '/unitStart': (context) => const UnitStartPage(),
        '/drawingUnit1': (context) => DrawingUnit1Page(),
        '/drawingLessonDetail': (context) => const DrawingLessonDetailPage(),
        '/drawingImprovementCheck': (context) => const DrawingImprovementCheckPage(),
        '/lessonComplete': (context) => const LessonCompletePage(),
        
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