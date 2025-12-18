import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class JournalsScreen extends StatelessWidget {
  const JournalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _JColors.pageBg,

      // ✅ ADD THIS
      bottomNavigationBar: const MainNavBar(currentIndex: 0),

      body: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            const MainHeader(
              title: "Hello!",
              subtitle: "Welcome back",
              notificationCount: 5,
            ),

            // ===== Body =====
            Expanded(
              child: Stack(
                children: [
                  // page background
                  Positioned.fill(child: Container(color: _JColors.pageBg)),

                  // Content
                  Column(
                    children: [
                      const SizedBox(height: 12),

                      // Back button + small floating button (right)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CircleIconButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      // Title "Journals" with underline
                      const Text(
                        "Journals",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _JColors.goldText,
                          decoration: TextDecoration.underline,
                          decorationColor: _JColors.goldText,
                          decorationThickness: 2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Illustration + Date tile + Add New
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // big illustration (left)
                            Expanded(
                              child: Image.asset(
                                "assets/display_Journals.png",
                                fit: BoxFit.contain,
                                width: 198,
                                height: 198,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // date tile + add button (right column)
                            Column(
                              children: [
                                _DateTile(date: DateTime.now()),
                                const SizedBox(height: 18),
                                _AddNewButton(
                                  onTap: () {
                                    Navigator.pushNamed(context, "/createJournalEntry");
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Journal list (scrollable)
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                          children: const [
                            _JournalCard(
                              dateText: "2/11/2025",
                              emoji: "😁",
                              text: "I feel joy with my child’s new skills",
                              showEdit: true,
                              showDelete: true,
                            ),
                            SizedBox(height: 16),
                            _JournalCard(
                              dateText: "1/11/2025",
                              emoji: "😡",
                              text: "I feel joy with my child’s new skills",
                              showEdit: false,
                              showDelete: true,
                            ),
                            SizedBox(height: 16),
                            _JournalCard(
                              dateText: "31/10/2025",
                              emoji: "😢",
                              text: "I feel joy with my child’s new skills",
                              showEdit: false,
                              showDelete: true,
                            ),
                            SizedBox(height: 16),
                            _JournalCard(
                              dateText: "2/11/2025",
                              emoji: "😣",
                              text: "I feel joy with my child’s new skills",
                              showEdit: false,
                              showDelete: true,
                            ),
                          ],
                        ),
                      ),
                    ],
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

/* ===================== TOP ICON BUTTONS ===================== */

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF3ECE4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: _JColors.goldText, size: 26),
        ),
      ),
    );
  }
}

/* ===================== DATE TILE ===================== */

class _DateTile extends StatelessWidget {
  final DateTime date;

  const _DateTile({required this.date});

  String get month {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[date.month - 1];
  }

  String get day => date.day.toString();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 103,
      decoration: BoxDecoration(
        color: _JColors.tileBeige,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(5, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // dots row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E8E8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            month,
            style: const TextStyle(
              color: _JColors.goldText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day,
            style: const TextStyle(
              color: _JColors.goldText,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== ADD NEW BUTTON ===================== */

class _AddNewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(132, 33),
        side: const BorderSide(color: _JColors.goldText, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      ),
      icon: const Icon(Icons.add, color: _JColors.goldText, size: 20),
      label: const Text(
        "Add New",
        style: TextStyle(
          color: _JColors.goldText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/* ===================== JOURNAL CARD ===================== */

class _JournalCard extends StatelessWidget {
  final String dateText;
  final String emoji;
  final String text;
  final bool showEdit;
  final bool showDelete;

  const _JournalCard({
    required this.dateText,
    required this.emoji,
    required this.text,
    required this.showEdit,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _JColors.tileBeige,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // left date + emoji + text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: _JColors.goldText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: const TextStyle(
                    color: _JColors.goldText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // right icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showEdit)
                IconButton(
                  onPressed: () {
                    // TODO: edit action
                  },
                  icon: const Icon(Icons.mode_edit_outlined),
                  color: const Color(0xFFC6A477),
                ),
              if (showDelete)
                IconButton(
                  onPressed: () {
                    // TODO: delete action
                  },
                  icon: const Icon(Icons.delete_forever_outlined),
                  color: _JColors.trashRed,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ===================== COLORS ===================== */

class _JColors {
  static const Color pageBg = Color(0xFFF3E8E8);

  static const Color goldText = Color(0xFFBD9A6B);
  static const Color tileBeige = Color(0xFFE9DDCC);

  static const Color trashRed = Color(0xFF974333);
}
