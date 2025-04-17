import 'package:agrihub_dashboard/widgets/graphs/pie_chart.dart';
import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../widgets/monitoring_pages/elevated_card.dart';
import '../widgets/navigation_sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double availableHeight = MediaQuery.of(context).size.height;
    final double squareSize = availableHeight / 4.8;
    final double boxHeight = squareSize * 2;
    final double imageSize = boxHeight * 2 / 5;

    return Scaffold(
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Agricultural Growth & Research with AI Vision',
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  ElevatedCard.square(
                                    title: 'Healthy Plants Detected',
                                    description: '248',
                                    backgroundColor: Colors.green[300]!,
                                    size: squareSize,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedCard.square(
                                    title: 'Plants in Growth Stage 3',
                                    description: '75',
                                    backgroundColor: Colors.teal[200]!,
                                    size: squareSize,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedCard(
                                title: 'About AgriVision AI: ',
                                backgroundColor: Colors.purple[100]!,
                                description:
                                    'AgriVision AI is an intelligent plant monitoring system developed under APCore (Asia Pacific Center of Robotics Engineering), focused on optimizing the growth and health of hydroponic crops, '
                                    'starting with lettuce at the University Agrihub Lab. It leverages deep learning models to perform real-time detection and '
                                    'classification of plant growth stages, health status, and potential diseases using live CCTV feeds. Designed for precision '
                                    'agriculture, the system supports non-soil-based farming by providing continuous visual monitoring, early issue detection, and '
                                    'data-driven insights through a Flutter-based dashboard and Python FastAPI backend. AgriVision AI enables remote access, automated '
                                    'data analysis, and cloud storage, making it a scalable solution for modern hydroponic farming environments.',
                                height: (squareSize * 2) + 6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  ElevatedCard.square(
                                    title: 'Unhealthy/Diseased Plants',
                                    description: '12',
                                    backgroundColor: Colors.red[300]!,
                                    size: squareSize,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedCard.square(
                                      title: 'Model Accuracy',
                                      description: '',
                                      backgroundColor: Colors.deepPurple[300]!,
                                      size: squareSize,
                                      child: CustomPieChart(
                                        values: [
                                          40,
                                          30,
                                          20,
                                          10
                                        ], // percentages or any numeric values
                                        colors: [
                                          Colors.blue,
                                          Colors.green,
                                          Colors.orange,
                                          Colors.red,
                                        ],
                                        titles: [
                                          'Sales',
                                          'Marketing',
                                          'R&D',
                                          'Support'
                                        ],
                                        iconPaths: [
                                          'assets/icons/sales.png',
                                          'assets/icons/marketing.png',
                                          'assets/icons/research.png',
                                          'assets/icons/support.png',
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  ElevatedCard.square(
                                    title: "Today's Detection Count",
                                    description: '1,120',
                                    backgroundColor: Colors.blueGrey[300]!,
                                    size: squareSize,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedCard.square(
                                    title: 'Avg. Detection Time',
                                    description: '0.15 sec',
                                    backgroundColor: Colors.cyan[300]!,
                                    size: squareSize,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedCard(
                                title: 'Audience Growth (Bar Chart)',
                                description: '5000',
                                backgroundColor: Colors.purple[200]!,
                                width: squareSize,
                                height: (squareSize * 2) + 6,
                                child: CustomPieChart(
                                  values: [
                                    40,
                                    30,
                                    20,
                                    10
                                  ], // percentages or any numeric values
                                  colors: [
                                    Colors.blue,
                                    Colors.green,
                                    Colors.orange,
                                    Colors.red,
                                  ],
                                  titles: [
                                    'Sales',
                                    'Marketing',
                                    'R&D',
                                    'Support'
                                  ],
                                  iconPaths: [
                                    'assets/icons/sales.png',
                                    'assets/icons/marketing.png',
                                    'assets/icons/research.png',
                                    'assets/icons/support.png',
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/agrivision');
                                },
                                child: Container(
                                  height: boxHeight,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Live Monitoring',
                                              style:
                                                  TextStyles.elevatedCardTitle,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Click to view real-time plant detection',
                                              style: TextStyles
                                                  .elevatedCardDescription
                                                  .copyWith(
                                                color: AppColors
                                                    .sidebarGradientStart,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 16,
                                        child: Image.asset(
                                          'assets/camera.png',
                                          width: imageSize,
                                          height: imageSize,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          height: boxHeight * 2 / 5,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/plant.png'),
                                              fit: BoxFit.cover,
                                              alignment: Alignment.centerLeft,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
