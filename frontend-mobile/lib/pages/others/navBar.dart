import 'package:flutter/material.dart';

class MainNavBar extends StatelessWidget {
  final int currentIndex;

  const MainNavBar({
    super.key,
    required this.currentIndex,
  });

  // 🎨 ChromaBloom colors
  static const Color barBlue = Color(0xFF386884);
  static const Color iconBeige = Color(0xFFDFC7A7);
  static const Color cream = Color(0xFFF8F2E8);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: barBlue,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 10),
                color: Color(0x33000000),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.spa_rounded,
                label: "Wellness",
                route: '/WellnessHome',
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.calendar_month_rounded,
                label: "Routine",
                route: '/displayUserActivity',
              ),
              _NavItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.home_rounded,
                label: "Home",
                route: '/',
              ),
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.menu_book_rounded,
                label: "Learn",
                route: '/skillSelection',
              ),
              _NavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.show_chart_rounded,
                label: "Progress",
                route: '/progress_prediction',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.route,
  });

  static const Color barBlue = Color(0xFF386884);
  static const Color iconBeige = Color(0xFFDFC7A7);
  static const Color cream = Color(0xFFF8F2E8);

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;

    void navigate() {
      if (isActive) return;
      Navigator.pushReplacementNamed(context, route);
    }

    return InkWell(
      onTap: navigate,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? cream : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 26 : 24,
              color: isActive ? barBlue : iconBeige,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: barBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
