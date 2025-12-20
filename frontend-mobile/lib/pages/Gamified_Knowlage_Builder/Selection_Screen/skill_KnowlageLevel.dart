import 'package:flutter/material.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';

class SkillKnowledgeLevelPage extends StatelessWidget {
  const SkillKnowledgeLevelPage({super.key});

  static const Color pageBg = Color(0xFFF3E8E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const MainHeader(
              title: "Hello !",
              subtitle: "Welcome Back.",
              notificationCount: 5,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    _BackCircleButton(
                      onTap: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 10),

                    _KnowledgeCard(
                      onSelect: (level) {
                        debugPrint("Selected level: $level");
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const MainNavBar(currentIndex: 2),
    );
  }
}

/* ===================== BACK BUTTON ===================== */

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F2E8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: Color(0xFFB0896E),
          ),
        ),
      ),
    );
  }
}

/* ===================== CARD ===================== */

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard({required this.onSelect});

  final void Function(String level) onSelect;

  static const Color cardBg = Color(0xFFE9DDCC);
  static const Color textColor = Color(0xFFBD9A6B);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3A000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),

              const Text(
                "How much skill knowledge\n does your child have?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              Image.asset(
                "assets/skill_level.png",
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Illustration Missing",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _ChoiceButton(
                label: "I'm New",
                onTap: () => onSelect("new"),
              ),
              const SizedBox(height: 10),
              _ChoiceButton(
                label: "Know some common",
                onTap: () => onSelect("some_common"),
              ),
              const SizedBox(height: 10),
              _ChoiceButton(
                label: "Know Basic",
                onTap: () => onSelect("basic"),
              ),
              const SizedBox(height: 10),
              _ChoiceButton(
                label: "Know most",
                onTap: () => onSelect("most"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== BUTTON ===================== */

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  static const Color textColor = Color(0xFFBD9A6B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 42,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFBD9A6B), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
