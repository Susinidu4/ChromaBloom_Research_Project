import 'package:flutter/material.dart';
import '../../../models/routine_model.dart';
import '../../../services/Interactive_visual_task_scheduler_services/routine_api.dart';

class DisplayRoutinesScreen extends StatefulWidget {
  const DisplayRoutinesScreen({super.key});

  @override
  State<DisplayRoutinesScreen> createState() => _DisplayRoutinesScreenState();
}

class _DisplayRoutinesScreenState extends State<DisplayRoutinesScreen> {
  // 🔹 IDs used to filter
  static const String suggestedCreatorId = "p-0001"; // system / suggested
  static const String caregiverId = "u-005";         // logged caregiver

  bool showSuggested = true;     // true = Suggested, false = Your Tasks
  bool loading = false;
  String? errorMsg;

  // two separate lists
  List<RoutineModel> suggestedRoutines = [];
  List<RoutineModel> caregiverRoutines = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestedRoutines(); // first tab = suggested
  }

  Future<void> _loadSuggestedRoutines() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final list = await RoutineApi.getRoutinesByCreator(suggestedCreatorId);
      setState(() => suggestedRoutines = list);
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadCaregiverRoutines() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final list = await RoutineApi.getRoutinesByCreator(caregiverId);
      setState(() => caregiverRoutines = list);
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // ============================= UI =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF235870),
        title: const Text("Task Scheduler"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ---------- TOGGLE ----------
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _toggleButton(
                  title: "Suggested",
                  selected: showSuggested,
                  onTap: () async {
                    if (!showSuggested) {
                      setState(() => showSuggested = true);
                      if (suggestedRoutines.isEmpty) {
                        await _loadSuggestedRoutines();
                      }
                    }
                  },
                ),
                _toggleButton(
                  title: "Your Tasks",
                  selected: !showSuggested,
                  onTap: () async {
                    if (showSuggested) {
                      setState(() => showSuggested = false);
                      if (caregiverRoutines.isEmpty) {
                        await _loadCaregiverRoutines();
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---------- CONTENT ----------
          Expanded(
            child: showSuggested
                ? _buildRoutineList(suggestedRoutines, emptyText: "No suggested tasks")
                : _buildRoutineList(caregiverRoutines, emptyText: "No tasks found"),
          ),
        ],
      ),

      // Only for caregiver tab
      floatingActionButton: showSuggested
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/createRoutine');
              },
              label: const Text("Add New Task"),
              icon: const Icon(Icons.add),
              backgroundColor: const Color(0xFFC79C68),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ---------- Toggle Button ----------
  Widget _toggleButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFC79C68) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- List widget used by both tabs ----------
  Widget _buildRoutineList(List<RoutineModel> list, {required String emptyText}) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMsg != null) {
      return Center(
        child: Text(
          errorMsg!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (list.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final r = list[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(r.title),
            subtitle: Text(r.description),
            trailing: Text("${r.estimatedDuration} min"),
          ),
        );
      },
    );
  }
}
