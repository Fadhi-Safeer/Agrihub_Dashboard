import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGRIVISION',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: const ColorScheme.light(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                // Growth cards grid (fixed height, non-scrollable)
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.6, // 60% of screen height
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height *
                              0.65), // Adjusting aspect ratio
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      children: const [
                        GrowthStageCard(
                            title: 'Early Growth',
                            image: 'assets/early_growth_icon.png',
                            number: 120),
                        GrowthStageCard(
                            title: 'Leafy Growth',
                            image: 'assets/leafy_growth_icon.png',
                            number: 90),
                        GrowthStageCard(
                            title: 'Head Formation',
                            image: 'assets/head_formation_icon.png',
                            number: 75),
                        GrowthStageCard(
                            title: 'Harvest Stage',
                            image: 'assets/harvest_stage_icon.png',
                            number: 60),
                      ],
                    ),
                  ),
                ),

                // Fixed graph section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.grey[100],
                      child: Center(
                        child: Text(
                          'Graphs Section',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.purple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: CircleAvatar(
              radius: 50,
              child: ClipOval(
                // Ensure the image is circular
                child: Image.asset(
                  'assets/agrivision_icon.png',
                  width: 50, // Set the width of the image to match the radius
                  height: 50, // Set the height of the image to match the radius
                  fit: BoxFit
                      .cover, // Makes sure the image fits well inside the circle
                ),
              ),
            ),
          ),
          Text(
            'AGRIVISION',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
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

class GrowthStageCard extends StatelessWidget {
  final String title;
  final String? image;
  final int number;

  const GrowthStageCard({
    super.key,
    required this.title,
    this.image,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple[50],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // Number at top-right
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ),
            // Main content column (image + title)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (image != null)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
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
