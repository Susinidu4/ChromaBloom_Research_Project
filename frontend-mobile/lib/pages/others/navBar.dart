import 'package:flutter/material.dart';

class MainNavBar extends StatelessWidget {
  final int currentIndex; // 0 = Wellness, 1 = Routine, 2 = Home, 3 = Learn, 4 = Progress

  const MainNavBar({
    super.key,
    required this.currentIndex,
  });

  // Colors
  static const Color _barBlue = Color(0xFF386884);
  static const Color _iconBeige = Color(0xFFDFC7A7);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 77,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: _barBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    icon: Icons.spa_rounded,        // lotus / wellness
                    label: "Wellness",
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    icon: Icons.grid_view_rounded,  // routine
                    label: "Routine",
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    icon: Icons.home_rounded,       // home
                    label: "Home",
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    icon: Icons.menu_book_rounded,  // learn
                    label: "Learn",
                  ),
                  _buildNavItem(
                    context: context,
                    index: 4,
                    icon: Icons.show_chart_rounded, // progress
                    label: "Progress",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;

    void handleTap() {
      // Centralized navigation
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/WellnessHome');        // change if needed
          break;
        case 1:
          Navigator.pushNamed(context, '/displayUserActivity');
          break;
        case 2:
          Navigator.pushNamed(context, '/');                // home
          break;
        case 3:
          Navigator.pushNamed(context, '/learn');           // create later
          break;
        case 4:
          Navigator.pushNamed(context, '/progress');        // create later
          break;
      }
    }

    // 🔵 Active item → bubble + label (like your screenshot)
    if (isActive) {
      return GestureDetector(
        onTap: handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -22), // pop out
              child: Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  color: _barBlue, // same blue as bar so it "joins"
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // 🟡 Inactive items → simple beige icon + label
    return GestureDetector(
      onTap: handleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 18),
          Icon(
            icon,
            color: _iconBeige,
            size: 26,
          ),
          const SizedBox(height: 4),
          // Text(
          //   label,
          //   style: const TextStyle(
          //     color: _iconBeige,
          //     fontSize: 11,
          //   ),
          // ),
        ],
      ),
    );
  }
}
