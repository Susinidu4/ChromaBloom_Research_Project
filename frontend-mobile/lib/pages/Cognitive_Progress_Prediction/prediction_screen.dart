import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Cognitive_Progress_Prediction/progress_insight_chart.dart';
import '../../services/Cognitive_Progress_Prediction/cognitive_progress_service.dart';
import '';


class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  // ✅ Replace this with your actual logged-in userId
  final String _userId = "cg-0001";

  final _childIdCtrl = TextEditingController(text: "c-001");
  final _ageCtrl = TextEditingController(text: "5");
  final _heightCtrl = TextEditingController(text: "105");
  final _weightCtrl = TextEditingController(text: "18.5");
  final _tasksAssignedCtrl = TextEditingController(text: "6");
  final _tasksCompletedCtrl = TextEditingController(text: "5");
  final _engagementCtrl = TextEditingController(text: "18.5");

  String _gender = "male";
  String _diagnosis = "Trisomy21";
  String _mood = "tired";

  bool _loading = false;
  double? _predictedScore;
  List<dynamic>? _topFactors;
  String? _error;

  bool _loadingHistory = false;
  List<StoredProgress> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loadingHistory = true;
      _error = null;
    });

    try {
      final list = await CognitiveProgressService.getHistory(_userId);
      setState(() => _history = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loadingHistory = false);
    }
  }

  Map<String, dynamic> _buildFeatures() {
    final assigned = int.parse(_tasksAssignedCtrl.text.trim());
    final completed = int.parse(_tasksCompletedCtrl.text.trim());

    return {
      "child_id": _childIdCtrl.text.trim(),
      "age": int.parse(_ageCtrl.text.trim()),
      "height_cm": int.parse(_heightCtrl.text.trim()),
      "weight_kg": double.parse(_weightCtrl.text.trim()),
      "gender": _gender,
      "diagnosis_type": _diagnosis,
      "mood_label": _mood,
      "sentiment_score": -0.2,
      "stress_score_combined": 0.68,
      "phone_screen_time_mins": 180,
      "sleep_hours": 6.5,
      "total_tasks_assigned": assigned,
      "total_tasks_completed": completed,
      "completion_rate": assigned == 0 ? 0.0 : (completed / assigned),
      "engagement_minutes": double.parse(_engagementCtrl.text.trim()),
      "memory_accuracy": 0.65,
      "attention_accuracy": 0.72,
      "problem_solving_accuracy": 0.58,
      "motor_skills_accuracy": 0.74,
      "average_response_time": 3.4,
    };
  }

  Future<void> _predictAndStore() async {
    setState(() {
      _loading = true;
      _error = null;
      _predictedScore = null;
      _topFactors = null;
    });

    try {
      final features = _buildFeatures();

      // 1) Predict
      final pred = await CognitiveProgressService.predict(features);

      // 2) Store to backend (model unchanged: userId + progress_prediction)
      await CognitiveProgressService.storePrediction(
        userId: _userId,
        progressPrediction: pred.predictedScore,
      );

      setState(() {
        _predictedScore = pred.predictedScore;
        _topFactors = pred.topFactors;
      });

      // 3) Refresh history (Insights)
      await _loadHistory();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _childIdCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _tasksAssignedCtrl.dispose();
    _tasksCompletedCtrl.dispose();
    _engagementCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cognitive Progress Predictor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Inputs", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _childIdCtrl, decoration: const InputDecoration(labelText: "Child ID")),
            TextField(controller: _ageCtrl, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
            TextField(controller: _heightCtrl, decoration: const InputDecoration(labelText: "Height (cm)"), keyboardType: TextInputType.number),
            TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),

            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: "Gender"),
              items: const [
                DropdownMenuItem(value: "male", child: Text("Male")),
                DropdownMenuItem(value: "female", child: Text("Female")),
              ],
              onChanged: (val) => setState(() => _gender = val ?? "male"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _diagnosis,
              decoration: const InputDecoration(labelText: "Diagnosis Type"),
              items: const [
                DropdownMenuItem(value: "Trisomy21", child: Text("Trisomy 21")),
                DropdownMenuItem(value: "Mosaic", child: Text("Mosaic")),
                DropdownMenuItem(value: "Translocation", child: Text("Translocation")),
              ],
              onChanged: (val) => setState(() => _diagnosis = val ?? "Trisomy21"),
            ),

            const SizedBox(height: 8),
            TextField(controller: _tasksAssignedCtrl, decoration: const InputDecoration(labelText: "Total Tasks Assigned"), keyboardType: TextInputType.number),
            TextField(controller: _tasksCompletedCtrl, decoration: const InputDecoration(labelText: "Total Tasks Completed"), keyboardType: TextInputType.number),
            TextField(controller: _engagementCtrl, decoration: const InputDecoration(labelText: "Engagement Minutes"), keyboardType: TextInputType.number),

            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _mood,
              decoration: const InputDecoration(labelText: "Mood"),
              items: const [
                DropdownMenuItem(value: "tired", child: Text("Tired")),
                DropdownMenuItem(value: "happy", child: Text("Happy")),
                DropdownMenuItem(value: "calm", child: Text("Calm")),
              ],
              onChanged: (val) => setState(() => _mood = val ?? "tired"),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _predictAndStore,
                child: _loading ? const CircularProgressIndicator() : const Text("Predict Progress (and Save)"),
              ),
            ),

            const SizedBox(height: 16),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),

            if (_predictedScore != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Latest predicted progress: ${_predictedScore!.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (_topFactors != null && _topFactors!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text("Top contributing factors:"),
                        const SizedBox(height: 6),
                        ..._topFactors!.map((f) {
                          final feature = f["feature"]?.toString() ?? "";
                          final value = f["value"];
                          final impact = (f["impact"] as num?)?.toDouble() ?? 0.0;
                          return Text("$feature  |  value: $value  |  impact: ${impact.toStringAsFixed(3)}");
                        }),
                      ]
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
const Text(
  "Insights (Progress Trend)",
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
const SizedBox(height: 10),

if (_loadingHistory)
  const Center(child: CircularProgressIndicator()),

if (!_loadingHistory && _history.isEmpty)
  const Text("No predictions saved yet."),

if (!_loadingHistory && _history.isNotEmpty)
  Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: ProgressInsightChart(history: _history),
    ),
  ),
          ],
        ),
      ),
    );

  }
}
