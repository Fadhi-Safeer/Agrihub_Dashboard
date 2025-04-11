import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigationbar_provider.dart';
import '../theme/text_styles.dart';

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the NavigationBarProvider
    final navigationBarProvider = Provider.of<NavigationBarProvider>(context);

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
                width: 120,
                height: 120,
                fit: BoxFit.contain,
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
          SidebarMenuItem(
            title: 'HOME',
            isSelected: navigationBarProvider.selectedMenu == 'HOME',
            onTap: () {
              navigationBarProvider.updateSelectedMenu('HOME');
              Navigator.pushNamed(context, '/home');
            },
          ),
          SidebarMenuItem(
            title: 'GROWTH',
            isSelected: navigationBarProvider.selectedMenu == 'GROWTH',
            onTap: () {
              navigationBarProvider.updateSelectedMenu('GROWTH');
              Navigator.pushNamed(context, '/growth');
            },
          ),
          SidebarMenuItem(
            title: 'HEALTH',
            isSelected: navigationBarProvider.selectedMenu == 'HEALTH',
            onTap: () {
              navigationBarProvider.updateSelectedMenu('HEALTH');
              Navigator.pushNamed(context, '/health');
            },
          ),
          SidebarMenuItem(
            title: 'DISEASE',
            isSelected: navigationBarProvider.selectedMenu == 'DISEASE',
            onTap: () {
              navigationBarProvider.updateSelectedMenu('DISEASE');
              Navigator.pushNamed(context, '/disease');
            },
          ),
        ],
      ),
    );
  }
}

class SidebarMenuItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap; // Callback for navigation

  const SidebarMenuItem({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap, // Accept the callback
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Colors.pink[600]!, // Darker pinkish purple
                  Colors.pink[400]!, // Lighter pinkish purple
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
          style: isSelected
              ? TextStyles.sidebarMenuItemSelected
              : TextStyles.sidebarMenuItem,
        ),
        onTap: onTap, // Attach the callback here
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
