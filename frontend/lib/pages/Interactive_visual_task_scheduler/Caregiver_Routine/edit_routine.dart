import 'package:flutter/material.dart';
import '../../../models/routine_model.dart';
import '../../../services/routine_api.dart';

class EditRoutineScreen extends StatefulWidget {
  final RoutineModel routine;

  const EditRoutineScreen({super.key, required this.routine});

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController durationController;

  String? selectedAgeGroup;
  String? selectedDevelopmentArea;
  String? selectedDifficulty;

  late List<TextEditingController> stepControllers;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    // ✅ Fill controllers using existing routine data
    titleController = TextEditingController(text: widget.routine.title);
    descriptionController =
        TextEditingController(text: widget.routine.description);
    durationController =
        TextEditingController(text: widget.routine.estimatedDuration.toString());

    selectedAgeGroup = widget.routine.ageGroup;
    selectedDevelopmentArea = widget.routine.developmentArea;
    selectedDifficulty = widget.routine.difficultyLevel;

    stepControllers = widget.routine.steps
        .map((s) => TextEditingController(text: s.instruction))
        .toList();
  }

  void addStep() {
    setState(() {
      stepControllers.add(TextEditingController());
    });
  }

  void removeStep(int index) {
    setState(() {
      stepControllers[index].dispose();
      stepControllers.removeAt(index);
    });
  }

  Future<void> handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    // ✅ build updated steps array
    final steps = List.generate(stepControllers.length, (i) {
      return {
        "step_number": i + 1, // send as number (not string)
        "instruction": stepControllers[i].text.trim(),
      };
    });

    final updateData = {
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "age_group": selectedAgeGroup,
      "development_area": selectedDevelopmentArea,
      "steps": steps,
      "estimated_duration": int.parse(durationController.text.trim()),
      "difficulty_level": selectedDifficulty,
    };

    final ok =
        await RoutineApi.updateRoutine(widget.routine.id, updateData);

    setState(() => saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Routine updated successfully")),
      );

      Navigator.pop(context, true); 
      // ✅ return true so details screen refreshes
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    for (final c in stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Routine")),
      body: saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // TITLE
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 12),

                    // DESCRIPTION
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 12),

                    // AGE GROUP
                    DropdownButtonFormField<String>(
                      value: selectedAgeGroup,
                      decoration: const InputDecoration(labelText: "Age Group"),
                      items: List.generate(10, (i) {
                        final val = (i + 1).toString();
                        return DropdownMenuItem(value: val, child: Text(val));
                      }),
                      onChanged: (v) => setState(() => selectedAgeGroup = v),
                      validator: (v) => v == null ? "Required" : null,
                    ),

                    const SizedBox(height: 12),

                    // DEVELOPMENT AREA
                    DropdownButtonFormField<String>(
                      value: selectedDevelopmentArea,
                      decoration:
                          const InputDecoration(labelText: "Development Area"),
                      items: const [
                        DropdownMenuItem(value: "Motor", child: Text("Motor")),
                        DropdownMenuItem(
                            value: "Language", child: Text("Language")),
                        DropdownMenuItem(
                            value: "Cognitive", child: Text("Cognitive")),
                        DropdownMenuItem(value: "Social", child: Text("Social")),
                        DropdownMenuItem(
                            value: "Emotional", child: Text("Emotional")),
                        DropdownMenuItem(
                            value: "Self-Help", child: Text("Self-Help")),
                      ],
                      onChanged: (v) =>
                          setState(() => selectedDevelopmentArea = v),
                      validator: (v) => v == null ? "Required" : null,
                    ),

                    const SizedBox(height: 12),

                    // STEPS
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Steps",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 8),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stepControllers.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: stepControllers[index],
                                decoration: InputDecoration(
                                  labelText: "Step ${index + 1}",
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? "Step required"
                                    : null,
                              ),
                            ),
                            if (stepControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeStep(index),
                              ),
                          ],
                        );
                      },
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: addStep,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Step"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DURATION
                    TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: "Estimated Duration (minutes)",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (int.tryParse(v) == null) return "Must be number";
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // DIFFICULTY
                    DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      decoration:
                          const InputDecoration(labelText: "Difficulty Level"),
                      items: const [
                        DropdownMenuItem(value: "Easy", child: Text("Easy")),
                        DropdownMenuItem(value: "Medium", child: Text("Medium")),
                        DropdownMenuItem(value: "Hard", child: Text("Hard")),
                      ],
                      onChanged: (v) => setState(() => selectedDifficulty = v),
                      validator: (v) => v == null ? "Required" : null,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: handleUpdate,
                        child: const Text("Update Routine"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
