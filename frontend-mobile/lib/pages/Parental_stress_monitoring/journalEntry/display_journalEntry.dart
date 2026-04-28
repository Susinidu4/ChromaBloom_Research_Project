import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import 'package:provider/provider.dart';
import '../../../state/session_provider.dart';

import '../../others/header.dart';
import '../../others/navBar.dart';

import '../../../services/Parental_stress_monitoring/journal_entry.dart';

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  State<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen> {
  final JournalEntryService _service = JournalEntryService();
  bool _errorShown = false;
  bool _notLoggedIn = false;

  // hardcode for now (until login)
  //final String _caregiverId = "p-0001";

// Helper to show themed QuickAlert (same theme everywhere)
  Future<void> showThemedAlert({
    required QuickAlertType type,
    required String title,
    required String text,
  }) async {
    await QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
      confirmBtnText: 'OK',
      backgroundColor: const Color(0xFFFFFFFF),
      titleColor: const Color(0xFFBD9A6B),
      textColor: const Color(0xFFBD9A6B),
      confirmBtnColor: const Color(0xFFBD9A6B),
    );
  }

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

// helper to format date as "DD/MM/YYYY"
  String _formatDateDMY(DateTime d) => "${d.day}/${d.month}/${d.year}";

// helper to check if two dates are on the same calendar day
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // mood -> emoji map (fallback)
  static const Map<String, String> _moodToEmoji = {
    "happy": "😃",
    "calm": "😌",
    "neutral": "🙂",
    "tired": "🥱",
    "sad": "😢",
    "angry": "😡",
    "stressed": "😖",
  };

  // ===== load journals (last 14 days) =====
  Future<List<Map<String, dynamic>>> _load() async {
    final session = context.read<SessionProvider>();
    final caregiverId =
        (session.caregiver?['_id'] ?? session.caregiver?['id'] ?? '')
            .toString();

    if (caregiverId.isEmpty) {
  if (!_notLoggedIn) {
    _notLoggedIn = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showThemedAlert(
        type: QuickAlertType.error,
        title: "Login Required",
        text: "Please login to view journals.",
      );
    });
  }
  return [];
}
_notLoggedIn = false;

// fetch all journals for caregiver, then filter/sort in app (since we don't have a "get recent journals" API)
    final list = await _service.getJournalsByCaregiver(caregiverId);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(
      const Duration(days: 13),
    ); // 14 days including today

    final filtered = list.where((e) {
      final created = _parseDate(e['created_at']?.toString());
      if (created == null) return false;
      final createdDay = DateTime(created.year, created.month, created.day);
      return !createdDay.isBefore(cutoff);
    }).toList();

    filtered.sort((a, b) {
      final da = _parseDate(a['created_at']?.toString()) ?? DateTime(1970);
      final db = _parseDate(b['created_at']?.toString()) ?? DateTime(1970);
      return db.compareTo(da);
    });

    return filtered;
  }

  // refresh (NO async inside setState)
  Future<void> _refresh() async {
    setState(() {
      _future = _load(); // <-- assign Future only (no await)
      _errorShown = false;
      _notLoggedIn = false;
    });
  }

  // ===== delete =====
  Future<void> _confirmDelete(String entryId) async {
  if (entryId.isEmpty) return;

  await QuickAlert.show(
    context: context,
    type: QuickAlertType.confirm,
    title: "Delete Journal",
    text: "Are you sure you want to delete this journal entry?",
    confirmBtnText: "Delete",
    cancelBtnText: "Cancel",
    showCancelBtn: true,
    barrierDismissible: false,

    // EXACT THEME
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    titleColor: const Color(0xFFBD9A6B),
    textColor: const Color(0xFFBD9A6B),
    confirmBtnColor: const Color(0xFFBD9A6B),

    onConfirmBtnTap: () async {
      // close confirm alert
      Navigator.of(context, rootNavigator: true).pop();

      try {
        await _service.deleteJournal(entryId);
        if (!mounted) return;

        // success alert
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Deleted",
          text: "Deleted successfully",
          confirmBtnText: "OK",

          // EXACT THEME
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          titleColor: const Color(0xFFBD9A6B),
          textColor: const Color(0xFFBD9A6B),
          confirmBtnColor: const Color(0xFFBD9A6B),
        );

        await _refresh();
      } catch (e) {
        if (!mounted) return;

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Delete Failed",
          text: e.toString(),
          confirmBtnText: "OK",

          // EXACT THEME
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          titleColor: const Color(0xFFBD9A6B),
          textColor: const Color(0xFFBD9A6B),
          confirmBtnColor: const Color(0xFFBD9A6B),
        );
      }
    },

    onCancelBtnTap: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );
}


// ===== show journal details in a dialog =====

  Future<void> _showJournalDetails({
    required String dateText,
    required String moodLabel,
    required String emoji,
    required String fullText,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: const Color(0xAA000000), // grey overlay
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE9DDCC), // outer soft bg
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ConstrainedBox(
              // dialog grows/shrinks with content, but won't exceed screen
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogCtx).size.height * 0.65,
              ),
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9DDCC), // inner beige card
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFBD9A6B),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // ===== Date pill (top-left) =====
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9DDCC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFBD9A6B),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateText,
                                style: const TextStyle(
                                  color: Color(0xFFBD9A6B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: Color(0xFFBD9A6B),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ===== Close circle (top-right) =====
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Navigator.pop(dialogCtx),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3E8E8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x55000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                size: 34,
                                color: Color(0xFFBD9A6B),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== Main content =====
                      Padding(
                        padding: const EdgeInsets.only(top: 70),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // emoji + mood
                            Row(
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  moodLabel,
                                  style: const TextStyle(
                                    color: Color(0xFFBD9A6B),
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // text scrolls only if very long
                            Flexible(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Text(
                                  fullText,
                                  style: const TextStyle(
                                    color: Color(0xFFBD9A6B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== edit (same day only) =====
  Future<void> _editEntry(Map<String, dynamic> entry) async {
    final entryId = entry['_id']?.toString() ?? "";
    if (entryId.isEmpty) return;

    final created = _parseDate(entry['created_at']?.toString());
    final now = DateTime.now();

    // allow edit only within the added day (same day)
    if (created == null || !_isSameDay(created, now)) {
      await showThemedAlert(
        type: QuickAlertType.warning,
        title: "Not Allowed",
        text: "Edit is allowed only on the same day.",
      );

      return;
    }

    final textCtrl = TextEditingController(
      text: (entry['text'] ?? "").toString(),
    );
    String mood = (entry['mood'] ?? "neutral").toString();
    String emoji = (entry['moodEmoji'] ?? _moodToEmoji[mood] ?? "🙂")
        .toString();

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFE9DDCC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Text(
          "Edit Journal",
          style: TextStyle(
            color: Color(0xFFBD9A6B),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Mood dropdown =====
            DropdownButtonFormField<String>(
              value: mood,
              dropdownColor: const Color(0xFFF3E8E8),
              decoration: InputDecoration(
                labelText: "Mood",
                labelStyle: const TextStyle(color: Color(0xFFBD9A6B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFBD9A6B),
                    width: 1.4,
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "happy", child: Text("😃  Happy")),
                DropdownMenuItem(value: "calm", child: Text("😌  Calm")),
                DropdownMenuItem(value: "neutral", child: Text("🙂  Neutral")),
                DropdownMenuItem(value: "tired", child: Text("🥱  Tired")),
                DropdownMenuItem(value: "sad", child: Text("😢  Sad")),
                DropdownMenuItem(value: "angry", child: Text("😡  Angry")),
                DropdownMenuItem(
                  value: "stressed",
                  child: Text("😖  Stressed"),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                mood = v;
                emoji = _moodToEmoji[mood] ?? "🙂";
              },
            ),

            const SizedBox(height: 14),

            // ===== Text field =====
            TextField(
              controller: textCtrl,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFF6B4F2D), fontSize: 15),
              decoration: InputDecoration(
                labelText: "Text",
                labelStyle: const TextStyle(color: Color(0xFFBD9A6B)),
                hintText: "Edit your note...",
                hintStyle: const TextStyle(color: Color(0xFFBD9A6B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFBD9A6B),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),

        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          // ===== Cancel =====
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF8B6B4F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ===== Save =====
          SizedBox(
            width: 80,
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBD9A6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Save",
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );

    if (saved != true) return;

    try {
      await _service.updateJournal(
        entryId: entryId,
        mood: mood,
        moodEmoji: emoji,
        text: textCtrl.text.trim(),
      );

      if (!mounted) return;

      await showThemedAlert(
        type: QuickAlertType.success,
        title: "Updated",
        text: "Updated successfully",
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;
      await showThemedAlert(
        type: QuickAlertType.error,
        title: "Update Failed",
        text: e.toString(),
      );
    }
  }

// ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _JColors.pageBg,
      bottomNavigationBar: const MainNavBar(currentIndex: 0),

      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello!",
              subtitle: "Welcome back",
            ),

            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: _JColors.pageBg)),

                  Column(
                    children: [
                      const SizedBox(height: 12),

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

// top section with image, date tile, and add button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Image.asset(
                                "assets/display_Journals.png",
                                fit: BoxFit.contain,
                                width: 198,
                                height: 198,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              children: [
                                _DateTile(date: DateTime.now()),
                                const SizedBox(height: 18),
                                _AddNewButton(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/createJournalEntry",
                                    ).then((_) => _refresh());
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

  // journal list (future builder)
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _future,
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snap.hasError) {
                              if (!_errorShown) {
                                _errorShown = false;
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  showThemedAlert(
                                    type: QuickAlertType.error,
                                    title: "Load Failed",
                                    text: snap.error.toString(),
                                  );
                                });
                              }

                              return const Center(
                                child: Text(
                                  "Unable to load journals.",
                                  style: TextStyle(
                                    color: _JColors.goldText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            final items = snap.data ?? [];

                            if (_notLoggedIn) {
                              return const Center(
                                child: Text(
                                  "Please login to view journals.",
                                  style: TextStyle(
                                    color: _JColors.goldText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            if (items.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No journals in the last 14 days.",
                                  style: TextStyle(
                                    color: _JColors.goldText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }
// pull to refresh list of journals
                            return RefreshIndicator(
                              onRefresh: _refresh,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  6,
                                  18,
                                  18,
                                ),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, i) {
                                  final e = items[i];

                                  final created = _parseDate(
                                    e['created_at']?.toString(),
                                  );
                                  final dateText = created == null
                                      ? "-"
                                      : _formatDateDMY(created);

                                  final mood = (e['mood'] ?? "neutral")
                                      .toString();
                                  final emoji =
                                      (e['moodEmoji'] ??
                                              _moodToEmoji[mood] ??
                                              "🙂")
                                          .toString();

                                  final text = (e['text'] ?? "").toString();
                                  final entryId = e['_id']?.toString() ?? "";

                                  final canEdit =
                                      created != null &&
                                      _isSameDay(created, DateTime.now());

                                  final moodLabel =
                                      mood[0].toUpperCase() +
                                      mood.substring(1); // "happy" -> "Happy"

// journal card with edit/delete buttons (edit only if same day)
                                  return _JournalCard(
                                    dateText: dateText,
                                    emoji: emoji,
                                    text: text,
                                    showEdit: canEdit,
                                    showDelete: true,
                                    onEdit: () => _editEntry(e),
                                    onDelete: () => _confirmDelete(entryId),

                                    onTap: () => _showJournalDetails(
                                      dateText: dateText,
                                      moodLabel: moodLabel,
                                      emoji: emoji,
                                      fullText: text,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
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

// circular button with an icon, used for back navigation and other actions in the journal screen
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

// custom styled tile to display the date in the top section of the journal screen, showing month and day with decorative dots
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

// custom styled outlined button with an add icon, used to navigate to the create journal entry screen
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

// display a summary of each journal entry in the list
class _JournalCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String dateText;
  final String emoji;
  final String text;
  final bool showEdit;
  final bool showDelete;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.dateText,
    required this.emoji,
    required this.text,
    required this.showEdit,
    required this.showDelete,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                    maxLines: 1, // limit lines (or 3 if you prefer)
                    overflow: TextOverflow.ellipsis, 
                    softWrap: true,
                    style: const TextStyle(
                      color: _JColors.goldText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // edit/delete buttons (only show if allowed)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showEdit)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.mode_edit_outlined),
                    color: const Color(0xFFC6A477),
                  ),
                if (showDelete)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_forever_outlined),
                    color: _JColors.trashRed,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// centralized color definitions for the journal screen, used for consistent theming across all widgets
class _JColors {
  static const Color pageBg = Color(0xFFF3E8E8);
  static const Color goldText = Color(0xFFBD9A6B);
  static const Color tileBeige = Color(0xFFE9DDCC);
  static const Color trashRed = Color(0xFF974333);
}
