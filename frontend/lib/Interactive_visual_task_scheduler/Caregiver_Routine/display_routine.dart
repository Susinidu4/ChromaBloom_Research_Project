import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../../models/routine_model.dart';
import '../../services/routine_api.dart';

class DisplayRoutinesScreen extends StatefulWidget {
  const DisplayRoutinesScreen({super.key});

  @override
  State<DisplayRoutinesScreen> createState() => _DisplayRoutinesScreenState();
}

class _DisplayRoutinesScreenState extends State<DisplayRoutinesScreen> {
  String? createdBy; // Logged user's ID
  bool loading = false;
  String? errorMsg;
  List<RoutineModel> routines = [];

  @override
  void initState() {
    super.initState();
    loadLoggedUser(); // 🔥 Load user ID automatically
  }

  // 🔥 Load logged user's ID (from login)
  Future<void> loadLoggedUser() async {
    // final prefs = await SharedPreferences.getInstance();
    // final userId = prefs.getString("userId"); // ← must be saved at login

    setState(() {
      createdBy = "ddfs"; 
      // fallback only for testing
    });

    fetchRoutines(); // auto load after ID is available
  }

  Future<void> fetchRoutines() async {
    if (createdBy == null) {
      setState(() => errorMsg = "Logged user ID not found");
      return;
    }

    setState(() {
      loading = true;
      errorMsg = null;
      routines = [];
    });

    try {
      final list = await RoutineApi.getRoutinesByCreator(createdBy!);
      setState(() => routines = list);
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Display Routines")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Logged user ID: ${createdBy ?? 'Loading...'}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 12),

            if (loading) const Center(child: CircularProgressIndicator()),

            if (errorMsg != null)
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 8),

            Expanded(
              child: routines.isEmpty
                  ? const Center(child: Text("No routines found"))
                  : ListView.builder(
                      itemCount: routines.length,
                      itemBuilder: (context, index) {
                        final r = routines[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(r.description),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
