import 'package:flutter/material.dart';

class FirstTimeOptionsPage extends StatelessWidget {
  const FirstTimeOptionsPage({super.key});

  static const Color bg = Color(0xFFF6EDED);
  static const Color gold = Color(0xFFC89B62);
  static const Color blue = Color(0xFF235870);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: blue,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Choose an option to continue",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B6B43),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),

              _BigOptionCard(
                title: "Caregiver + Child Register",
                subtitle: "Create caregiver profile and add child details",
                icon: Icons.family_restroom_rounded,
                onTap: () => Navigator.pushNamed(context, '/caregiver_signup'),
              ),

              const SizedBox(height: 14),

              _BigOptionCard(
                title: "Already have an account?",
                subtitle: "Login as Caregiver",
                icon: Icons.login_rounded,
                onTap: () => Navigator.pushNamed(context, '/caregiver_login'),
              ),

              const Spacer(),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  child: const Text(
                    "Skip for now",
                    style: TextStyle(
                      color: gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BigOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  static const Color gold = Color(0xFFC89B62);
  static const Color card = Color(0xFFE8DDCE);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: gold.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: gold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB88F55),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: gold),
          ],
        ),
      ),
    );
  }
}
