import 'package:flutter/material.dart';
import '../others/profile_options_dialog.dart';

import '../../services/Parental_stress_monitoring/consent_service.dart';
import '../Parental_stress_monitoring/stressAnalysis/wellnessPermission.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ---- Colors ----
  final Color _primaryBlue = const Color(0xFF235870);
  final Color _lightBackground = const Color(0xFFF7EDE4);

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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/chromabloom1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -70),
                    child: SizedBox(
                      width: 170,
                      height: 140,
                      child: Image.asset(
                        'assets/chromabloom2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 0),

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
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Welcome Back.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),

              // right side: profile icon
              GestureDetector(
                onTap: () {
                  showProfileOptionsDialog(context);
                },
                child: Container(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HERO CARD =================
  Widget _buildHeroCard() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none, // allows overlap
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBD9A6B), // <-- new border color
                width: 3,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,

              // reduce width of text column
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6, // 60% width

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Designed for Caregivers. Loved by Children. ❤️",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBD9A6B), // <-- text color
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Empowering caregivers to nurture creativity and learning in children through engaging digital experiences.",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Color(0xFFBD9A6B), // <-- text color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Image overlapping the right border
          Positioned(
            right: -30,
            top: 25,
            child: Image.asset(
              "assets/images/banner_image.png",
              width: 200,
              height: 200,
            ),
          ),
        ],
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
          // 1. Parental Stress Monitoring - BLUE GRAY
          _FeatureCard(
            title: 'Parental Stress\nMonitoring &\nSupport System',
            imagePath: 'assets/h1.png',
            bgColor: const Color(0xFF6993AB),
            onTap: () async {
              try {
                final caregiverId =
                    "p-0001"; // TODO: replace with real logged-in ID
                final consentApi = ConsentService();

                // 1️⃣ Check existing consent from DB
                final consent = await consentApi.getConsent(caregiverId);
                final bool alreadyAllowed =
                    consent != null &&
                    consent["digital_wellbeing_consent"] == true;

                // 2️⃣ If already allowed → skip dialog completely
                if (alreadyAllowed) {
                  if (!context.mounted) return;
                  Navigator.pushNamed(context, '/WellnessHome');
                  return;
                }

                // 3️⃣ Otherwise show permission dialog
                await showDigitalWellbeingPermissionGate(
                  context: context,

                  // ❌ CANCEL → save cancel → go wellnessHome
                  onCancel: () async {
                    await consentApi.saveDecision(
                      caregiverId: caregiverId,
                      decision: "cancel",
                    );
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, '/WellnessHome');
                  },

                  // ✅ ALLOW → save allow → go wellnessHome
                  onAllow: () async {
                    await consentApi.saveDecision(
                      caregiverId: caregiverId,
                      decision: "allow",
                    );
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, '/WellnessHome');
                  },
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
                Navigator.pushNamed(context, '/WellnessHome');
              }
            },
          ),

          // 2. Task Scheduler - BEIGE
          _FeatureCard(
            title: 'Task Scheduler\n& Routine Builder',
            imagePath: 'assets/h2.png',
            bgColor: const Color(0xFFDFC7A7),
            onTap: () {
              Navigator.pushNamed(context, '/displayUserActivity');
            },
          ),

          // 3. Gamified Knowledge - BEIGE
          _FeatureCard(
            title: 'Gamified\nKnowledge\nBuilder',
            imagePath: 'assets/h3.png',
            bgColor: const Color(0xFFDFC7A7),
            onTap: () {},
          ),

          // 4. Cognitive Profiling - BLUE GRAY
          _FeatureCard(
            title: 'Cognitive\nProfiling &\nProgress',
            imagePath: 'assets/h4.png',
            bgColor: const Color(0xFF6993AB),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// ================= FEATURE CARD WIDGET =================
// ========================================================================

class _FeatureCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final Color bgColor;

  const _FeatureCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
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
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Image.asset(
                        imagePath,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}