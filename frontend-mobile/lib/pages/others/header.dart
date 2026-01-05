import 'package:flutter/material.dart';

class MainHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int notificationCount;

  const MainHeader({
    super.key,
    this.title = "Hello !",
    this.subtitle = "Welcome Back.",
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // background outside the header (your page bg can be grey)
      child: Container(
        height: 97,
        decoration: BoxDecoration(
          color: const Color(0xFF386884), // blue header color
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),

            // Right avatar + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFD9D9D9), 
                  child: Icon(Icons.person, color: Color(0xFF386884), size: 30),
                ),
                // Notification badge
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4E0909), // dark red/burgundy
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
