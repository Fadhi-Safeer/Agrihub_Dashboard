import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigationbar_provider.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';

class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({super.key});

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Sync the provider with the current route on widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithCurrentRoute();
    });
  }

  void _syncWithCurrentRoute() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final navigationBarProvider =
        Provider.of<NavigationBarProvider>(context, listen: false);

    String menuFromRoute = _getMenuFromRouteName(currentRoute);
    if (navigationBarProvider.selectedMenu != menuFromRoute) {
      navigationBarProvider.updateSelectedMenu(menuFromRoute);
    }
  }

  String _getMenuFromRouteName(String? routeName) {
    switch (routeName) {
      case '/home':
        return 'HOME';
      case '/growth':
        return 'GROWTH';
      case '/health':
        return 'HEALTH';
      case '/disease':
        return 'DISEASE';
      default:
        return 'HOME';
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationBarProvider = Provider.of<NavigationBarProvider>(context);

    return Container(
      width: 250,
      color: AppColors.navigationBarBackground,
      child: Column(
        children: [
          // Top section (unchanged)
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

          // Spacer to push content to top
          const Spacer(),

          // Bottom assets - side by side, resizing to fit available space
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate max width for each image (half of available width minus padding)
                final maxWidth = (constraints.maxWidth - 32) / 2;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // First asset
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth,
                        ),
                        child: Image.asset(
                          'assets/apu_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Second asset
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth,
                        ),
                        child: Image.asset(
                          'assets/apcore_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// SidebarMenuItem class remains unchanged
class SidebarMenuItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const SidebarMenuItem({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  const Color(0xFFAD1457),
                  const Color(0xFFE91E63),
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
        onTap: onTap,
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
