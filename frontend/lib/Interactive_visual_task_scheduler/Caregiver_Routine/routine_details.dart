import 'package:flutter/material.dart';
import '../../models/routine_model.dart';
import '../../services/routine_api.dart';
import '../../services/tts_service.dart';

class RoutineDetailsScreen extends StatelessWidget {
  final String routineId;

  const RoutineDetailsScreen({super.key, required this.routineId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Routine Details")),

      body: FutureBuilder<RoutineModel>(
        future: RoutineApi.getRoutineById(routineId),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Routine not found"));
          }

          final routine = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ✅ TITLE + SPEAK
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        routine.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () {
                        TtsService.speak(routine.title);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ✅ DESCRIPTION + SPEAK
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        routine.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () {
                        TtsService.speak(routine.description);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ READ TITLE + DESCRIPTION TOGETHER
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Read Routine"),
                  onPressed: () {
                    TtsService.speak(
                      "${routine.title}. ${routine.description}",
                    );
                  },
                ),

                // ✅ STOP BUTTON
                TextButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  onPressed: () {
                    TtsService.stop();
                  },
                ),

                const Divider(height: 30),

                const Text(
                  "Steps",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ STEPS LIST + SPEAK EACH STEP
                ...routine.steps.map(
                  (s) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(s.stepNumber.toString()),
                      ),
                      title: Text(s.instruction),
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          TtsService.speak(s.instruction);
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ READ ALL STEPS
                ElevatedButton.icon(
                  icon: const Icon(Icons.queue_music),
                  label: const Text("Read All Steps"),
                  onPressed: () async {
                    for (final step in routine.steps) {
                      await TtsService.speak(step.instruction);
                      await Future.delayed(const Duration(seconds: 1));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
