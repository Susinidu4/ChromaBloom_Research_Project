import 'package:flutter/material.dart';
import 'package:frontend/pages/others/SplashScreen.dart';
import 'package:frontend/pages/others/home.dart';
import 'package:frontend/pages/others/welcome_screen.dart';
import 'package:frontend/pages/others/first_time_options.dart';
import 'package:provider/provider.dart';
import 'state/session_provider.dart';

import 'pages/Others/onboardScreen1.dart';
import 'pages/Others/onboardScreen2.dart';
import 'pages/others/onboardScreen3.dart';
import 'pages/others/getStartedScreen.dart';

import 'pages/Interactive_visual_task_scheduler/taskSchedulerHome.dart';
import 'pages/Interactive_visual_task_scheduler/userActivity/create_userActivity.dart';
import 'pages/Interactive_visual_task_scheduler/userActivity/display_userActivity.dart';

import 'pages/Parental_stress_monitoring/wellnessHome.dart';
import 'pages/Parental_stress_monitoring/journalEntry/display_journalEntry.dart';
import 'pages/Parental_stress_monitoring/journalEntry/create_journalEntry.dart';
import 'pages/Parental_stress_monitoring/stressAnalysis/stressAnalysis.dart';

import 'pages/auth/signup/signup_screen.dart';
import 'pages/auth/signup/caregiver_login_screen.dart';
import 'pages/auth/signup/therapist_login_screen.dart';
import 'pages/auth/signup/therapist_register_screen.dart';

import 'package:frontend/pages/profile_pages/ChildDetailsPage.dart';
import 'package:frontend/pages/profile_pages/ProfileSettingsPage.dart';
import 'package:frontend/pages/profile_pages/profile_page.dart';

import 'package:frontend/pages/Cognitive_Progress_Prediction/progress_prediction_screen.dart';

import 'package:frontend/pages/Gamified_Knowlage_Builder/Selection_Screen/startG.dart';
import 'package:frontend/pages/Gamified_Knowlage_Builder/Drawing/drawing_predict_api_page.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/Skill_Selection.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/skill_knowlageLevel_2.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/skill_KnowlageLevel.dart';
import 'pages/Gamified_Knowlage_Builder/Selection_Screen/startG_2.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/display_DrawingLesson.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/DisplayContent.dart';
import 'pages/Gamified_Knowlage_Builder/Drawing/drawingUpload.dart';
import 'pages/Gamified_Knowlage_Builder/problemSolving/lessons.dart';
import 'pages/Gamified_Knowlage_Builder/problemSolving/lessonDetails.dart';
import 'pages/Gamified_Knowlage_Builder/problemSolving/quize1.dart';
import 'pages/Gamified_Knowlage_Builder/problemSolving/problemSComplete.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: const AppBoot(),
    ),
  );
}

// ✅ NEW: waits for SessionProvider.loadFromStorage() BEFORE running MyApp
class AppBoot extends StatelessWidget {
  const AppBoot({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionProvider>();

    return FutureBuilder(
      future: session.loadFromStorage(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const MaterialApp(
            title: 'ChromaBloom',
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return const MyApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChromaBloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome_screen': (context) => const WelcomePage(),
        '/first_time': (context) => const FirstTimeOptionsPage(),

        '/onboard1': (context) => const OnboardScreen1(),
        '/onboard2': (context) => const OnboardScreen2(),
        '/onboard3': (context) => const OnboardScreen3(),
        '/get_started': (context) => const GetStartedScreen(),

        '/': (context) => const HomePage(),
        '/profile_page': (context) => const ProfilePage(),
        '/profile_settings': (context) => const ProfileSettingsPage(),
        '/child_details': (context) => const ChildDetailsPage(),

        '/taskSchedulerHome': (context) => const RoutineHomeScreen(),
        '/createUserActivity': (context) => const CreateUserActivityScreen(),
        '/displayUserActivity': (context) => const DisplayUserActivityScreen(),

        '/WellnessHome': (context) => const WellnessHomeScreen(),
        '/createJournalEntry': (context) => const CreateJournalEntryScreen(),
        '/displayJournalEntry': (context) => const JournalsScreen(),
        '/stressAnalysis': (context) => const StressAnalysisPage(),

        '/caregiver_signup': (_) => const SignUpScreen(),
        '/caregiver_login': (_) => const CaregiverLoginScreen(),
        '/therapistLogin': (_) => const TherapistLoginScreen(),
        '/therapistRegister': (_) => const TherapistRegisterScreen(),

        '/skillSelection': (context) => const SkillSelectionPage(),
        '/skillKnowlageLevel': (context) => const SkillKnowledgeLevelPage(),
        '/skillKnowlageLevel_2': (context) => const SkillKnowledgeLevelPage_2(),
        '/startG': (context) => const UnitStartPage_2(),
        '/unitStart': (context) => const UnitStartPage(),
        '/drawingUnit1': (context) => DrawingUnit1Page(),
        '/drawingLessonDetail': (context) => const DrawingLessonDetailPage(),
        '/drawingImprovementCheck': (context) =>const DrawingImprovementCheckPage(),
        '/drawingperdcit': (context) => const DrawingPredictApiPage(),

        '/problemSolvingLessons': (context) => ProblemSolvingUnit1Page(),
        '/problemSolvingLessonDetail': (context) =>const ProblemSolvingMiniTutorialPage(lessonId: ''),
        '/problemSolvingQuiz1': (context) => const ProblemSolvingMatchPage(),
        '/problemSolvingLessonComplete': (context) =>
            const ProblemSolvingLessonCompletePage(
              correctness: 0.0,
              improvement: 0.0,
              lessonId: '',
            ),

        '/progress_prediction': (context) => const ProgressPredictionScreen(),
      },
    );
  }
}
