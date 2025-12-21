import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/session_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color headerBlue = Color(0xFF3E6D86);
  static const Color pageBg = Color(0xFFF6EDED);

  static const Color textGold = Color(0xFFC6A36C);
  static const Color cardBg = Color(0xFFE8DDCE);
  static const Color cardIconBg = Color(0xFFD7C3AA);

  static const Color signOutBg = Color(0xFFE9DECF);

  ImageProvider _resolveAvatar(Map<String, dynamic>? caregiver) {
    // Try multiple common keys your backend might return
    final raw = (caregiver?['profilePicUrl'] ??
            caregiver?['profile_pic_url'] ??
            caregiver?['profilePic'] ??
            caregiver?['profile_pic'] ??
            caregiver?['avatar'] ??
            caregiver?['image'])
        ?.toString();

    // Fallback asset
    const fallback = AssetImage("assets/images/profile_avatar.png");

    if (raw == null || raw.trim().isEmpty) return fallback;

    final v = raw.trim();

    // 1) Network URL
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }

    // 2) Data URI base64: data:image/png;base64,....
    if (v.startsWith('data:image')) {
      final commaIndex = v.indexOf(',');
      if (commaIndex != -1) {
        final b64 = v.substring(commaIndex + 1);
        try {
          final bytes = base64Decode(b64);
          return MemoryImage(bytes);
        } catch (_) {
          return fallback;
        }
      }
    }

    // 3) Plain base64 (no prefix)
    try {
      final bytes = base64Decode(v);
      return MemoryImage(bytes);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final caregiver = session.caregiver;

    final fullName = (caregiver?['fullName'] ??
            caregiver?['full_name'] ??
            caregiver?['name'] ??
            'Caregiver')
        .toString();

    final email = (caregiver?['email'] ?? 'unknown@email.com').toString();

    final avatarProvider = _resolveAvatar(caregiver);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderSection(
              name: fullName,
              email: email,
              avatar: avatarProvider,
              notificationCount: 5,
              onNotificationTap: () {},
              onBackTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      "YOUR PROFILE",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "GENERAL",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: "Profile Settings",
                      subtitle: "Update and Modify your details",
                      onTap: () =>
                          Navigator.pushNamed(context, '/profile_settings'),
                    ),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.child_care_outlined,
                      title: "Child Details",
                      subtitle: "Update and Modify your child details",
                      onTap: () => Navigator.pushNamed(context, '/child_details'),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        color: textGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sign out
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: signOutBg,
                          foregroundColor: const Color(0xFF9B845F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: Color(0xFFBFA47A),
                              width: 1.2,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await context.read<SessionProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/welcome_screen',
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= HEADER =================

class _HeaderSection extends StatelessWidget {
  final String name;
  final String email;
  final ImageProvider avatar;

  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onBackTap;

  const _HeaderSection({
    required this.name,
    required this.email,
    required this.avatar,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ProfilePage.headerBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onBackTap,
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              _NotificationBell(
                count: notificationCount,
                onTap: onNotificationTap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.88),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFE9E9E9),
                backgroundImage: avatar,
                onBackgroundImageError: (_, __) {},
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= NOTIFICATION =================

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 26,
            ),
          ),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8C1D1D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ProfilePage.headerBlue,
                    width: 2,
                  ),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================= MENU ITEM =================

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: ProfilePage.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ProfilePage.cardIconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF8F6F44)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFB88F55),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFB88F55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFB88F55),
            ),
          ],
        ),
      ),
    );
  }
}
