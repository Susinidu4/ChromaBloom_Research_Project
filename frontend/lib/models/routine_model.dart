// lib/models/routine_model.dart

class RoutineStep {
  final int stepNumber;
  final String instruction;

  RoutineStep({
    required this.stepNumber,
    required this.instruction,
  });

  factory RoutineStep.fromJson(Map<String, dynamic> json) {
    return RoutineStep(
      stepNumber: json["step_number"] ?? 0,
      instruction: json["instruction"] ?? "",
    );
  }
}

class RoutineModel {
  final String id;
  final String createdBy;
  final String title;
  final String description;
  final String? image;           // may be null
  final String ageGroup;
  final String developmentArea;
  final List<RoutineStep> steps;
  final int estimatedDuration;
  final String difficultyLevel;

  RoutineModel({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    this.image,
    required this.ageGroup,
    required this.developmentArea,
    required this.steps,
    required this.estimatedDuration,
    required this.difficultyLevel,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    final stepsJson = (json["steps"] as List? ?? []);

    return RoutineModel(
      id: json["_id"] ?? "",
      createdBy: json["created_by"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      image: json["image"], // can be null
      ageGroup: json["age_group"] ?? "",
      developmentArea: json["development_area"] ?? "",
      steps: stepsJson.map((s) => RoutineStep.fromJson(s)).toList(),
      estimatedDuration: json["estimated_duration"] ?? 0,
      difficultyLevel: json["difficulty_level"] ?? "",
    );
  }
}
