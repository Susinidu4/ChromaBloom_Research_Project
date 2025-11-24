import 'package:flutter/material.dart';
import '../../models/routine_model.dart';
import '../../services/routine_api.dart';
import '../../services/tts_service.dart';
import 'edit_routine.dart';

class RoutineDetailsScreen extends StatefulWidget {
  final String routineId;

  const RoutineDetailsScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailsScreen> createState() => _RoutineDetailsScreenState();
}

class _RoutineDetailsScreenState extends State<RoutineDetailsScreen> {
  late Future<RoutineModel> futureRoutine;

  @override
  void initState() {
    super.initState();
    futureRoutine = RoutineApi.getRoutineById(widget.routineId);
  }

  // ✅ refresh after edit
  void reloadRoutine() {
    setState(() {
      futureRoutine = RoutineApi.getRoutineById(widget.routineId);
    });
  }

  // ✅ DELETE FUNCTION
  Future<void> handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Routine?"),
        content: const Text("Are you sure you want to delete this routine?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await RoutineApi.deleteRoutine(widget.routineId);

    if (success) {
      TtsService.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Routine deleted successfully")),
      );
      Navigator.pop(context, true); // go back to list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Routine Details")),
      body: FutureBuilder<RoutineModel>(
        future: futureRoutine,
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
                      onPressed: () => TtsService.speak(routine.title),
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
                      onPressed: () => TtsService.speak(routine.description),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ READ TITLE + DESCRIPTION
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Read Routine"),
                  onPressed: () {
                    TtsService.speak(
                      "${routine.title}. ${routine.description}",
                    );
                  },
                ),

                // ✅ STOP
                TextButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  onPressed: () => TtsService.stop(),
                ),

                const Divider(height: 30),

                const Text(
                  "Steps",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        onPressed: () => TtsService.speak(s.instruction),
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

                const SizedBox(height: 10),

                // ✅ EDIT BUTTON
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Routine"),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditRoutineScreen(routine: routine),
                      ),
                    );

                    if (updated == true) {
                      reloadRoutine();
                    }
                  },
                ),

                const SizedBox(height: 10),

                // ✅ DELETE BUTTON
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  label: const Text("Delete Routine"),
                  onPressed: handleDelete,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
