import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:agrihub_dashboard/theme/text_styles.dart';
import 'package:agrihub_dashboard/widgets/graphs/combination_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/agrivision_page/camera_grid.dart';
import '../widgets/graphs/time_series_line_chart.dart';
import '../widgets/graphs/pie_chart_sample2.dart';
import '../widgets/agrivision_page/right_panel.dart';
import '../utils/size_config.dart';
import '../utils/available_cameras.dart';

class AgrivisionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List<String> availableCameras = getAvailableCameras();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.topBar,
        centerTitle: true,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set icon (back button) color
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/agrivision_icon.png',
              height: 40,
            ),
            const SizedBox(width: 12),
            Text(
              'Agricultural Growth & Research with AI Vision',
              style: TextStyles.mainHeading.copyWith(color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the homepage and remove current screen from stack
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(
                          SizeConfig.proportionateScreenWidth(4)),
                      child: CameraGrid(availableCameras: availableCameras),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(
                          SizeConfig.proportionateScreenWidth(4)),
                      child: Row(
                        children: [
                          Expanded(child: TimeSeriesLineChart()),
                          Expanded(child: PieChartSample2()),
                          Expanded(
                              child: CombinationChart(
                            data: [],
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: RightPanel(),
            ),
          ],
        ),
      ),
    );
  }
}
