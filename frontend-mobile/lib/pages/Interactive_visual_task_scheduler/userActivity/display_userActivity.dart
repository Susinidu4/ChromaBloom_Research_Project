import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../services/Interactive_visual_task_scheduler_services/user_activity_service.dart';
import '../../../services/Interactive_visual_task_scheduler_services/system_activity_service.dart';
import 'create_userActivity.dart';

import 'detailed_UserActivity.dart';
import '../../Interactive_visual_task_scheduler/systemActivity/detailed_systemActivity.dart';

class DisplayUserActivityScreen extends StatefulWidget {
  const DisplayUserActivityScreen({super.key});

  @override
  State<DisplayUserActivityScreen> createState() =>
      _DisplayUserActivityScreenState();
}

class _DisplayUserActivityScreenState extends State<DisplayUserActivityScreen> {
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color cardBg = Color(0xFFE9DDCC);

  String searchQuery = "";

  // ✅ TEMP hardcoded logged-in caregiver id, childID, ageGroup
  //static const String hardcodedCaregiverId = "u-005";

  static const String hardcodedCaregiverId = "p-0001";
  static const String hardcodedChildId = "c-0001";
  static const String hardcodedAgeGroup = "5";

  String? suggestedPlanMongoId;
  DateTime? suggestedStart;
  DateTime? suggestedEnd;

  bool isSuggested = true;
  DateTime selectedDate = DateTime.now();

  bool loading = false;
  String? errorMsg;

  bool loadingSuggested = false;
  String? suggestedError;

  List<Map<String, dynamic>> suggestedTasks = [];

  List<Map<String, dynamic>> yourTasks = [];

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

  void _onDateSelected(DateTime d) {
    setState(() => selectedDate = d);

    if (isSuggested) {
      if (_isWithinSuggestedCycle(selectedDate)) {
        _refreshSuggestedProgressForDay();
      } else {
        // outside cycle → show empty
        setState(() {
          // keep the plan loaded, but don't show tasks for this date
          // you can either clear list OR show message using UI condition
        });
      }
    } else {
      _fetchYourTasks();
    }
  }

  @override
  void initState() {
    super.initState();
    // optional: if you want to auto-load when opening "Your tasks" first, set isSuggested=false

    _fetchSuggestedPlan();
  }

  Future<void> _refreshSuggestedProgressForDay() async {
    if (suggestedPlanMongoId == null || suggestedPlanMongoId!.isEmpty) return;
    if (suggestedTasks.isEmpty) return;

    try {
      final futures = suggestedTasks.map((t) async {
        final activityId = (t["_id"] ?? "").toString();
        if (activityId.isEmpty) return t;

        final run = await ChildRoutinePlanService.getRoutineRunProgress(
          caregiverId: hardcodedCaregiverId,
          childId: hardcodedChildId,
          planMongoId: suggestedPlanMongoId!,
          activityMongoId: activityId,
          runDate: selectedDate, // ✅ calendar day
        );

        if (run == null) {
          // no progress saved for this day
          return {...t, "percent": 0, "status": "Pending"};
        }

        final total = (run["total_steps"] ?? 0) as int;
        final completed = (run["completed_steps"] ?? 0) as int;
        final percent = total == 0 ? 0 : ((completed / total) * 100).round();

        final status = percent == 0
            ? "Pending"
            : (percent == 100 ? "Completed" : "In Progress");

        return {...t, "percent": percent, "status": status};
      }).toList();

      final updated = await Future.wait(futures);
      if (!mounted) return;
      setState(() => suggestedTasks = updated);
    } catch (_) {
      // ignore for UI
    }
  }

  Future<int> _fetchSuggestedPercentForActivity(
    String planId,
    String activityId,
  ) async {
    final run = await ChildRoutinePlanService.getRoutineRunProgress(
      caregiverId: hardcodedCaregiverId,
      childId: hardcodedChildId,
      planMongoId: planId,
      activityMongoId: activityId,
      runDate: selectedDate, // ✅ per day
    );

    if (run == null) return 0;

    final steps = (run["steps_progress"] as List?) ?? [];
    if (steps.isEmpty) return 0;

    final done = steps.where((s) => (s["status"] == true)).length;
    return ((done / steps.length) * 100).round();
  }

  Future<void> _fetchSuggestedPlan() async {
    setState(() {
      loadingSuggested = true;
      suggestedError = null;
    });

    try {
      final res = await ChildRoutinePlanService.getOrCreateStarterPlan(
        caregiverId: hardcodedCaregiverId,
        childId: hardcodedChildId,
        ageGroup: hardcodedAgeGroup,
      );

      final plan = (res["data"] as Map?) ?? {};
      final acts = (plan["activities"] as List?) ?? [];

      final startStr = (plan["cycle_start_date"] ?? "").toString();
      final endStr = (plan["cycle_end_date"] ?? "").toString();

      suggestedStart = startStr.isEmpty
          ? null
          : DateTime.parse(startStr).toLocal();
      suggestedEnd = endStr.isEmpty ? null : DateTime.parse(endStr).toLocal();

      suggestedPlanMongoId = (plan["_id"] ?? "").toString();

      // activities[] -> activityId populated object
      final list = acts.map<Map<String, dynamic>>((a) {
        final activityObj = (a["activityId"] as Map?) ?? {};

        return {
          "_id": activityObj["_id"],
          "title": (activityObj["title"] ?? "").toString(),

          // ✅ make UI keys exist
          "desc": (activityObj["description"] ?? "").toString(),
          "img":
              ((activityObj["media_links"] is List &&
                  (activityObj["media_links"] as List).isNotEmpty)
              ? (activityObj["media_links"][0]).toString()
              : "assets/brushing_teeth.png"),

          // keep extra fields if you want
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

      setState(() => suggestedTasks = list);
      await _refreshSuggestedProgressForDay();
      final planId = suggestedPlanMongoId ?? "";
      for (final t in list) {
        final actId = (t["_id"] ?? "").toString();
        if (planId.isNotEmpty && actId.isNotEmpty) {
          t["percent"] = await _fetchSuggestedPercentForActivity(planId, actId);
          t["status"] = (t["percent"] == 100)
              ? "Completed"
              : (t["percent"] == 0 ? "Pending" : "In Progress");
        }
      }
      setState(() => suggestedTasks = list);
    } catch (e) {
      setState(() => suggestedError = e.toString());
    } finally {
      setState(() => loadingSuggested = false);
    }
  }

  Future<void> _fetchYourTasks() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final data = await UserActivityService.getByDate(
        caregiverId: hardcodedCaregiverId,
        date: selectedDate,
      );

      // expect List<Map>
      setState(() => yourTasks = data);
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void _onToggleChanged(bool suggestedSelected) {
    setState(() => isSuggested = suggestedSelected);
    if (suggestedSelected) {
      _fetchSuggestedPlan(); // ✅ when switching to Suggested
    } else {
      _fetchYourTasks();
    }
  }

  int _calcProgressPercent(Map<String, dynamic> activity) {
    final steps = (activity["steps"] as List?) ?? [];
    if (steps.isEmpty) return 0;

    final done = steps.where((s) => (s["status"] == true)).length;
    return ((done / steps.length) * 100).round();
  }

  int _dailyProgressPercentForList(
    List<dynamic> taskList, {
    required bool suggested,
  }) {
    if (taskList.isEmpty) return 0;

    int total = 0;

    for (final t in taskList) {
      final task = Map<String, dynamic>.from(t as Map);

      final p = suggested
          ? ((task["percent"] as num?)?.toInt() ?? 0) // suggestedTasks percent
          : _calcProgressPercent(task); // yourTasks from steps.status

      total += p;
    }

    return (total / taskList.length).round(); // average
  }

  @override
  Widget build(BuildContext context) {
    final bool showSuggestedForThisDate =
        isSuggested && _isWithinSuggestedCycle(selectedDate);

    final tasks = showSuggestedForThisDate
        ? suggestedTasks
        : (isSuggested ? [] : yourTasks);

    final filteredTasks = tasks.where((t) {
      final title = (t["title"] ?? "").toString().toLowerCase();
      return title.contains(searchQuery.toLowerCase());
    }).toList();

    final dailyProgress = _dailyProgressPercentForList(
      filteredTasks,
      suggested: isSuggested,
    );

    final showYour = !isSuggested;
    final bool isDailyLimitReached = yourTasks.length >= 10;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello!",
              subtitle: "Welcome back",
              notificationCount: 0,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    _SearchBar(
                      onChanged: (v) => setState(() => searchQuery = v.trim()),
                    ),
                    const SizedBox(height: 14),

                    ExpandableCalendar(
                      selectedDate: selectedDate,
                      onDateSelected: _onDateSelected, // ✅ use handler
                    ),

                    const SizedBox(height: 14),

                    SegmentToggle(
                      leftText: "Suggested",
                      rightText: "Your tasks",
                      isLeftSelected: isSuggested,
                      onLeftTap: () => _onToggleChanged(true),
                      onRightTap: () => _onToggleChanged(false),
                    ),

                    const SizedBox(height: 14),

                    _ProgressCard(
                      percent: dailyProgress,
                      kidImagePath: "assets/kid_trophy.png",
                      isSuggested: isSuggested,
                      ringSize: 125,
                    ),

                    const SizedBox(height: 14),

                    // ✅ Content area
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
                                (t["img"] ?? "assets/brushing_teeth.png")
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
                                (t["img"] ?? "assets/brushing_teeth.png")
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Missing planId"),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailedSystemActivityScreen(
                                      activity: {
                                        ...t,
                                        "selectedDate":
                                            selectedDate, // optional if you still want it
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

                    if (showYour) ...[
                      _CreateTaskButton(
                        enabled: !isDailyLimitReached,
                        onTap: () async {
                          if (isDailyLimitReached) return;

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateUserActivityScreen(),
                            ),
                          );

                          _fetchYourTasks();
                        },
                      ),

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
                    ],

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 1),
    );
  }
}

/* ===================== CALENDAR ===================== */
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
  static const Color cardBg = Color(0xFFDFC7A7);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x22000000);

  bool expanded = false;
  late DateTime focusedDay;

  @override
  void initState() {
    super.initState();
    focusedDay = widget.selectedDate;
  }

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

/* ===================== SEARCH ===================== */
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const Icon(Icons.search, color: Colors.black54),
        ],
      ),
    );
  }
}

/* ===================== TOGGLE ===================== */
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

  static const Color bg = Color(0xFFE8DDCD);
  static const Color stroke = Color(0xFFBD9A6B);

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

/* ===================== PROGRESS CARD ===================== */
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

  static const Color cardBg = Color(0xFFF3E8E8);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x22000000);

  @override
  Widget build(BuildContext context) {
    // ✅ Ring widget (same as yours)
    final ring = Transform.scale(
      scale: 2.7, // Scale factor (1.25 = 125% of original size)
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
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );

    // ✅ IMPORTANT: Make ring area flexible to avoid overflow
    final textAndRing = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: isSuggested
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
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

          // ✅ Flexible stops "Bottom overflowed"
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

    final kidImage = Expanded(
      child: Align(
        alignment: isSuggested ? Alignment.centerRight : Alignment.centerLeft,
        child: Image.asset(kidImagePath, height: 160, fit: BoxFit.contain),
      ),
    );

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
        height: 180, // keep your design same
        child: Row(
          children: isSuggested
              ? [textAndRing, const SizedBox(width: 12), kidImage]
              : [kidImage, const SizedBox(width: 12), textAndRing],
        ),
      ),
    );
  }
}

/* ===================== CREATE BUTTON ===================== */
class _CreateTaskButton extends StatelessWidget {
  const _CreateTaskButton({required this.onTap, this.enabled = true});

  final VoidCallback onTap;
  final bool enabled;

  static const Color stroke = Color(0xFFBD9A6B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null, // ✅ disables button
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? stroke
              : stroke.withOpacity(0.4), // greyed look
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

/* ===================== TASK CARD ===================== */
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

  @override
  Widget build(BuildContext context) {
    final imageWidget = isNetwork
        ? Image.network(imagePath, height: 80, width: 80, fit: BoxFit.contain)
        : Image.asset(imagePath, height: 80, width: 80, fit: BoxFit.contain);

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
            imageWidget,
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: stroke,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
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
