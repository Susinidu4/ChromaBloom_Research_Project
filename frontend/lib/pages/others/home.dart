import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ---- Colors ----
  final Color _primaryBlue = const Color(0xFF235870);
  final Color _lightBackground = const Color(0xFFF7EDE4);
  final Color _cardBackground = const Color(0xFFFFF9F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildHeroCard(),
              const SizedBox(height: 24),
              _buildFeatureGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= LOGOS =================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/chromabloom1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                 
                  SizedBox(
                    width: 100,
                    height: 70,
                    child: Image.asset(
                      'assets/chromabloom2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ================= BOTTOM ROW: TEXT + PROFILE =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // left side: greeting text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hello !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Welcome Back.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // right side: profile icon
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HERO CARD =================
  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Designed for Caregivers.\nLoved by Children. ❤️',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'A personalized, AI-powered support system designed to help children with Down Syndrome grow, learn, and thrive—while supporting caregivers every step of the way.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Illustration placeholder
            SizedBox(
              height: 110,
              width: 80,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  Icons.family_restroom,
                  size: 80,
                  color: _primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FEATURE GRID =================
  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.78,
        children: [
          _FeatureCard(
            title: 'Parental Stress\nMonitoring &\nSupport System',
            icon: Icons.sentiment_very_dissatisfied,
            onTap: () {},
          ),
          _FeatureCard(
            title: 'Task Scheduler\n& Routine Builder',
            icon: Icons.checklist_rounded,
            onTap: () {},
          ),
          _FeatureCard(
            title: 'Gamified\nKnowledge\nBuilder',
            icon: Icons.videogame_asset_rounded,
            onTap: () {},
          ),
          _FeatureCard(
            title: 'Cognitive\nProfiling &\nProgress',
            icon: Icons.psychology_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ================= FEATURE CARD WIDGET =================
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF235870);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2E0),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.07),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
