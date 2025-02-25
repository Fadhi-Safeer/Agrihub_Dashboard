// lib/widgets/right_panel.dart
import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../theme/text_styles.dart';

class RightPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rightPanel,
      child: Column(
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
                child: Text(
                  'Right Panel Content',
                  style: TextStyles.rightPanelHeadingText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
