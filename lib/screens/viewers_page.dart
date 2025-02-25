import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:agrihub_dashboard/theme/text_styles.dart';
import 'package:agrihub_dashboard/widgets/graphs/bar_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/camera_grid.dart';
import '../widgets/graphs/time_series_line_chart.dart';
import '../widgets/graphs/pie_chart_sample2.dart';
import '../widgets/right_panel.dart';
import '../utils/size_config.dart';
import '../utils/available_cameras.dart'; // Import the available cameras file

class ViewersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // Initialize SizeConfig

    // Get the list of available cameras
    List<int> availableCameras = getAvailableCameras();

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Crop Monitoring & Analysis Dashboard',
            style: TextStyles.mainHeading),
        centerTitle: true,
        backgroundColor: AppColors.topBar,
      ),
      body: Container(
        color: AppColors.background,
        child: Row(
          children: [
            Expanded(
              flex: 5, // Increased flex value for the main content area
              child: Column(
                children: [
                  Expanded(
                    flex: 2, // 2 parts out of 3 for the camera grid
                    child: Padding(
                      padding: EdgeInsets.all(
                          SizeConfig.proportionateScreenWidth(
                              4)), // Padding around the CameraGrid
                      child: CameraGrid(
                          availableCameras:
                              availableCameras), // Camera Widgets or placeholders
                    ),
                  ),
                  Expanded(
                    flex: 1, // 1 part out of 3 for the graphs
                    child: Padding(
                      padding: EdgeInsets.all(
                          SizeConfig.proportionateScreenWidth(
                              4)), // Padding around the graphs
                      child: Row(
                        children: [
                          Expanded(child: TimeSeriesLineChart()),
                          Expanded(child: PieChartSample2()), // Pie Chart
                          Expanded(child: GroupedBarChart()), // Bar Chart
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2, // Reduced flex value for the right panel
              child: RightPanel(), // Right Panel
            ),
          ],
        ),
      ),
    );
  }
}
