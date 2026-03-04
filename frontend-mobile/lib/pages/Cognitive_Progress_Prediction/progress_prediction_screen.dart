import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/Cognitive_Progress_Prediction/cognitive_progress_service.dart';
import '../../services/user_services/child_api.dart';
import '../../services/Parental_stress_monitoring/digital_wellbeing_log_service.dart';
import '../../services/Parental_stress_monitoring/stress_analysis_service.dart';
import '../../state/session_provider.dart';

import '../others/header.dart';
import '../others/navBar.dart';
import '../../services/api_config.dart'; // ✅ Added import

import './insight_chart_card.dart';

class ProgressPredictionScreen extends StatefulWidget {
  const ProgressPredictionScreen({super.key});

  @override
  State<ProgressPredictionScreen> createState() => _ProgressPredictionScreenState();
}

class _ProgressPredictionScreenState extends State<ProgressPredictionScreen> {
  // ✅ Use shared config
  final api = ProgressPredictionApi(baseUrl: ApiConfig.baseUrl);

  // ✅ Digital wellbeing service
  final wellbeingService = DigitalWellbeingService();

  bool loading = false;
  double? predictedScore;
  List<dynamic> positive = [];
  List<dynamic> negative = [];
  String? errorMsg;

  // ✅ History
  bool historyLoading = false;
  String? childIdResolved;
  List<dynamic> history = [];

  // ✅ Child auto load
  bool childLoading = false;
  Map<String, dynamic>? childData;

  // ✅ Digital wellbeing load
  bool wellbeingLoading = false;
  double? avgScreenTimeMin;

  // ✅ Stress history avg load
  bool stressAvgLoading = false;
  double? avgStressProbability; // 0..1

  // -------------------- AUTO from child --------------------
  String gender = "male";
  String diagnosisType = "Trisomy21";
  int ageYears = 5;

  // -------------------- TEMP HARDCODED (no input fields) --------------------
  static const String _hardActivity = "Matching picture cards";
  static const String _hardMoodLabel = "tired";
  static const int _hardTimeDurationMin = 5;
  static const double _hardSentimentScore = -0.2;
  static const double _hardSleepHours = 6.5;

  // -------------------- TEMP HARDCODED (removed user inputs) --------------------
  static const String _hardCaregiverMoodLabel = "stressed";

  static const double _hardStressScoreCombined = 0.68;
  static const int _hardTotalTasksAssigned = 6;
  static const int _hardTotalTasksCompleted = 5;
  static const double _hardCompletionRate = 0.83;
  static const double _hardEngagementMinutes = 18.5;

  static const double _hardMemoryAccuracy = 0.65;
  static const double _hardAttentionAccuracy = 0.72;
  static const double _hardProblemSolvingAccuracy = 0.58;
  static const double _hardMotorSkillsAccuracy = 0.74;
  static const double _hardAverageResponseTime = 3.4;

  static const double _hardCaregiverSentimentScore = -0.15;
  static const double _hardCaregiverSleepHours = 5.8;

  // -------------------- HIDE THESE FEATURES IN POS/NEG LISTS --------------------
  static const Set<String> _hideExplainFeatures = {
    "caregiver_sleep_hours",
    "caregiver_sentiment_score",
  };

  List<dynamic> _filteredFactors(List<dynamic> factors) {
    return factors.where((f) {
      final key = (f["feature"] ?? "").toString().trim().toLowerCase();
      return !_hideExplainFeatures.contains(key);
    }).toList();
  }

  double _clampScore(double v) {
    if (v.isNaN || v.isInfinite) return 0;
    if (v < 0) return 0;
    if (v > 100) return 100;
    return v;
  }

  // -------------------- CHILD AUTO LOAD HELPERS --------------------

  String _normalizeGender(String raw) {
    final g = raw.trim().toLowerCase();
    if (g == "female" || g == "f") return "female";
    return "male";
  }

  String _mapDownSyndromeType(String raw) {
    final v = raw.trim().toLowerCase();
    if (v.contains("mosaic")) return "Mosaicism";
    if (v.contains("trans")) return "Translocation";
    return "Trisomy21";
  }

  int _calcAgeYearsFromIso(String? iso) {
    if (iso == null || iso.trim().isEmpty) return 0;
    try {
      final dob = DateTime.parse(iso).toLocal();
      final now = DateTime.now();

      int age = now.year - dob.year;
      final hadBirthdayThisYear =
          (now.month > dob.month) || (now.month == dob.month && now.day >= dob.day);
      if (!hadBirthdayThisYear) age -= 1;
      if (age < 0) age = 0;
      return age;
    } catch (_) {
      return 0;
    }
  }

  String _resolveCaregiverId(SessionProvider session) {
    final caregiver = session.caregiver;
    if (caregiver == null) throw Exception("Not logged in");

    final caregiverId =
        (caregiver["_id"] ?? caregiver["id"] ?? caregiver["caregiverId"] ?? "")
            .toString();

    if (caregiverId.isEmpty) {
      throw Exception("Caregiver ID not found in session");
    }
    return caregiverId;
  }

  Future<String> _resolveChildId(SessionProvider session) async {
    final caregiver = session.caregiver;
    if (caregiver == null) throw Exception("Not logged in");

    final directChildId = (caregiver["childId"] ?? caregiver["child_id"] ?? "").toString();
    if (directChildId.isNotEmpty) return directChildId;

    if (caregiver["childIds"] is List && (caregiver["childIds"] as List).isNotEmpty) {
      final first = (caregiver["childIds"] as List).first;
      final id = first?.toString() ?? "";
      if (id.isNotEmpty) return id;
    }

    if (caregiver["children"] is List && (caregiver["children"] as List).isNotEmpty) {
      final first = (caregiver["children"] as List).first;
      if (first is Map) {
        final id = (first["_id"] ?? first["id"] ?? "").toString();
        if (id.isNotEmpty) return id;
      }
    }

    final caregiverId = _resolveCaregiverId(session);
    final kids = await ChildApi.getChildrenByCaregiver(caregiverId);

    if (kids.isEmpty) throw Exception("No children found for this caregiver");

    final firstKid = kids.first;
    final childId = (firstKid["_id"] ?? firstKid["id"] ?? "").toString();
    if (childId.isEmpty) throw Exception("Child ID not found in children response");

    return childId;
  }

  // -------------------- DIGITAL WELLBEING: AVG SCREEN TIME --------------------

  double _extractScreenTimeMin(Map<String, dynamic> log) {
    final raw = log["total_screen_time_min"] ??
        log["totalScreenTimeMin"] ??
        log["total_screen_time_mins"] ??
        log["totalScreenTimeMins"];

    if (raw == null) return double.nan;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString().trim()) ?? double.nan;
  }

  Future<void> _loadAvgScreenTimeFromWellbeing() async {
    if (!mounted) return;
    final session = context.read<SessionProvider>();

    setState(() {
      wellbeingLoading = true;
      errorMsg = null;
    });

    try {
      final caregiverId = _resolveCaregiverId(session);
      final logs = await wellbeingService.getLogsByCaregiverId(caregiverId);

      double sum = 0;
      int count = 0;

      for (final log in logs) {
        final v = _extractScreenTimeMin(log);
        if (!v.isNaN && v.isFinite && v >= 0) {
          sum += v;
          count += 1;
        }
      }

      final avg = (count == 0) ? 0.0 : (sum / count);

      setState(() {
        avgScreenTimeMin = avg;
      });
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => wellbeingLoading = false);
    }
  }

  // -------------------- STRESS: AVG STRESS PROBABILITY --------------------

  Future<void> _loadAvgStressProbability() async {
    if (!mounted) return;
    final session = context.read<SessionProvider>();

    setState(() {
      stressAvgLoading = true;
      errorMsg = null;
    });

    try {
      final caregiverId = _resolveCaregiverId(session);

      final list = await StressAnalysisService.getHistoryByCaregiver(
        caregiverId: caregiverId,
      );

      double sum = 0;
      int count = 0;

      for (final item in list) {
        final v = item.stressProbability;
        if (v.isFinite && v >= 0) {
          sum += v;
          count += 1;
        }
      }

      final avg = (count == 0) ? 0.0 : (sum / count);

      setState(() {
        avgStressProbability = avg;
      });
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => stressAvgLoading = false);
    }
  }

  // -------------------- CHILD AUTO LOAD + AUTOFILL --------------------

  Future<void> _loadChildAndAutofill() async {
    final session = context.read<SessionProvider>();

    setState(() {
      childLoading = true;
      errorMsg = null;
    });

    try {
      final caregiverId = _resolveCaregiverId(session);

      // ✅ load wellbeing avg + stress avg first
      await _loadAvgScreenTimeFromWellbeing();
      await _loadAvgStressProbability();

      final kids = await ChildApi.getChildrenByCaregiver(caregiverId);
      if (kids.isEmpty) throw Exception("No children found for this caregiver");

      final first = kids.first;
      if (first is! Map) throw Exception("Unexpected child response shape");

      final cid = (first["_id"] ?? first["id"] ?? "").toString();
      if (cid.isEmpty) throw Exception("Child ID missing in response");

      childIdResolved = cid;
      childData = Map<String, dynamic>.from(first);

      final childGender = (first["gender"] ?? "male").toString();
      final dsType = (first["downSyndromeType"] ?? "Trisomy21").toString();
      final dobIso = (first["dateOfBirth"] ?? "").toString();

      final computedAge = _calcAgeYearsFromIso(dobIso);
      final safeAge = (computedAge <= 0) ? 5 : computedAge;

      setState(() {
        gender = _normalizeGender(childGender);
        diagnosisType = _mapDownSyndromeType(dsType);
        ageYears = safeAge;
      });

      await _loadHistory();
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => childLoading = false);
    }
  }

  // -------------------- HISTORY --------------------

  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      historyLoading = true;
      errorMsg = null;
    });

    try {
      String childId = childIdResolved ?? "";
      if (childId.isEmpty) {
        final session = context.read<SessionProvider>();
        childId = await _resolveChildId(session);
        childIdResolved = childId;
      }

      final data = await api.getPredictionsByUserId(childId);

      setState(() {
        history = (data["data"] as List?) ?? [];
      });
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => historyLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildAndAutofill());
  }

  // -------------------- PREDICT --------------------

  Future<void> _predict() async {
    final session = context.read<SessionProvider>();

    setState(() {
      loading = true;
      errorMsg = null;
      predictedScore = null;
      positive = [];
      negative = [];
    });

    try {
      if (avgScreenTimeMin == null) await _loadAvgScreenTimeFromWellbeing();
      if (avgStressProbability == null) await _loadAvgStressProbability();

      final avgScreenInt = (avgScreenTimeMin ?? 0.0).round();
      final avgStress = (avgStressProbability ?? 0.0);

      final childId = childIdResolved ?? await _resolveChildId(session);
      childIdResolved = childId;

      // ✅ extra safety
      final safeAge = (ageYears <= 0) ? 5 : ageYears;

      final features = <String, dynamic>{
        "gender": gender,
        "diagnosis_type": diagnosisType,
        "age": safeAge,

        "activity": _hardActivity,
        "mood_label": _hardMoodLabel,
        "time_duration_for_activity": _hardTimeDurationMin,
        "sentiment_score": _hardSentimentScore,
        "sleep_hours": _hardSleepHours,

        "caregiver_mood_label": _hardCaregiverMoodLabel,
        "stress_score_combined": _hardStressScoreCombined,

        "total_tasks_assigned": _hardTotalTasksAssigned,
        "total_tasks_completed": _hardTotalTasksCompleted,
        "completion_rate": _hardCompletionRate,
        "engagement_minutes": _hardEngagementMinutes,

        "memory_accuracy": _hardMemoryAccuracy,
        "attention_accuracy": _hardAttentionAccuracy,
        "problem_solving_accuracy": _hardProblemSolvingAccuracy,
        "motor_skills_accuracy": _hardMotorSkillsAccuracy,
        "average_response_time": _hardAverageResponseTime,

        "caregiver_sentiment_score": _hardCaregiverSentimentScore,

        // ✅ AUTO: use avg stress probability as caregiver stress score combined
        "caregiver_stress_score_combined": avgStress,

        "caregiver_phone_screen_time_mins": avgScreenInt,
        "phone_screen_time_mins": avgScreenInt,

        "caregiver_sleep_hours": _hardCaregiverSleepHours,
      };

      final data = await api.predictProgress(features);
      final result = data["result"];

      final rawScore = (result["predicted_score_next_14_days"] as num).toDouble();
      final score = _clampScore(rawScore);

      setState(() {
        predictedScore = score;

        // ✅ filter out caregiver sleep/sentiment from explainability display
        positive = _filteredFactors(result["explainability"]?["top_positive_factors"] ?? []);
        negative = _filteredFactors(result["explainability"]?["top_negative_factors"] ?? []);
      });

      // ✅ Map factors to backend-friendly format (List<Map<String, dynamic>>)
      final posFactors = positive.map((f) => {
        "feature": (f["feature"] ?? "").toString(),
        "shap_value": ((f["shap_value"] as num?) ?? 0.0).toDouble(),
      }).toList();

      final negFactors = negative.map((f) => {
        "feature": (f["feature"] ?? "").toString(),
        "shap_value": ((f["shap_value"] as num?) ?? 0.0).toDouble(),
      }).toList();

      await api.savePrediction(
        userId: childId,
        progressPrediction: score,
        positiveFactors: posFactors,
        negativeFactors: negFactors,
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
      if (mounted) setState(() => loading = false);
    }
  }

  // ----------------- Decorated UI -----------------
  static const Color _cardBg = Color(0xFFF1E6D8);
  static const Color _barFill = Color(0xFFC4A26A);
  static const Color _barTrack = Color(0xFFD9D9D9);
  static const Color _outlineBlue = Color(0xFF2B79FF);

  BoxDecoration _pngCardDecoration() {
    return BoxDecoration(
      color: _cardBg,
      borderRadius: BorderRadius.circular(16),
      // border: Border.all(color: _outlineBlue, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.50),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  double _maxAbsShap(List<dynamic> factors) {
    double maxV = 0.000001;
    for (final f in factors) {
      final v = ((f["shap_value"] as num?) ?? 0).toDouble().abs();
      if (v > maxV) maxV = v;
    }
    return maxV;
  }

  Widget _progressBar({required double value01, double height = 10}) {
    final v = value01.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: _barTrack,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Container(
              height: height,
              width: w * v,
              decoration: BoxDecoration(
                color: _barFill,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _factorRow({required String label, required double value01}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.8, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        _progressBar(value01: value01, height: 10),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _factorsCard({required String title, required List<dynamic> factors}) {
    final maxAbs = _maxAbsShap(factors);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _pngCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (factors.isEmpty)
            const Text("No factors returned")
          else
            ...factors.take(5).map((f) {
              final feature = (f["feature"] ?? "-").toString().replaceAll("_", " ");
              final shapVal = ((f["shap_value"] as num?) ?? 0).toDouble();
              final v01 = (shapVal.abs() / maxAbs).clamp(0.0, 1.0);
              return _factorRow(label: feature, value01: v01);
            }),
        ],
      ),
    );
  }

  Widget _predictionScoreCard(double score) {
    final v01 = (score / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _pngCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Prediction Score (Next 14 Days)",
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _progressBar(value01: v01, height: 12),
          const SizedBox(height: 8),
          Text(
            "${score.toStringAsFixed(2)} / 100",
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
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
            onPressed: (loading || childLoading || wellbeingLoading || stressAvgLoading)
                ? null
                : _predict,
            style: ElevatedButton.styleFrom(
              backgroundColor: _barFill,
              foregroundColor: Colors.white,
              elevation: 10,
            ),
            child: Text(
              childLoading
                  ? "Loading child..."
                  : (wellbeingLoading
                      ? "Loading wellbeing..."
                      : (stressAvgLoading
                          ? "Loading stress..."
                          : (loading ? "Predicting..." : "Predict Now"))),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (errorMsg != null) Text(errorMsg!, style: const TextStyle(color: Colors.red)),
        if (predictedScore != null) ...[
          const SizedBox(height: 10),
          _predictionScoreCard(predictedScore!),
          const SizedBox(height: 16),
          _factorsCard(title: "Top Positive Factors", factors: positive),
          const SizedBox(height: 16),
          _factorsCard(title: "Top Negative Factors", factors: negative),
        ],
      ],
    );
  }

  Widget _childSummaryCard() {
    final c = childData;
    if (c == null) return const SizedBox.shrink();

    final name = (c["childName"] ?? "-").toString();
    final id = (c["_id"] ?? "-").toString();
    final dob = (c["dateOfBirth"] ?? "-").toString();
    final ds = (c["downSyndromeType"] ?? "-").toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _pngCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Child Auto-Loaded",
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text("ID: $id"),
          Text("Name: $name"),
          Text("DOB: $dob"),
          Text("Down Syndrome Type: $ds"),
        ],
      ),
    );
  }

  Widget _wellbeingAvgCard() {
    final avg = avgScreenTimeMin;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _pngCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Digital Wellbeing (Auto)",
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (wellbeingLoading)
            const Text("Loading wellbeing logs...")
          else
            Text(
              "Average Screen Time: ${(avg ?? 0).toStringAsFixed(1)} mins",
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _stressAvgCard() {
    final avg = avgStressProbability;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _pngCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stress (Auto)",
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (stressAvgLoading)
            const Text("Loading stress history...")
          else
            Text(
              "Average Stress Probability: ${(avg ?? 0).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _childSummaryCard(),
                  if (childData != null) const SizedBox(height: 12),

                  _wellbeingAvgCard(),
                  const SizedBox(height: 12),

                  _stressAvgCard(),
                  const SizedBox(height: 12),

                  InsightChartCard(
                    loading: historyLoading,
                    history: history,
                    childId: childIdResolved,
                    onRefresh: _loadHistory,
                  ),
                  const SizedBox(height: 12),

                  _predictionSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
