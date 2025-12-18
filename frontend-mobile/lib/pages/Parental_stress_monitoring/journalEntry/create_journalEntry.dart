import 'package:flutter/material.dart';

// ✅ update these imports to your project paths
import '../../others/header.dart'; // MainHeader
import '../../others/navBar.dart'; // MainNavBar

// ✅ service import (path exactly as you asked)
import '../../../services/Parental_stress_monitoring/journal_entry.dart';

class CreateJournalEntryScreen extends StatefulWidget {
  const CreateJournalEntryScreen({super.key});

  @override
  State<CreateJournalEntryScreen> createState() => _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState extends State<CreateJournalEntryScreen> {
  final TextEditingController _noteCtrl = TextEditingController();
  final DateTime _today = DateTime.now();

  // ✅ CHANGE THIS to your backend IP + port
  final JournalEntryService _service =
      const JournalEntryService(baseUrl: "http://YOUR_SERVER_IP:PORT");

  // ✅ Replace later with real logged-in caregiver id
  final String _caregiverId = "u-0001";

  // UI label+emoji list
  final List<Map<String, String>> _moods = const [
    {"label": "Happy", "emoji": "😃"},
    {"label": "Calm", "emoji": "😌"},
    {"label": "Neutral", "emoji": "🙂"},
    {"label": "Tired", "emoji": "🥱"},
    {"label": "Sad", "emoji": "😢"},
    {"label": "Angry", "emoji": "😡"},
    {"label": "Stressed", "emoji": "😖"},
  ];

  // UI label -> backend enum value
  final Map<String, String> _moodToEnum = const {
    "Happy": "happy",
    "Calm": "calm",
    "Neutral": "neutral",
    "Tired": "tired",
    "Sad": "sad",
    "Angry": "angry",
    "Stressed": "stressed",
  };

  Map<String, String>? _selectedMood;
  bool _saving = false;

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  Future<void> _save() async {
    if (_saving) return;

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your mood")),
      );
      return;
    }

    final text = _noteCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write something")),
      );
      return;
    }

    final label = _selectedMood!["label"]!;
    final emoji = _selectedMood!["emoji"]!;
    final moodEnum = _moodToEnum[label] ?? "neutral";

    setState(() => _saving = true);

    try {
      await _service.createJournalEntry(
        caregiverId: _caregiverId,
        mood: moodEnum,
        moodEmoji: emoji,
        text: text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Journal saved successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CColors.pageBg,

      // ✅ bottom nav
      bottomNavigationBar: const MainNavBar(currentIndex: 0),

      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 5,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    decoration: BoxDecoration(
                      color: _CColors.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _CColors.blueBorder, width: 3),
                    ),
                    child: Column(
                      children: [
                        // date + close
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _DateChip(text: _formatDate(_today)),
                            _CloseCircle(onTap: () => Navigator.pop(context)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          "How do you feel today?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _CColors.goldText,
                            decoration: TextDecoration.underline,
                            decorationColor: _CColors.goldText,
                            decorationThickness: 2,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // illustration
                        SizedBox(
                          height: 150,
                          child: Image.asset(
                            "assets/journal_illustration.png",
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.draw_rounded,
                              size: 120,
                              color: Color(0xFFB9A38B),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // mood row
                        Row(
                          children: [
                            const Expanded(
                              flex: 4,
                              child: Text(
                                "Your Mood :",
                                style: TextStyle(
                                  color: _CColors.goldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: _MoodDropdown(
                                moods: _moods,
                                value: _selectedMood,
                                onChanged: (m) => setState(() => _selectedMood = m),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Write Something :",
                            style: TextStyle(
                              color: _CColors.goldText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // textarea
                        Container(
                          decoration: BoxDecoration(
                            color: _CColors.inputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _CColors.inputBorder, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x16000000),
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _noteCtrl,
                            maxLines: 5,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _CColors.goldText,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Write a short note about your day...",
                              hintStyle: TextStyle(
                                color: Color(0xFFBFA780),
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: EdgeInsets.fromLTRB(14, 14, 14, 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // save button
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 120,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _CColors.saveBtn,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Save",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
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
}

/* ===================== SMALL WIDGETS ===================== */

class _DateChip extends StatelessWidget {
  final String text;
  const _DateChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9DDCC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _CColors.inputBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: _CColors.goldText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.calendar_month_rounded, color: _CColors.goldText, size: 18),
        ],
      ),
    );
  }
}

class _CloseCircle extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 54,
        height: 54,
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
        child: const Icon(Icons.close_rounded, color: _CColors.goldText, size: 26),
      ),
    );
  }
}

class _MoodDropdown extends StatelessWidget {
  final List<Map<String, String>> moods;
  final Map<String, String>? value;
  final ValueChanged<Map<String, String>?> onChanged;

  const _MoodDropdown({
    required this.moods,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _CColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _CColors.inputBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, String>>(
          value: value,
          hint: const Text(""),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _CColors.goldText),
          items: moods.map((m) {
            final label = m["label"]!;
            final emoji = m["emoji"]!;
            return DropdownMenuItem<Map<String, String>>(
              value: m,
              child: Text(
                "$emoji  $label",
                style: const TextStyle(
                  color: _CColors.goldText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/* ===================== COLORS ===================== */

class _CColors {
  static const Color pageBg = Color(0xFFF3ECE4);
  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color blueBorder = Color(0xFF5A8FE6);

  static const Color goldText = Color(0xFFC6A477);

  static const Color inputBg = Color(0xFFE9DDCC);
  static const Color inputBorder = Color(0xFFB79B72);

  static const Color saveBtn = Color(0xFFB79B72);
}
