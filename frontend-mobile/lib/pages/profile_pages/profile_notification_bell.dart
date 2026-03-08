import 'package:flutter/material.dart';
import 'profile_page.dart';

class ProfileNotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const ProfileNotificationBell({
    super.key,
    required this.count,
    required this.onTap,
  });

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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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