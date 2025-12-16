import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

// IMPORTANT: make sure you registered this in MaterialApp routes
// routes: { '/createUserActivity': (_) => const CreateUserActivityScreen(), }

class DisplayUserActivityScreen extends StatefulWidget {
  const DisplayUserActivityScreen({super.key});

  @override
  State<DisplayUserActivityScreen> createState() =>
      _DisplayUserActivityScreenState();
}

class _DisplayUserActivityScreenState extends State<DisplayUserActivityScreen> {
  static const Color pageBg = Color(0xFFF3E8E8);

  bool isSuggested = true;
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> suggestedTasks = [
    {
      "title": "Mindful Reading",
      "desc": "Description",
      "status": "Completed",
      "percent": 100,
      "img": "assets/brushing_teeth.png",
    },
    {
      "title": "Organizing",
      "desc": "Description",
      "status": "In Progress",
      "percent": 70,
      "img": "assets/create_user_activity.png",
    },
  ];

  final List<Map<String, dynamic>> yourTasks = [
    {
      "title": "Simple Yoga",
      "desc": "Description",
      "status": "Pending",
      "percent": 0,
      "img": "assets/create_user_activity.png",
    },
    {
      "title": "Folding Cloths",
      "desc": "Description",
      "status": "Pending",
      "percent": 0,
      "img": "assets/brushing_teeth.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tasks = isSuggested ? suggestedTasks : yourTasks;

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
                    _SearchBar(onChanged: (_) {}),
                    const SizedBox(height: 14),

                    ExpandableCalendar(
                      selectedDate: selectedDate,
                      onDateSelected: (d) => setState(() => selectedDate = d),
                    ),

                    const SizedBox(height: 14),

                    SegmentToggle(
                      leftText: "Suggested",
                      rightText: "Your tasks",
                      isLeftSelected: isSuggested,
                      onLeftTap: () => setState(() => isSuggested = true),
                      onRightTap: () => setState(() => isSuggested = false),
                    ),

                    const SizedBox(height: 14),

                    _ProgressCard(
                      percent: isSuggested ? 80 : 62,
                      kidImagePath: "assets/kid_trophy.png",
                      isSuggested: isSuggested,
                    ),

                    const SizedBox(height: 14),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final t = tasks[i];
                        return _TaskCard(
                          title: t["title"],
                          desc: t["desc"],
                          status: t["status"],
                          percent: t["percent"],
                          imagePath: t["img"],
                          onTap: () {},
                        );
                      },
                    ),

                    // ✅ CREATE NEW TASK BUTTON (only for "Your tasks")
                    if (!isSuggested) ...[
                      const SizedBox(height: 14),
                      _CreateTaskButton(
                        onTap: () {
                          // ✅ Correct navigation (named route)
                          Navigator.pushNamed(context, '/createUserActivity');
                        },
                      ),
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

/* ======================================================
   REAL EXPANDABLE CALENDAR (WEEK ⇄ MONTH)
====================================================== */
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

/* ======================================================
   SEARCH BAR
====================================================== */
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

/* ======================================================
   TOGGLE
====================================================== */
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

/* ======================================================
  PROGRESS CARD (NO OVERFLOW)
  Suggested: image RIGHT, text+ring LEFT
  Your tasks: image LEFT, text+ring RIGHT (right aligned)
====================================================== */
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.percent,
    required this.kidImagePath,
    required this.isSuggested,
  });

  final int percent;
  final String kidImagePath;
  final bool isSuggested;

  static const Color cardBg = Color(0xFFF3E8E8);
  static const Color stroke = Color(0xFFBD9A6B);
  static const Color shadow = Color(0x22000000);

  @override
  Widget build(BuildContext context) {
    final kidImage = Image.asset(
      kidImagePath,
      height: 180,
      fit: BoxFit.contain,
    );

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

    final textAndRing = Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ important (prevents extra height)
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
              decorationColor: stroke, // ✅ underline color
            ),
          ),
          const SizedBox(height: 10), // ✅ instead of Spacer()
          Align(
            alignment: isSuggested
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: ring,
          ),
        ],
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isSuggested
            ? [
                // Suggested: LEFT text+ring, RIGHT image
                textAndRing,
                const SizedBox(width: 12),
                Align(alignment: Alignment.centerRight, child: kidImage),
              ]
            : [
                // Your tasks: LEFT image, RIGHT text+ring (right aligned)
                Align(alignment: Alignment.centerLeft, child: kidImage),
                const SizedBox(width: 12),
                textAndRing,
              ],
      ),
    );
  }
}

/* ======================================================
   CREATE BUTTON
====================================================== */
class _CreateTaskButton extends StatelessWidget {
  const _CreateTaskButton({required this.onTap});
  final VoidCallback onTap;

  static const Color stroke = Color(0xFFBD9A6B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: stroke,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Create a new task",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

/* ======================================================
   TASK CARD
====================================================== */
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.desc,
    required this.status,
    required this.percent,
    required this.imagePath,
    required this.onTap,
  });

  final String title, desc, status, imagePath;
  final int percent;
  final VoidCallback onTap;

  static const Color stroke = Color(0xFFBD9A6B);
  static const Color cardBg = Color(0xFFE9DDCC);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 105,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, height: 85, width: 85),
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
                  Text(
                    desc,
                    style: TextStyle(
                      color: stroke.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: stroke.withOpacity(0.85),
                    fontSize: 10,
                  ),
                ),
                Text(
                  "$percent%",
                  style: const TextStyle(
                    color: stroke,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
