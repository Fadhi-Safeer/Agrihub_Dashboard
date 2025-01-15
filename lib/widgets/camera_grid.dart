// lib/widgets/camera_grid.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../utils/size_config.dart';

class CameraGrid extends StatelessWidget {
  final List<bool> cameraConnected =
      List.generate(10, (index) => true); // Simulate camera connectivity status

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // Initialize SizeConfig

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.proportionateScreenWidth(2),
            vertical: SizeConfig.proportionateScreenHeight(
                0.2), // Reduced padding top and bottom
          ),
          child: Text(
            'Live Camera Feed',
            style: TextStyle(
              fontSize: SizeConfig.proportionateScreenWidth(
                  2), // Smaller font size for heading
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double gridHeight = constraints.maxHeight;
              double gridWidth = constraints.maxWidth;
              int crossAxisCount = 5; // Number of columns
              double itemHeight =
                  gridHeight / 2; // Two rows, so divide height by 2
              double itemWidth = gridWidth / crossAxisCount;

              return GridView.builder(
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: 10,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: SizeConfig.proportionateScreenWidth(2),
                  mainAxisSpacing: SizeConfig.proportionateScreenWidth(2),
                  childAspectRatio: itemWidth / itemHeight,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    color: AppColors.purpleLight,
                    child: Center(
                      child: cameraConnected[index]
                          ? Text(
                              'Camera ${index + 1}',
                              style:
                                  TextStyles.heading2, // Use defined text style
                              textAlign: TextAlign.center,
                            )
                          : Image.asset(
                              'assets/images/camera_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
