import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:quickalert/quickalert.dart';

import 'package:provider/provider.dart';
import '../../../state/session_provider.dart';
import '../../../services/user_services/child_api.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../services/Interactive_visual_task_scheduler_services/user_activity_service.dart';
import '../../../services/Interactive_visual_task_scheduler_services/system_activity_service.dart';
import '../../Interactive_visual_task_scheduler/systemActivity/detailed_systemActivity.dart';
import 'create_userActivity.dart';
import 'detailed_UserActivity.dart';

class DisplayUserActivityScreen extends StatefulWidget {
  const DisplayUserActivityScreen({super.key});

  @override
  State<DisplayUserActivityScreen> createState() =>
      _DisplayUserActivityScreenState();
}

class _DisplayUserActivityScreenState extends State<DisplayUserActivityScreen> {
  // Colors for theme
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color cardBg = Color(0xFFE9DDCC);

  // TEMP hardcoded logged-in caregiver id, childID, ageGroup
  // static const String hardcodedCaregiverId = "p-0001";
  // static const String hardcodedChildId = "c-0001";
  // static const String hardcodedAgeGroup = "5";

  void _alert(QuickAlertType type, String title, String text) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
      confirmBtnText: "OK",
      confirmBtnColor: const Color(0xFFBD9A6B),
      titleColor: const Color(0xFFBD9A6B),
      textColor: const Color(0xFFBD9A6B),
    );
  }

  // These values are loaded from SessionProvider + Child API (NOT hardcoded)
  String? caregiverId;
  String? childId;
  String? ageGroup;

  String searchQuery = "";

  int suggestedDayTotalSteps = 0;
  int suggestedDayCompletedSteps = 0;

  bool loadingIdentity = false;
  String? identityError;

  String? suggestedPlanMongoId;
  DateTime? suggestedStart;
  DateTime? suggestedEnd;

  bool isSuggested = true;
  DateTime selectedDate = DateTime.now();

  bool loading = false;
  String? errorMsg;

  bool loadingSuggested = false;
  String? suggestedError;

  // Suggested plan
  List<Map<String, dynamic>> suggestedTasks = [];
  // Caregiver's own tasks
  List<Map<String, dynamic>> yourTasks = [];

  // Load caregiverId, childId, ageGroup from session and Child API
  Future<void> _loadCaregiverAndChild() async {
    setState(() {
      loadingIdentity = true;
      identityError = null;
    });

    try {
      // 1) caregiverId from session
      final session = context.read<SessionProvider>();
      final cid = (session.caregiver?['_id'] ?? session.caregiver?['id'] ?? '')
          .toString();

      if (cid.isEmpty) {
        throw Exception(
          "Session error: caregiverId not found. Please login again.",
        );
      }

      // 2) fetch children
      final children = await ChildApi.getChildrenByCaregiver(cid);
      if (children.isEmpty) {
        throw Exception("No child found. Please add a child profile first.");
      }

      // If multiple children exist, for now pick first
      final child = children.first;

      final cId = (child['_id'] ?? child['id'] ?? '').toString();
      if (cId.isEmpty) {
        throw Exception("Child ID missing from API response.");
      }

      final dob = (child['dateOfBirth'] ?? '').toString();
      if (dob.isEmpty) {
        throw Exception("Child dateOfBirth missing from API response.");
      }

      // Calculate age group from dob
      final age = calculateAgeFromDob(dob);

      // set identity
      setState(() {
        caregiverId = cid;
        childId = cId;
        ageGroup = age.toString();
      });
    } catch (e) {
      identityError = e.toString();
      _alert(QuickAlertType.error, "Error", identityError!);
    } finally {
      if (!mounted) return;
      setState(() => loadingIdentity = false);
    }
  }

  // Calculate age from dob
  int calculateAgeFromDob(String dob) {
    final birthDate = DateTime.parse(dob);
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Check if selected date is within suggested cycle
  bool _isWithinSuggestedCycle(DateTime day) {
    if (suggestedStart == null || suggestedEnd == null) return false;

    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(
      suggestedStart!.year,
      suggestedStart!.month,
      suggestedStart!.day,
    );
    final e = DateTime(
      suggestedEnd!.year,
      suggestedEnd!.month,
      suggestedEnd!.day,
    );

    return !d.isBefore(s) && !d.isAfter(e);
  }

  // Handle date selection
  void _onDateSelected(DateTime d) {
    setState(() => selectedDate = d);

    if (isSuggested) {
      if (_isWithinSuggestedCycle(selectedDate)) {
        _refreshSuggestedProgressForDay();
      } else {
        // outside cycle → show empty
        setState(() {
          // keep the plan loaded, but don't show tasks for this date
          suggestedDayTotalSteps = 0;
          suggestedDayCompletedSteps = 0;
        });
      }
    } else {
      _fetchYourTasks();
    }
  }

  // Check if selected date is past date
  bool isPastSelectedDate(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final chosen = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return chosen.isBefore(today);
  }

  // Load suggested plan on init
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCaregiverAndChild();
      if (caregiverId != null && childId != null && ageGroup != null) {
        _fetchSuggestedPlan();
      }
    });
  }

  // Refresh progress for day
  Future<void> _refreshSuggestedProgressForDay() async {
    if (suggestedPlanMongoId == null || suggestedPlanMongoId!.isEmpty) return;
    if (suggestedTasks.isEmpty) return;

    try {
      // Run all activity progress fetches in parallel
      final results = await Future.wait(
        suggestedTasks.map((t) async {
          final activityId = (t["_id"] ?? "").toString();

          // total steps should come from the activity object
          final stepsList = (t["steps"] as List?) ?? [];
          final total = stepsList.length;

          // If activity ID is missing, treat as not started
          if (activityId.isEmpty) {
            return {
              "task": t,
              "total": total,
              "completed": 0,
              "percent": 0,
              "status": "Pending",
            };
          }

          // Fetch progress for this activity on the selected day
          final run = await ChildRoutinePlanService.getRoutineRunProgress(
            caregiverId: caregiverId!,
            childId: childId!,
            planMongoId: suggestedPlanMongoId!,
            activityMongoId: activityId,
            runDate: selectedDate,
          );

          // If no run exists yet, no steps are completed
          if (run == null) {
            return {
              "task": t,
              "total": total,
              "completed": 0,
              "percent": 0,
              "status": "Pending",
            };
          }

          // completed steps should come from steps_progress
          final progress = (run["steps_progress"] as List?) ?? [];
          final completed = progress.where((s) => (s["status"] == true)).length;

          final percent = total == 0 ? 0 : ((completed / total) * 100).round();
          final status = percent == 0
              ? "Pending"
              : (percent == 100 ? "Completed" : "In Progress");

          return {
            "task": t,
            "total": total,
            "completed": completed,
            "percent": percent,
            "status": status,
          };
        }),
      );

      final sumTotal = results.fold<int>(0, (a, r) => a + (r["total"] as int));
      final sumCompleted = results.fold<int>(
        0,
        (a, r) => a + (r["completed"] as int),
      );

      // Update UI task list with calculated percent + status
      final updatedTasks = results.map((r) {
        final t = Map<String, dynamic>.from(r["task"] as Map);
        t["percent"] = r["percent"];
        t["status"] = r["status"];
        return t;
      }).toList();

      if (!mounted) return;
      setState(() {
        suggestedTasks = updatedTasks;
        suggestedDayTotalSteps = sumTotal;
        suggestedDayCompletedSteps = sumCompleted;
      });
    } catch (_) {}
  }

  // Calculate daily progress percent for caregiver's own tasks
  int _dailyProgressPercentForYourTasks(List<dynamic> taskList) {
    int sumTotal = 0;
    int sumCompleted = 0;

    // Sum total and completed steps
    for (final t in taskList) {
      final task = Map<String, dynamic>.from(t as Map);
      final steps = (task["steps"] as List?) ?? [];
      // Ignore tasks with no steps
      sumTotal += steps.length;
      sumCompleted += steps.where((s) => s["status"] == true).length;
    }

    return sumTotal == 0 ? 0 : ((sumCompleted / sumTotal) * 100).round();
  }

  // Fetch suggested percent for activity
  Future<int> _fetchSuggestedPercentForActivity(
    String planId,
    String activityId,
  ) async {
    // fetch activity run progress
    final run = await ChildRoutinePlanService.getRoutineRunProgress(
      caregiverId: caregiverId!,
      childId: childId!,
      planMongoId: planId,
      activityMongoId: activityId,
      runDate: selectedDate,
    );

    if (run == null) return 0;

    // Sum total and completed steps
    final steps = (run["steps_progress"] as List?) ?? [];
    if (steps.isEmpty) return 0;
    // Ignore tasks with no steps
    final done = steps.where((s) => (s["status"] == true)).length;
    return ((done / steps.length) * 100).round();
  }

  // Fetch suggested plan
  Future<void> _fetchSuggestedPlan() async {
    setState(() {
      loadingSuggested = true;
      suggestedError = null;

      suggestedDayTotalSteps = 0;
      suggestedDayCompletedSteps = 0;
    });

    if (caregiverId == null || childId == null || ageGroup == null) return;

    try {
      // Create or fetch starter plan from backend
      final res = await ChildRoutinePlanService.getOrCreateStarterPlan(
        caregiverId: caregiverId!,
        childId: childId!,
        ageGroup: ageGroup!,
      );

      // Extract plan and activities
      final plan = (res["data"] as Map?) ?? {};
      final acts = (plan["activities"] as List?) ?? [];

      // Extract plan start and end dates
      final startStr = (plan["cycle_start_date"] ?? "").toString();
      final endStr = (plan["cycle_end_date"] ?? "").toString();

      // Convert to local timezone
      suggestedStart = startStr.isEmpty
          ? null
          : DateTime.parse(startStr).toLocal();
      suggestedEnd = endStr.isEmpty ? null : DateTime.parse(endStr).toLocal();

      suggestedPlanMongoId = (plan["_id"] ?? "").toString();

      // activities[] -> activityId populated object (Convert activities into UI task objects)
      final list = acts.map<Map<String, dynamic>>((a) {
        final activityObj = (a["activityId"] as Map?) ?? {};

        return {
          "_id": activityObj["_id"],
          "title": (activityObj["title"] ?? "").toString(),
          "desc": (activityObj["description"] ?? "").toString(),
          "img":
              ((activityObj["media_links"] is List &&
                  (activityObj["media_links"] as List).isNotEmpty)
              ? (activityObj["media_links"][0]).toString()
              : "assets/InteractiveVisualTaskScheduler/systemActivityDemo.png"),

          "description": (activityObj["description"] ?? "").toString(),
          "steps": (activityObj["steps"] as List?) ?? [],
          "media_links": (activityObj["media_links"] as List?) ?? [],
          "estimated_duration_minutes":
              activityObj["estimated_duration_minutes"],
          "difficulty_level": activityObj["difficulty_level"],
          "development_area": activityObj["development_area"],
          "age_group": activityObj["age_group"],

          "status": "Pending",
          "percent": 0,
        };
      }).toList();

      // Save suggested tasks
      setState(() => suggestedTasks = list);
      await _refreshSuggestedProgressForDay();
    } catch (e) {
      setState(() => suggestedError = e.toString());
    } finally {
      setState(() => loadingSuggested = false);
    }
  }

  // Fetch caregiver's own tasks by date
  Future<void> _fetchYourTasks() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final data = await UserActivityService.getByDate(
        caregiverId: caregiverId!,
        date: selectedDate,
      );

      // expect List<Map>
      data.sort((a, b) {
        DateTime parseDate(dynamic x) {
          final s = (x ?? "").toString();
          return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
        }

        // try common fields (use whatever your backend returns)
        final da = parseDate(
          a["createdAt"] ??
              a["created_at"] ??
              a["updatedAt"] ??
              a["scheduled_date"],
        );
        final db = parseDate(
          b["createdAt"] ??
              b["created_at"] ??
              b["updatedAt"] ??
              b["scheduled_date"],
        );

        return db.compareTo(da); // latest first
      });

      setState(() => yourTasks = data);
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // Toggle handler between Suggested and Your Tasks
  void _onToggleChanged(bool suggestedSelected) {
    setState(() => isSuggested = suggestedSelected);
    if (suggestedSelected) {
      _fetchSuggestedPlan(); // load suggested plan when switching to Suggested
    } else {
      _fetchYourTasks(); // load user tasks when switching to Your Tasks
    }
  }

  // Calculate progress percent for activity
  int _calcProgressPercent(Map<String, dynamic> activity) {
    final steps = (activity["steps"] as List?) ?? [];
    if (steps.isEmpty) return 0;

    final done = steps.where((s) => (s["status"] == true)).length;
    return ((done / steps.length) * 100).round();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    if (loadingIdentity) {
      return const Scaffold(
        backgroundColor: pageBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (identityError != null) {
      return Scaffold(
        backgroundColor: pageBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Session/Child load failed:\n$identityError",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final bool showSuggestedForThisDate =
        isSuggested && _isWithinSuggestedCycle(selectedDate);

    final tasks = showSuggestedForThisDate
        ? suggestedTasks
        : (isSuggested ? [] : yourTasks);

    final filteredTasks = tasks.where((t) {
      final title = (t["title"] ?? "").toString().toLowerCase();
      return title.contains(searchQuery.toLowerCase());
    }).toList();

    final dailyProgress = isSuggested
        ? (suggestedDayTotalSteps == 0
              ? 0
              : ((suggestedDayCompletedSteps / suggestedDayTotalSteps) * 100)
                    .round())
        : _dailyProgressPercentForYourTasks(filteredTasks);

    final showYour = !isSuggested;
    final bool isDailyLimitReached = yourTasks.length >= 10;
    final canAdd = !isDailyLimitReached && !isPastSelectedDate(selectedDate);

    // Build UI
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const MainHeader(
              title: "Hello!",
              subtitle: "Welcome back",
              notificationCount: 0,
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    _SearchBarWithBack(
                      onBack: () => Navigator.pop(context),
                      onChanged: (v) => setState(() => searchQuery = v.trim()),
                    ),

                    const SizedBox(height: 14),

                    // Calendar
                    ExpandableCalendar(
                      selectedDate: selectedDate,
                      onDateSelected: _onDateSelected,
                    ),

                    const SizedBox(height: 14),

                    // Segment toggle
                    SegmentToggle(
                      leftText: "Suggested",
                      rightText: "Your tasks",
                      isLeftSelected: isSuggested,
                      onLeftTap: () => _onToggleChanged(true),
                      onRightTap: () => _onToggleChanged(false),
                    ),

                    const SizedBox(height: 14),

                    // Progress card
                    _ProgressCard(
                      percent: dailyProgress,
                      kidImagePath:
                          "assets/InteractiveVisualTaskScheduler/kid_trophy.png",
                      isSuggested: isSuggested,
                      ringSize: 125,
                    ),

                    const SizedBox(height: 14),

                    // Task list
                    if (showYour) ...[
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      else if (errorMsg != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            errorMsg!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      else if (yourTasks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "No tasks for this date.",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        // Caregiver's own tasks
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final t = filteredTasks[i];

                            final title = (t["title"] ?? "").toString();
                            final desc = (t["description"] ?? "").toString();

                            final steps = (t["steps"] as List?) ?? [];
                            final done = steps
                                .where((s) => s["status"] == true)
                                .length;
                            final total = steps.length;

                            final percent = _calcProgressPercent(t);

                            final status = total == 0
                                ? "Pending"
                                : (done == 0
                                      ? "Pending"
                                      : (done == total
                                            ? "Completed"
                                            : "In Progress"));

                            final img =
                                (t["img"] ??
                                        "assets/InteractiveVisualTaskScheduler/activityDemo.png")
                                    .toString();

                            return _TaskCard(
                              title: title,
                              desc: desc,
                              status: status,
                              percent: percent,
                              imagePath: img,
                              isNetwork: img.startsWith("http"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailedUserActivityScreen(activity: t),
                                  ),
                                ).then((changed) {
                                  if (changed == true) _fetchYourTasks();
                                });
                              },
                            );
                          },
                        ),
                    ] else ...[
                      // Suggested tasks
                      if (loadingSuggested)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      else if (suggestedError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            suggestedError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      else if (filteredTasks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "No suggested activities found.",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final t = filteredTasks[i];
                            final img =
                                (t["img"] ??
                                        "assets/InteractiveVisualTaskScheduler/activityDemo.png")
                                    .toString();

                            return _TaskCard(
                              title: t["title"].toString(),
                              desc: (t["desc"] ?? "").toString(),
                              status: (t["status"] ?? "Pending").toString(),
                              percent: (t["percent"] as num?)?.toInt() ?? 0,
                              imagePath: img,
                              isNetwork: img.startsWith("http"),
                              onTap: () {
                                final planId = suggestedPlanMongoId ?? "";
                                if (planId.isEmpty) {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: "Missing plan",
                                    text:
                                        "Plan ID not found. Please refresh or try again.",
                                  );

                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailedSystemActivityScreen(
                                          activity: {
                                            ...t,
                                            "selectedDate": selectedDate,
                                          },
                                          planMongoId: planId,
                                          selectedDate: selectedDate,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],

                    const SizedBox(height: 14),

                    // Add task button
                    if (showYour) ...[
                      _CreateTaskButton(
                        enabled: canAdd,
                        onTap: () async {
                          if (!canAdd) return;

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateUserActivityScreen(),
                            ),
                          );

                          _fetchYourTasks();
                        },
                      ),

                      // Info messages for daily limit reached by user
                      if (isDailyLimitReached) ...[
                        const SizedBox(height: 6),
                        const Text(
                          "Daily limit reached (10 activities)",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      // Info messages for past dates selected by user
                      if (isPastSelectedDate(selectedDate)) ...[
                        const SizedBox(height: 6),
                        const Text(
                          "You cannot add tasks for past dates",
                          style: TextStyle(
                            color: Color(0xFFBD9A6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Navigation Bar
      bottomNavigationBar: const MainNavBar(currentIndex: 1),
    );
  }
}

// ------------------------- SEARCH BAR WITH BACK BUTTON ------------------------ //
class _SearchBarWithBack extends StatelessWidget {
  const _SearchBarWithBack({required this.onBack, required this.onChanged});

  final VoidCallback onBack;
  final ValueChanged<String> onChanged;

  // Build the search bar with back button widget
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button (small round)
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9).withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.black54,
              size: 26,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Search bar (same style)
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9).withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Routine",
                      hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------- EXPANDABLE CALENDAR ------------------------- //
class ExpandableCalendar extends StatefulWidget {
  const ExpandableCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<ExpandableCalendar> createState() => _ExpandableCalendarState();
}

class _ExpandableCalendarState extends State<ExpandableCalendar> {
  // UI theme colors for the calendar card
  static const Color cardBg = Color(0xFFDFC7A7);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x22000000);

  bool expanded = false;
  late DateTime focusedDay;

  // Initialize focusedDay with selectedDate
  @override
  void initState() {
    super.initState();
    focusedDay = widget.selectedDate;
  }

  // Build the ExpandableCalendar widget
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadow, blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: TableCalendar(
              firstDay: DateTime.utc(2000),
              lastDay: DateTime.utc(2050),
              focusedDay: focusedDay,
              calendarFormat: expanded
                  ? CalendarFormat.month
                  : CalendarFormat.week,
              headerStyle: const HeaderStyle(
                titleCentered: false,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: stroke,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: stroke),
                rightChevronIcon: Icon(Icons.chevron_right, color: stroke),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 10, color: Colors.black54),
                weekendStyle: TextStyle(fontSize: 10, color: Colors.black54),
              ),
              selectedDayPredicate: (day) =>
                  isSameDay(day, widget.selectedDate),
              onDaySelected: (selected, focused) {
                widget.onDateSelected(selected);
                setState(() => focusedDay = focused);
              },
              onPageChanged: (focused) => focusedDay = focused,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: const BoxDecoration(
                  color: stroke,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  border: Border.all(color: stroke, width: 1.6),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Expand/collapse button
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Container(
              width: 60,
              height: 16,
              alignment: Alignment.center,
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: stroke,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- SEGMENT TOGGLE ------------------------- //
class SegmentToggle extends StatelessWidget {
  final String leftText, rightText;
  final bool isLeftSelected;
  final VoidCallback onLeftTap, onRightTap;

  const SegmentToggle({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.isLeftSelected,
    required this.onLeftTap,
    required this.onRightTap,
  });

  // background and stroke colors
  static const Color bg = Color(0xFFE8DDCD);
  static const Color stroke = Color(0xFFBD9A6B);

  // Build the SegmentToggle widget
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _item(leftText, isLeftSelected, onLeftTap),
          _item(rightText, !isLeftSelected, onRightTap),
        ],
      ),
    );
  }

  // Build individual segment item
  Widget _item(String t, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFDFCCB2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            t,
            style: const TextStyle(color: stroke, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

// ------------------------- PROGRESS CARD ------------------------- //
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.percent,
    required this.kidImagePath,
    required this.isSuggested,
    this.ringSize = 125,
  });

  final int percent;
  final String kidImagePath;
  final bool isSuggested;
  final double ringSize;

  // background and stroke colors
  static const Color cardBg = Color(0xFFF3E8E8);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x22000000);

  // Build the _ProgressCard widget
  @override
  Widget build(BuildContext context) {
    // Progress ring
    final ring = Transform.scale(
      scale: 2.7, // Enlarges the ring visually without changing layout size
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: percent / 100.0,
              strokeWidth: 5,
              backgroundColor: Colors.white.withOpacity(0.65),
              color: stroke,
            ),
            Text(
              "$percent%",
              style: const TextStyle(
                color: stroke,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );

    // Text and ring column
    final textAndRing = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: isSuggested
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // Card title
          Text(
            "Your Today’s\nProgress",
            textAlign: isSuggested ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              color: stroke,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationColor: stroke,
            ),
          ),
          const SizedBox(height: 10),

          // Flexible stops "Bottom overflowed"
          Flexible(
            child: Align(
              alignment: isSuggested
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: ring,
            ),
          ),
        ],
      ),
    );

    // Child image
    final kidImage = Expanded(
      child: Align(
        alignment: isSuggested ? Alignment.centerRight : Alignment.centerLeft,
        child: Image.asset(kidImagePath, height: 160, fit: BoxFit.contain),
      ),
    );

    // Build the progress card container
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stroke.withOpacity(0.7), width: 1.4),
        boxShadow: const [
          BoxShadow(color: shadow, blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: SizedBox(
        height: 180,
        child: Row(
          children: isSuggested
              ? [textAndRing, const SizedBox(width: 12), kidImage]
              : [kidImage, const SizedBox(width: 12), textAndRing],
        ),
      ),
    );
  }
}

// ------------------------- TASK CARD ------------------------- //
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.desc,
    required this.status,
    required this.percent,
    required this.imagePath,
    required this.isNetwork,
    required this.onTap,
  });

  final String title, desc, status, imagePath;
  final bool isNetwork;
  final int percent;
  final VoidCallback onTap;

  static const Color stroke = Color(0xFFBD9A6B);
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color shadow = Color(0x22000000);

  // Build the _TaskCard widget
  @override
  Widget build(BuildContext context) {
    // Choose image widget based on source type
    final imageWidget = isNetwork
        ? Image.network(imagePath, height: 110, width: 90, fit: BoxFit.contain)
        : Image.asset(imagePath, height: 110, width: 90, fit: BoxFit.contain);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: shadow, blurRadius: 14, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            // Left color bar + 3 dots
            Container(
              width: 15,
              decoration: const BoxDecoration(
                color: Color(0xFFDFC7A7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(),
                    SizedBox(height: 6),
                    _Dot(),
                    SizedBox(height: 6),
                    _Dot(),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),
            // Activity image
            imageWidget,
            const SizedBox(width: 12),

            // Task details
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: stroke,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    desc,
                    style: TextStyle(
                      color: stroke.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Progress percentage and status
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: stroke.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$percent%",
                    style: const TextStyle(
                      color: stroke,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- DOT ------------------------- //
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFFBD9A6B),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ------------------------- CREATE TASK BUTTON ------------------------- //
class _CreateTaskButton extends StatelessWidget {
  const _CreateTaskButton({required this.onTap, this.enabled = true});

  final VoidCallback onTap; // Callback when button is pressed
  final bool enabled; // Controls enabled/disabled state

  static const Color stroke = Color(0xFFBD9A6B);

  // Build the _CreateTaskButton widget
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? stroke : stroke.withOpacity(0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "+ Add New Task",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
