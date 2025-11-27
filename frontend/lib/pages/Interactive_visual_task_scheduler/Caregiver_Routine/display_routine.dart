import 'package:flutter/material.dart';
import '../../../models/routine_model.dart';
import '../../../services/routine_api.dart';
import 'routine_details.dart';

class DisplayRoutinesScreen extends StatefulWidget {
  const DisplayRoutinesScreen({super.key});

  @override
  State<DisplayRoutinesScreen> createState() => _DisplayRoutinesScreenState();
}

class _DisplayRoutinesScreenState extends State<DisplayRoutinesScreen> {
  String? createdBy;
  bool loading = false;
  String? errorMsg;
  List<RoutineModel> routines = [];

  @override
  void initState() {
    super.initState();
    createdBy = "p-0001"; // hardcoded for now
    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
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
          children: [
            if (loading) const CircularProgressIndicator(),
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

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RoutineDetailsScreen(routineId: r.id),
                              ),
                            );
                          },
                          child: Card(
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(r.description),
                                ],
                              ),
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
