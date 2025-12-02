import 'package:flutter/material.dart';
import '../../../services/Interactive_visual_task_scheduler_services/routine_api.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // TEMP hard-coded caregiver / user id
  // TODO: later replace with real logged-in caregiver id
  static const String hardcodedCaregiverId = "p-0001";

  // Controllers for routine fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController estimatedDurationController =
      TextEditingController();

  // Dropdown values
  String? selectedAgeGroup;
  String? selectedDevelopmentArea;
  String? selectedDifficultyLevel;

  // Dynamic steps list
  final List<TextEditingController> stepControllers = [];

  @override
  void initState() {
    super.initState();
    // start with 3 steps by default
    addStep();
    addStep();
    addStep();
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    estimatedDurationController.dispose();
    for (final c in stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Build steps array like backend expects (step_number is Number)
    final steps = List.generate(stepControllers.length, (i) {
      return {
        "step_number": i + 1,
        "instruction": stepControllers[i].text.trim(),
      };
    });

    final routineData = {
      "created_by": hardcodedCaregiverId, // ✅ temp hard-coded user id
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "age_group": selectedAgeGroup,
      "development_area": selectedDevelopmentArea,
      "steps": steps,
      "estimated_duration":
          int.parse(estimatedDurationController.text.trim()),
      "difficulty_level": selectedDifficultyLevel,
    };

    final success = await RoutineApi.createRoutine(routineData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Routine Created Successfully!")),
      );

      // clear form
      titleController.clear();
      descriptionController.clear();
      estimatedDurationController.clear();
      for (final c in stepControllers) {
        c.clear();
      }
      setState(() {
        selectedAgeGroup = null;
        selectedDevelopmentArea = null;
        selectedDifficultyLevel = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create routine")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Routine")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Routine Title",
                  hintText: "e.g. Putting Away Toys",
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              // description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              // age_group dropdown
              DropdownButtonFormField<String>(
                value: selectedAgeGroup,
                decoration: const InputDecoration(labelText: "Age Group"),
                items: List.generate(10, (index) {
                  final age = (index + 1).toString();
                  return DropdownMenuItem(
                    value: age,
                    child: Text(age),
                  );
                }),
                onChanged: (value) => setState(() {
                  selectedAgeGroup = value;
                }),
                validator: (value) => value == null ? "Required" : null,
              ),

              const SizedBox(height: 16),

              // development_area dropdown
              DropdownButtonFormField<String>(
                value: selectedDevelopmentArea,
                decoration:
                    const InputDecoration(labelText: "Development Area"),
                items: const [
                  DropdownMenuItem(value: "Motor", child: Text("Motor")),
                  DropdownMenuItem(value: "Language", child: Text("Language")),
                  DropdownMenuItem(value: "Cognitive", child: Text("Cognitive")),
                  DropdownMenuItem(value: "Social", child: Text("Social")),
                  DropdownMenuItem(value: "Emotional", child: Text("Emotional")),
                  DropdownMenuItem(value: "Self-Help", child: Text("Self-Help")),
                ],
                onChanged: (value) => setState(() {
                  selectedDevelopmentArea = value;
                }),
                validator: (value) => value == null ? "Required" : null,
              ),

              const SizedBox(height: 16),

              // steps list
              const Text(
                "Steps",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stepControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: stepControllers[index],
                            decoration: InputDecoration(
                              labelText: "Step ${index + 1}",
                              hintText: "Instruction for step ${index + 1}",
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? "Step required"
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (stepControllers.length > 1)
                          IconButton(
                            onPressed: () => removeStep(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                      ],
                    ),
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

              const SizedBox(height: 16),

              // estimated_duration
              TextFormField(
                controller: estimatedDurationController,
                decoration: const InputDecoration(
                  labelText: "Estimated Duration (minutes)",
                  hintText: "e.g. 3",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (int.tryParse(value) == null) return "Must be a number";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // difficulty dropdown
              DropdownButtonFormField<String>(
                value: selectedDifficultyLevel,
                decoration:
                    const InputDecoration(labelText: "Difficulty Level"),
                items: const [
                  DropdownMenuItem(value: "Easy", child: Text("Easy")),
                  DropdownMenuItem(value: "Medium", child: Text("Medium")),
                  DropdownMenuItem(value: "Hard", child: Text("Hard")),
                ],
                onChanged: (value) => setState(() {
                  selectedDifficultyLevel = value;
                }),
                validator: (value) => value == null ? "Required" : null,
              ),

              const SizedBox(height: 24),

              // submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleSubmit,
                  child: const Text("Submit Routine"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
