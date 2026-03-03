import 'package:flutter/material.dart';
import 'profile_notification_bell.dart';
import 'profile_page.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final ImageProvider avatar;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onBackTap;

  const ProfileHeader({
    super.key,
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
              ProfileNotificationBell(
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