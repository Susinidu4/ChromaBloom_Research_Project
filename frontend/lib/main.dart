import 'package:flutter/material.dart';
import 'services/tts_service.dart';
import 'Interactive_visual_task_scheduler/Caregiver_Routine/create_routine.dart';
import 'Interactive_visual_task_scheduler/Caregiver_Routine/display_routine.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); 
  // ✅ Required before async main and platform services

  await TtsService.init();  
  // 🎤 Initialize Text-to-Speech ONCE when app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 226, 76, 11),
        ),
      ),
      home: const MyHomePage(title: 'ChromaBloom'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Button 1 — Create Routine
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormScreen()),
                );
              },
              child: const Text("Create Routine"),
            ),

            const SizedBox(height: 16),

            // ✅ Button 2 — Display Routines (change later when display page is created)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DisplayRoutinesScreen(),
                  ),
                );
              },
              child: const Text("Display Routines"),
            ),
          ],
        ),
      ),
    );
  }
}
