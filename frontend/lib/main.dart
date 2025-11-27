import 'package:flutter/material.dart';
import 'package:frontend/pages/others/home.dart';
import 'services/tts_service.dart';
import 'pages/Interactive_visual_task_scheduler/Caregiver_Routine/create_routine.dart';
import 'pages/Interactive_visual_task_scheduler/Caregiver_Routine/display_routine.dart';


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
        
      },
    );
  }
}