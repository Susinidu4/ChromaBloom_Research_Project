import 'package:flutter/material.dart';
import 'package:frontend/pages/Cognitive_Progress_Prediction/progress_prediction_screen.dart';
import 'package:frontend/pages/Gamified_Knowlage_Builder/Selection_Screen/startG.dart';
import 'package:frontend/pages/Gamified_Knowlage_Builder/Drawing/drawing_predict_api_page.dart';
import 'package:provider/provider.dart';

import 'state/session_provider.dart';

import 'package:frontend/pages/others/SplashScreen.dart';
import 'package:frontend/pages/others/first_time_options.dart';
import 'package:frontend/pages/others/home.dart';
import 'package:frontend/pages/others/welcome_screen.dart';

import 'package:frontend/pages/profile_pages/ChildDetailsPage.dart';
import 'package:frontend/pages/profile_pages/ProfileSettingsPage.dart';
import 'package:frontend/pages/profile_pages/profile_page.dart';

import 'pages/auth/signup/signup_screen.dart';
import 'pages/auth/signup/caregiver_login_screen.dart';
import 'pages/auth/signup/therapist_login_screen.dart';
import 'pages/auth/signup/therapist_register_screen.dart';


import 'pages/Interactive_visual_task_scheduler/userActivity/create_userActivity.dart';
import 'pages/Interactive_visual_task_scheduler/userActivity/display_userActivity.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/Skill_Selection.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/skill_KnowlageLevel.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/startG.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/display_DrawingLesson.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/DisplayContent.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/drawingUpload.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/improvment.dart';
import 'pages/Gamified_Knowlage_Builder/problemSolving/lessons.dart';



void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionProvider()..loadFromStorage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChromaBloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue,),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome_screen': (context) => const WelcomePage(),
        '/first_time': (context) => const FirstTimeOptionsPage(),
        
        '/': (context) => const HomePage(),
        
         '/profile_page': (context) => const ProfilePage(),
        '/profile_settings': (context) => const ProfileSettingsPage(),
        '/child_details': (context) => const ChildDetailsPage(),
        
        '/createUserActivity': (context) => const CreateUserActivityScreen(),
        '/displayUserActivity': (context) => const DisplayUserActivityScreen(),

        '/skillSelection': (context) => const SkillSelectionPage(),
        '/skillKnowlageLevel': (context) => const SkillKnowledgeLevelPage(),
        '/unitStart': (context) => const UnitStartPage(),
        '/drawingUnit1': (context) => DrawingUnit1Page(),
        '/drawingLessonDetail': (context) => const DrawingLessonDetailPage(), // drawing lesson 
        '/drawingImprovementCheck': (context) => const DrawingImprovementCheckPage(), //drawing lesson img upload
        '/lessonComplete': (context) => const LessonCompletePage(), //drawing lesson correctness & improvment
        '/problemSolvingLessons': (context) =>  ProblemSolvingUnit1Page(),
        
        
        '/caregiver_signup': (_) => const SignUpScreen(),
        '/caregiver_login': (_) => const CaregiverLoginScreen(),
        '/therapistLogin': (_) => const TherapistLoginScreen(),
        '/therapistRegister': (_) => const TherapistRegisterScreen(),

        '/progress_prediction': (context) => const ProgressPredictionScreen(),

        '/drawingperdcit' : (context) => const DrawingPredictApiPage(),

      },
    );
  }
}