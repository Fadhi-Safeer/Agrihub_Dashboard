// lib/widgets/right_panel.dart
import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:agrihub_dashboard/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/yolo_provider.dart';

class RightPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rightPanel,
      child: Consumer<YOLOProvider>(
        builder: (context, yoloProvider, child) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.rightPanel,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: yoloProvider.boundingBoxes.isEmpty
                        ? Text(
                            'No Detection Data',
                            style: TextStyles.rightPanelHeadingText,
                          )
                        : ListView.builder(
                            itemCount: yoloProvider.boundingBoxes.length,
                            itemBuilder: (context, index) {
                              final box = yoloProvider.boundingBoxes[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Box ${index + 1}: (${box['x1']}, ${box['y1']}) - (${box['x2']}, ${box['y2']})',
                                  style: TextStyles.rightPanelHeadingText,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
