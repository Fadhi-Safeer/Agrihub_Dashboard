import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:agrihub_dashboard/theme/text_styles.dart';
import 'package:agrihub_dashboard/widgets/graphs/bar_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/viewers_page/camera_grid.dart';
import '../widgets/graphs/time_series_line_chart.dart';
import '../widgets/graphs/pie_chart_sample2.dart';
import '../widgets/viewers_page/right_panel.dart';
import '../utils/size_config.dart';
import '../utils/available_cameras.dart';

class AgrivisionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List<String> availableCameras = getAvailableCameras();

    return Scaffold(
      appBar: AppBar(
        title: Text('Agricultural Growth & Research with AI Vision',
            style: TextStyles.mainHeading),
        centerTitle: true,
        backgroundColor: AppColors.topBar,
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
                          Expanded(child: GroupedBarChart()),
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
