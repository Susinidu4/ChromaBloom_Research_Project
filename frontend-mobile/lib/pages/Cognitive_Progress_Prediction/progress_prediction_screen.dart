import 'package:flutter/material.dart';
import '../../services/Cognitive_Progress_Prediction/cognitive_progress_service.dart';

class ProgressPredictionScreen extends StatefulWidget {
  const ProgressPredictionScreen({super.key});

  @override
  State<ProgressPredictionScreen> createState() => _ProgressPredictionScreenState();
}

class _ProgressPredictionScreenState extends State<ProgressPredictionScreen> {
  // ✅ Android emulator: 10.0.2.2 (if you're on real phone, use your PC IP)
  final api = ProgressPredictionApi(baseUrl: "http://localhost:5000");

  bool loading = false;
  double? predictedScore;
  List<dynamic> positive = [];
  List<dynamic> negative = [];
  String? errorMsg;

  final _formKey = GlobalKey<FormState>();

  // --------------------------
  // Dropdown values
  // --------------------------
  String gender = "male";
  String diagnosisType = "Trisomy21";
  String activity = "Matching picture cards";
  String moodLabel = "tired";
  String caregiverMoodLabel = "stressed";

  // --------------------------
  // Text controllers (numbers)
  // --------------------------
  final ageCtrl = TextEditingController(text: "5");
  final durationCtrl = TextEditingController(text: "5"); // minutes
  final sentimentCtrl = TextEditingController(text: "-0.2");
  final stressCtrl = TextEditingController(text: "0.68");
  final sleepCtrl = TextEditingController(text: "6.5");

  final totalAssignedCtrl = TextEditingController(text: "6");
  final totalCompletedCtrl = TextEditingController(text: "5");
  final completionRateCtrl = TextEditingController(text: "0.83");
  final engagementCtrl = TextEditingController(text: "18.5");

  final memoryAccCtrl = TextEditingController(text: "0.65");
  final attentionAccCtrl = TextEditingController(text: "0.72");
  final problemAccCtrl = TextEditingController(text: "0.58");
  final motorAccCtrl = TextEditingController(text: "0.74");
  final responseTimeCtrl = TextEditingController(text: "3.4");

  final caregiverSentimentCtrl = TextEditingController(text: "-0.15");
  final caregiverStressCtrl = TextEditingController(text: "0.72");
  final caregiverScreenCtrl = TextEditingController(text: "210");
  final caregiverSleepCtrl = TextEditingController(text: "5.8");

  final phoneScreenCtrl = TextEditingController(text: "180");

  // --------------------------
  // Helpers
  // --------------------------
  double _d(TextEditingController c) => double.parse(c.text.trim());
  int _i(TextEditingController c) => int.parse(c.text.trim());

  String? _reqValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Required";
    return null;
  }

  String? _numValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Required";
    final x = double.tryParse(v.trim());
    if (x == null) return "Enter a valid number";
    return null;
  }

  Future<void> _predict() async {
    // validate inputs
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      errorMsg = null;
      predictedScore = null;
      positive = [];
      negative = [];
    });

    try {
      final features = <String, dynamic>{
        // categoricals
        "gender": gender,
        "diagnosis_type": diagnosisType,
        "activity": activity,
        "mood_label": moodLabel,
        "caregiver_mood_label": caregiverMoodLabel,

        // numerics
        "age": _i(ageCtrl),
        "time_duration_for_activity": _i(durationCtrl),
        "sentiment_score": _d(sentimentCtrl),
        "stress_score_combined": _d(stressCtrl),
        "sleep_hours": _d(sleepCtrl),

        "total_tasks_assigned": _i(totalAssignedCtrl),
        "total_tasks_completed": _i(totalCompletedCtrl),
        "completion_rate": _d(completionRateCtrl),
        "engagement_minutes": _d(engagementCtrl),

        "memory_accuracy": _d(memoryAccCtrl),
        "attention_accuracy": _d(attentionAccCtrl),
        "problem_solving_accuracy": _d(problemAccCtrl),
        "motor_skills_accuracy": _d(motorAccCtrl),
        "average_response_time": _d(responseTimeCtrl),

        // caregiver related
        "caregiver_sentiment_score": _d(caregiverSentimentCtrl),
        "caregiver_stress_score_combined": _d(caregiverStressCtrl),
        "caregiver_phone_screen_time_mins": _i(caregiverScreenCtrl),
        "caregiver_sleep_hours": _d(caregiverSleepCtrl),

        // still required by your model
        "phone_screen_time_mins": _i(phoneScreenCtrl),
      };

      final data = await api.predictProgress(features);
      final result = data["result"];

      setState(() {
        predictedScore = (result["predicted_score_next_14_days"] as num).toDouble();
        positive = result["explainability"]["top_positive_factors"] ?? [];
        negative = result["explainability"]["top_negative_factors"] ?? [];
      });
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _numField(String label, TextEditingController ctrl, {String hint = ""}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      validator: _numValidator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.map((x) => DropdownMenuItem(value: x, child: Text(x.toString()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _factorList(String title, List<dynamic> factors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (factors.isEmpty)
          const Text("No factors returned")
        else
          ...factors.take(10).map((f) {
            final feature = f["feature"]?.toString() ?? "-";
            final shapVal = (f["shap_value"] as num?)?.toDouble() ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(feature)),
                  Text(shapVal.toStringAsFixed(4)),
                ],
              ),
            );
          }),
      ],
    );
  }

  @override
  void dispose() {
    ageCtrl.dispose();
    durationCtrl.dispose();
    sentimentCtrl.dispose();
    stressCtrl.dispose();
    sleepCtrl.dispose();
    totalAssignedCtrl.dispose();
    totalCompletedCtrl.dispose();
    completionRateCtrl.dispose();
    engagementCtrl.dispose();
    memoryAccCtrl.dispose();
    attentionAccCtrl.dispose();
    problemAccCtrl.dispose();
    motorAccCtrl.dispose();
    responseTimeCtrl.dispose();
    caregiverSentimentCtrl.dispose();
    caregiverStressCtrl.dispose();
    caregiverScreenCtrl.dispose();
    caregiverSleepCtrl.dispose();
    phoneScreenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cognitive Progress Prediction (Manual)")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _dropdown<String>(
              label: "Gender",
              value: gender,
              items: const ["male", "female"],
              onChanged: (v) => setState(() => gender = v ?? "male"),
            ),
            const SizedBox(height: 12),

            _dropdown<String>(
              label: "Diagnosis Type",
              value: diagnosisType,
              items: const ["Trisomy21", "Mosaicism", "Translocation"],
              onChanged: (v) => setState(() => diagnosisType = v ?? "Trisomy21"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: activity,
              validator: _reqValidator,
              decoration: const InputDecoration(
                labelText: "Activity",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => activity = v,
            ),
            const SizedBox(height: 12),

            _dropdown<String>(
              label: "Child Mood Label",
              value: moodLabel,
              items: const ["happy", "neutral", "tired", "sad", "angry"],
              onChanged: (v) => setState(() => moodLabel = v ?? "tired"),
            ),
            const SizedBox(height: 12),

            _dropdown<String>(
              label: "Caregiver Mood Label",
              value: caregiverMoodLabel,
              items: const ["calm", "neutral", "stressed", "angry", "sad"],
              onChanged: (v) => setState(() => caregiverMoodLabel = v ?? "stressed"),
            ),
            const SizedBox(height: 16),

            const Text("Child Metrics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _numField("Age", ageCtrl, hint: "e.g., 5"),
            const SizedBox(height: 12),
            _numField("Time Duration for Activity (minutes)", durationCtrl, hint: "e.g., 5"),
            const SizedBox(height: 12),
            _numField("Sentiment Score", sentimentCtrl, hint: "e.g., -0.2"),
            const SizedBox(height: 12),
            _numField("Stress Score Combined", stressCtrl, hint: "e.g., 0.68"),
            const SizedBox(height: 12),
            _numField("Sleep Hours", sleepCtrl, hint: "e.g., 6.5"),
            const SizedBox(height: 12),
            _numField("Phone Screen Time (mins)", phoneScreenCtrl, hint: "e.g., 180"),
            const SizedBox(height: 12),

            _numField("Total Tasks Assigned", totalAssignedCtrl, hint: "e.g., 6"),
            const SizedBox(height: 12),
            _numField("Total Tasks Completed", totalCompletedCtrl, hint: "e.g., 5"),
            const SizedBox(height: 12),
            _numField("Completion Rate", completionRateCtrl, hint: "e.g., 0.83"),
            const SizedBox(height: 12),
            _numField("Engagement Minutes", engagementCtrl, hint: "e.g., 18.5"),
            const SizedBox(height: 12),

            _numField("Memory Accuracy", memoryAccCtrl, hint: "0.0 - 1.0"),
            const SizedBox(height: 12),
            _numField("Attention Accuracy", attentionAccCtrl, hint: "0.0 - 1.0"),
            const SizedBox(height: 12),
            _numField("Problem Solving Accuracy", problemAccCtrl, hint: "0.0 - 1.0"),
            const SizedBox(height: 12),
            _numField("Motor Skills Accuracy", motorAccCtrl, hint: "0.0 - 1.0"),
            const SizedBox(height: 12),
            _numField("Average Response Time (sec)", responseTimeCtrl, hint: "e.g., 3.4"),
            const SizedBox(height: 18),

            const Text("Caregiver Metrics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _numField("Caregiver Sentiment Score", caregiverSentimentCtrl, hint: "e.g., -0.15"),
            const SizedBox(height: 12),
            _numField("Caregiver Stress Score Combined", caregiverStressCtrl, hint: "e.g., 0.72"),
            const SizedBox(height: 12),
            _numField("Caregiver Phone Screen Time (mins)", caregiverScreenCtrl, hint: "e.g., 210"),
            const SizedBox(height: 12),
            _numField("Caregiver Sleep Hours", caregiverSleepCtrl, hint: "e.g., 5.8"),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : _predict,
              child: Text(loading ? "Predicting..." : "Predict Now"),
            ),

            const SizedBox(height: 16),

            if (errorMsg != null)
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),

            if (predictedScore != null) ...[
              const SizedBox(height: 12),
              Text(
                "Predicted Score (Next 14 Days): ${predictedScore!.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _factorList("Top Positive Factors", positive),
              const SizedBox(height: 16),
              _factorList("Top Negative Factors", negative),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
