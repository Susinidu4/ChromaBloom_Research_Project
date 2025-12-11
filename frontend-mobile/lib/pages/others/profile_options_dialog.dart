import 'package:flutter/material.dart';

Future<void> showProfileOptionsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35), // dim background
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- TOP DECOR ----------
              Container(
                width: 55,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF235870),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(height: 18),

              // ---------- TITLE ----------
              const Text(
                'Profile Options',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how you want to continue',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13.5,
                ),
              ),

              const SizedBox(height: 20),

              // ---------- CAREGIVER SECTION ----------
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Caregiver',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              _OptionTile(
                icon: Icons.login,
                iconBg: const Color(0xFFE0F0FF),
                iconColor: const Color(0xFF1E4E8C),
                title: 'Caregiver Login',
                subtitle: 'Already have an account? Sign in',
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.pushNamed(context, '/caregiver_login');
                },
              ),
              const SizedBox(height: 10),
              _OptionTile(
                icon: Icons.family_restroom_outlined,
                iconBg: const Color(0xFFFAE4C8),
                iconColor: const Color(0xFFBF6C1B),
                title: 'Caregiver Signup',
                subtitle: 'Create a new caregiver account',
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.pushNamed(context, '/caregiver_signup');
                },
              ),

              const SizedBox(height: 18),

              // ---------- THERAPIST SECTION ----------
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Therapist',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              _OptionTile(
                icon: Icons.login_outlined,
                iconBg: const Color(0xFFE3F7EF),
                iconColor: const Color(0xFF147453),
                title: 'Therapist Login',
                subtitle: 'Sign in to your therapist account',
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.pushNamed(context, '/therapistLogin');
                },
              ),
              const SizedBox(height: 10),
              _OptionTile(
                icon: Icons.medical_information_outlined,
                iconBg: const Color(0xFFE0F0F8),
                iconColor: const Color(0xFF196B85),
                title: 'Therapist Register',
                subtitle: 'Register as a new therapist',
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.pushNamed(context, '/therapistRegister');
                },
              ),

              const SizedBox(height: 20),

              // ---------- CLOSE BUTTON ----------
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF235870),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// =======================================================
// REUSABLE CUSTOM TILE
// =======================================================
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON BOX
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.5,
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
