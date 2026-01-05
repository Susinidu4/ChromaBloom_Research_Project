import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/Cognitive_Progress_Prediction/cognitive_progress_service.dart';
import '../../services/user_services/child_api.dart';
import '../../state/session_provider.dart';

import '../others/header.dart';
import '../others/navBar.dart';

class ProgressPredictionScreen extends StatefulWidget {
  const ProgressPredictionScreen({super.key});

  @override
  State<ProgressPredictionScreen> createState() =>
      _ProgressPredictionScreenState();
}

class _ProgressPredictionScreenState extends State<ProgressPredictionScreen> {
  // ✅ If emulator use: http://10.0.2.2:5000
  final api = ProgressPredictionApi(baseUrl: "http://localhost:5000");
  final childApi = ChildApi();

  bool loading = false;
  double? predictedScore;
  List<dynamic> positive = [];
  List<dynamic> negative = [];
  String? errorMsg;

  // ✅ History
  bool historyLoading = false;
  String? childIdResolved;
  List<dynamic> history = []; // { _id, userId, progress_prediction, createdAt, ... }

  final _formKey = GlobalKey<FormState>();

  String gender = "male";
  String diagnosisType = "Trisomy21";
  String activity = "Matching picture cards";
  String moodLabel = "tired";
  String caregiverMoodLabel = "stressed";

  final ageCtrl = TextEditingController(text: "5");
  final durationCtrl = TextEditingController(text: "5");
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

  // ✅ Clamp scores into 0..100 (chart requirement)
  double _clampScore(double v) {
    if (v.isNaN || v.isInfinite) return 0;
    if (v < 0) return 0;
    if (v > 100) return 100;
    return v;
  }

  /// ✅ Try to get childId from session JSON first.
  /// If not present, fetch children using caregiverId.
  Future<String> _resolveChildId(SessionProvider session) async {
    final caregiver = session.caregiver;
    if (caregiver == null) throw Exception("Not logged in");

    final caregiverId =
        (caregiver["_id"] ?? caregiver["id"] ?? caregiver["caregiverId"] ?? "")
            .toString();
    if (caregiverId.isEmpty) {
      throw Exception("Caregiver ID not found in session");
    }

    final directChildId =
        (caregiver["childId"] ?? caregiver["child_id"] ?? "").toString();
    if (directChildId.isNotEmpty) return directChildId;

    if (caregiver["childIds"] is List &&
        (caregiver["childIds"] as List).isNotEmpty) {
      final first = (caregiver["childIds"] as List).first;
      final id = first?.toString() ?? "";
      if (id.isNotEmpty) return id;
    }

    if (caregiver["children"] is List &&
        (caregiver["children"] as List).isNotEmpty) {
      final first = (caregiver["children"] as List).first;
      if (first is Map) {
        final id = (first["_id"] ?? first["id"] ?? "").toString();
        if (id.isNotEmpty) return id;
      }
    }

    final kids = await ChildApi.getChildrenByCaregiver(caregiverId);

    if (kids.isEmpty) {
      throw Exception("No children found for this caregiver");
    }

    final firstKid = kids.first;
    final childId = (firstKid["_id"] ?? firstKid["id"] ?? "").toString();

    if (childId.isEmpty) {
      throw Exception("Child ID not found in children response");
    }

    return childId;
  }

  Future<void> _loadHistory() async {
    final session = context.read<SessionProvider>();

    setState(() {
      historyLoading = true;
      errorMsg = null;
    });

    try {
      final childId = await _resolveChildId(session);
      childIdResolved = childId;

      final data = await api.getPredictionsByUserId(childId);

      setState(() {
        history = (data["data"] as List?) ?? [];
      });
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => historyLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionProvider>();

    setState(() {
      loading = true;
      errorMsg = null;
      predictedScore = null;
      positive = [];
      negative = [];
    });

    try {
      final childId = await _resolveChildId(session);
      childIdResolved = childId;

      final features = <String, dynamic>{
        "gender": gender,
        "diagnosis_type": diagnosisType,
        "activity": activity,
        "mood_label": moodLabel,
        "caregiver_mood_label": caregiverMoodLabel,
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
        "caregiver_sentiment_score": _d(caregiverSentimentCtrl),
        "caregiver_stress_score_combined": _d(caregiverStressCtrl),
        "caregiver_phone_screen_time_mins": _i(caregiverScreenCtrl),
        "caregiver_sleep_hours": _d(caregiverSleepCtrl),
        "phone_screen_time_mins": _i(phoneScreenCtrl),
      };

      final data = await api.predictProgress(features);
      final result = data["result"];

      final rawScore =
          (result["predicted_score_next_14_days"] as num).toDouble();
      final score = _clampScore(rawScore);

      setState(() {
        predictedScore = score;
        positive = result["explainability"]?["top_positive_factors"] ?? [];
        negative = result["explainability"]?["top_negative_factors"] ?? [];
      });

      await api.savePrediction(
        userId: childId,
        progressPrediction: score,
      );

      await _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Prediction saved for child: $childId ✅")),
        );
      }
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // ----------------- Helpers (history -> chart points) -----------------
  double? _safeScore(dynamic item) {
    final v = item?["progress_prediction"];
    if (v is num) return _clampScore(v.toDouble());
    return null;
  }

  DateTime? _safeDate(dynamic item) {
    final s = item?["createdAt"]?.toString();
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  String _fmtShortDate(DateTime d) {
    final dd = d.toLocal().day.toString().padLeft(2, "0");
    final mm = d.toLocal().month.toString().padLeft(2, "0");
    return "$mm/$dd";
  }

  String _fmtDateTime(DateTime? d) {
    if (d == null) return "-";
    final dt = d.toLocal();
    final y = dt.year.toString().padLeft(4, "0");
    final m = dt.month.toString().padLeft(2, "0");
    final day = dt.day.toString().padLeft(2, "0");
    final hh = dt.hour.toString().padLeft(2, "0");
    final min = dt.minute.toString().padLeft(2, "0");
    return "$y-$m-$day $hh:$min";
  }

  /// Returns history sorted ASC by date, with bad rows removed
  List<Map<String, dynamic>> _sortedHistoryForChart() {
    final cleaned = <Map<String, dynamic>>[];

    for (final item in history) {
      final score = _safeScore(item);
      final dt = _safeDate(item);
      if (score == null || dt == null) continue;
      cleaned.add({"date": dt, "score": score});
    }

    cleaned.sort((a, b) =>
        (a["date"] as DateTime).compareTo(b["date"] as DateTime));

    return cleaned;
  }

  Widget _insightChartCard() {
    if (historyLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final points = _sortedHistoryForChart();
    if (points.length < 2) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Insight Chart",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadHistory,
                    icon: const Icon(Icons.refresh),
                    tooltip: "Refresh",
                  )
                ],
              ),
              const SizedBox(height: 6),
              Text(
                points.isEmpty
                    ? "No saved predictions yet."
                    : "Need at least 2 saved predictions to draw a chart.",
              ),
              const SizedBox(height: 6),
              Text("Child ID: ${childIdResolved ?? "-"}"),
            ],
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), (points[i]["score"] as double)));
    }

    // ✅ FIXED Y RANGE: 0..100
    const double minY = 0;
    const double maxY = 100;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Insight Chart",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: _loadHistory,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Refresh",
                )
              ],
            ),
            const SizedBox(height: 4),
            Text("Child ID: ${childIdResolved ?? "-"}"),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,

                  // ✅ Grid lines each 10
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 10,
                    verticalInterval: (points.length <= 6) ? 1 : 2,
                  ),

                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black12),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    // ✅ Y-axis labels: 0,10,20...100
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          // show only exact multiples of 10
                          if (value % 10 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),

                    // ✅ X-axis labels: date
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (points.length <= 6) ? 1 : 2,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final dt = points[idx]["date"] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _fmtShortDate(dt),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((s) {
                          final idx = s.x.toInt();
                          final dt = points[idx]["date"] as DateTime;
                          final score = points[idx]["score"] as double;
                          return LineTooltipItem(
                            "${_fmtDateTime(dt)}\nScore: ${score.toStringAsFixed(2)}",
                            const TextStyle(fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- UI helpers -----------------
  Widget _numField(String label, TextEditingController ctrl, {String hint = ""}) {
    return TextFormField(
      controller: ctrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
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
          items: items
              .map((x) => DropdownMenuItem(value: x, child: Text(x.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _factorList(String title, List<dynamic> factors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

  Widget _predictionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : _predict,
            child: Text(loading ? "Predicting..." : "Predict Now"),
          ),
        ),
        const SizedBox(height: 12),
        if (errorMsg != null)
          Text(errorMsg!, style: const TextStyle(color: Colors.red)),
        if (predictedScore != null) ...[
          const SizedBox(height: 10),
          Text(
            "Predicted Score (Next 14 Days): ${predictedScore!.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _factorList("Top Positive Factors", positive),
          const SizedBox(height: 16),
          _factorList("Top Negative Factors", negative),
        ],
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
      bottomNavigationBar: const MainNavBar(currentIndex: 4),
      backgroundColor: const Color(0xFFF3E8E8),
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Cognitive Progress Prediction",
              notificationCount: 0,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ✅ Insight chart (x=date, y=prediction)
                    _insightChartCard(),
                    const SizedBox(height: 12),

                    // ✅ Prediction UI
                    _predictionSection(),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

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
                      onChanged: (v) =>
                          setState(() => diagnosisType = v ?? "Trisomy21"),
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
                      onChanged: (v) => setState(
                          () => caregiverMoodLabel = v ?? "stressed"),
                    ),
                    const SizedBox(height: 16),

                    const Text("Child Metrics",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    _numField("Age", ageCtrl, hint: "e.g., 5"),
                    const SizedBox(height: 12),
                    _numField("Time Duration for Activity (minutes)", durationCtrl,
                        hint: "e.g., 5"),
                    const SizedBox(height: 12),
                    _numField("Sentiment Score", sentimentCtrl, hint: "e.g., -0.2"),
                    const SizedBox(height: 12),
                    _numField("Stress Score Combined", stressCtrl, hint: "e.g., 0.68"),
                    const SizedBox(height: 12),
                    _numField("Sleep Hours", sleepCtrl, hint: "e.g., 6.5"),
                    const SizedBox(height: 12),
                    _numField("Phone Screen Time (mins)", phoneScreenCtrl,
                        hint: "e.g., 180"),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
