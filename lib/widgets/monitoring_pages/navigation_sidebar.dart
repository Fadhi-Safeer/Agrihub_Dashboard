import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.purple[900],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
            child: ClipOval(
              child: Image.asset(
                'assets/agrivision_icon.png',
                width: 120, // Adjust the width
                height: 120, // Adjust the height
                fit: BoxFit.contain, // Ensures the image fills the circle
              ),
            ),
          ),
          Text(
            'AGRIVISION',
            style: TextStyles.mainHeading.copyWith(
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 20),
          const SidebarMenuItem(title: 'HOME', isSelected: true),
          const SidebarMenuItem(title: 'GROWTH'),
          const SidebarMenuItem(title: 'HEALTH'),
          const SidebarMenuItem(title: 'DISEASE'),
        ],
      ),
    );
  }
}

class SidebarMenuItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const SidebarMenuItem({
    super.key,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Colors.purple[600]!,
                  Colors.purple[400]!,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        color: isSelected ? null : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          _getIconForTitle(title),
          color: isSelected ? Colors.white : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'HOME':
        return Icons.home;
      case 'GROWTH':
        return Icons.trending_up;
      case 'HEALTH':
        return Icons.health_and_safety;
      case 'DISEASE':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}
