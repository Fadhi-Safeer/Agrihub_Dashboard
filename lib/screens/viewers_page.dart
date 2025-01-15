import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:agrihub_dashboard/theme/text_styles.dart';
import 'package:flutter/material.dart';
import '../widgets/camera_grid.dart';
import '../widgets/graphs/time_series_line_chart.dart';
import '../widgets/graphs/pie_chart_sample2.dart';
import '../widgets/right_panel.dart';
import '../utils/size_config.dart';

class ViewersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // Initialize SizeConfig

    return Scaffold(
      appBar: AppBar(
        title: Text('YOLO Detection Dashboard', style: TextStyles.heading2),
        backgroundColor: AppColors.purpleDark,
      ),
      body: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(
                          SizeConfig.proportionateScreenWidth(4)),
                      child: CameraGrid(), // 10 Camera Widgets
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
                          Expanded(child: PieChartSample2()), // Pie Chart
                          Expanded(
                              child:
                                  Placeholder()), // Placeholder for another chart
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: RightPanel(), // Right Panel
            ),
          ],
        ),
      ),
    );
  }
}
