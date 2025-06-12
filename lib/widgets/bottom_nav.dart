import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF3A7BD5),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            _buildNavItem(
              icon: Icons.dashboard_rounded,
              label: 'Home',
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.map_rounded,
              label: 'Map',
              isSelected: currentIndex == 1,
            ),
            _buildPostItem(isSelected: currentIndex == 2),
            _buildNavItem(
              icon: Icons.inbox_rounded,
              label: 'Inbox',
              isSelected: currentIndex == 3,
            ),
            _buildNavItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              isSelected: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon, size: 26),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildPostItem({required bool isSelected}) {
    return BottomNavigationBarItem(
      icon: Container(
        height: 48,
        width: 48,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3A7BD5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A7BD5).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      label: '',
    );
  }
}