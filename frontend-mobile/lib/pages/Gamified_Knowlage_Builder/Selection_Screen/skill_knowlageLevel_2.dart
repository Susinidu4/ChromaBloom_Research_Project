import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../others/header.dart';
import '../../others/navBar.dart';
import '../../../state/session_provider.dart';
import '../../../services/user_services/child_api.dart';
import '../../../services/Gemified/problem_solving_level.dart';

class SkillKnowledgeLevelPage_2 extends StatelessWidget {
  const SkillKnowledgeLevelPage_2({super.key});

  static const Color pageBg = Color(0xFFF3E8E8);
  static const String _prefKeyProblemLevelSet = "problem_solving_skill_level_set";
  static const String _prefKeyProblemLevelValue = "problem_solving_skill_level_value";

  Future<void> _saveLevelAndGo(BuildContext context, String rawSelection) async {
    String mappedLevel = "Beginner";
    if (rawSelection == "basic") {
      mappedLevel = "Intermediate";
    } else if (rawSelection == "most") {
      mappedLevel = "Advanced";
    }

    try {
      final session = Provider.of<SessionProvider>(context, listen: false);
      final caregiver = session.caregiver;

      if (caregiver != null) {
        final caregiverId = (caregiver['_id'] ?? caregiver['id']).toString();
        
        // 2. Get children
        final children = await ChildApi.getChildrenByCaregiver(caregiverId);
        
        if (children.isNotEmpty) {
          final child = children.first;
          final childId = (child['_id'] ?? child['id']).toString();

          // 3. Try to get existing level to decide if we create or update
          bool exists = false;
          try {
            await ProblemSolvingLevelService.getLevelByUserId(childId);
            exists = true;
          } catch (e) {
            exists = false;
          }

          // 4. Create or Update
          if (exists) {
            await ProblemSolvingLevelService.updateLevelByUserId(
              userId: childId,
              level: mappedLevel,
            );
          } else {
            await ProblemSolvingLevelService.createLevel(
              userId: childId,
              level: mappedLevel,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error storing problem solving level: $e");
      // Continue anyway to not block user flow, or show a snackbar
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyProblemLevelSet, true);
    await prefs.setString(_prefKeyProblemLevelValue, mappedLevel);

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/startG');
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    _BackCircleButton(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    _KnowledgeCard(
                      onSelect: (level) => _saveLevelAndGo(context, level),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 3),
    );
  }
}
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
