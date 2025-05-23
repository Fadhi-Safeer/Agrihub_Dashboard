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

class _NavigationSidebarState extends State<NavigationSidebar> with RouteAware {
  late final RouteObserver<PageRoute> _routeObserver;

  @override
  void initState() {
    super.initState();
    _routeObserver = RouteObserver<PageRoute>();
    // Delay the initial sync to avoid build-phase conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithCurrentRoute();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithCurrentRoute();
    });
  }

  @override
  void didPopNext() {
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
      // Schedule the update for the next frame
      Future.microtask(() {
        navigationBarProvider.updateSelectedMenu(menuFromRoute);
      });
    }
  }

  String _getMenuFromRouteName(String? routeName) {
    if (routeName == null) return 'HOME';
    switch (routeName.toLowerCase()) {
      case '/home':
      case '/':
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
            style: TextStyles.mainHeading.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 20),
          SidebarMenuItem(
            title: 'HOME',
            isSelected: navigationBarProvider.selectedMenu == 'HOME',
            onTap: () {
              if (navigationBarProvider.selectedMenu != 'HOME') {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          SidebarMenuItem(
            title: 'GROWTH',
            isSelected: navigationBarProvider.selectedMenu == 'GROWTH',
            onTap: () {
              if (navigationBarProvider.selectedMenu != 'GROWTH') {
                Navigator.pushReplacementNamed(context, '/growth');
              }
            },
          ),
          SidebarMenuItem(
            title: 'HEALTH',
            isSelected: navigationBarProvider.selectedMenu == 'HEALTH',
            onTap: () {
              if (navigationBarProvider.selectedMenu != 'HEALTH') {
                Navigator.pushReplacementNamed(context, '/health');
              }
            },
          ),
          SidebarMenuItem(
            title: 'DISEASE',
            isSelected: navigationBarProvider.selectedMenu == 'DISEASE',
            onTap: () {
              if (navigationBarProvider.selectedMenu != 'DISEASE') {
                Navigator.pushReplacementNamed(context, '/disease');
              }
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = (constraints.maxWidth - 32) / 2;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Image.asset(
                          'assets/apu_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxWidth),
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
            ? const LinearGradient(
                colors: [
                  Color(0xFFAD1457),
                  Color(0xFFE91E63),
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
