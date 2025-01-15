// lib/widgets/camera_grid.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../utils/size_config.dart';
import 'camera_feed.dart';

class CameraGrid extends StatefulWidget {
  const CameraGrid({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CameraGridState createState() => _CameraGridState();
}

class _CameraGridState extends State<CameraGrid> {
  late List<CameraDescription> cameras;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    cameras = await availableCameras();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.proportionateScreenWidth(2),
            vertical: SizeConfig.proportionateScreenHeight(0.2),
          ),
          child: Text(
            'Live Camera Feed',
            style: TextStyle(
              fontSize: SizeConfig.proportionateScreenWidth(2),
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
              int crossAxisCount = 5;
              double itemHeight = gridHeight / 2;
              double itemWidth = gridWidth / crossAxisCount;

              return GridView.builder(
                physics: NeverScrollableScrollPhysics(),
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
                      child: index < cameras.length
                          ? CameraFeed(camera: cameras[index])
                          : Text(
                              'Camera ${index + 1}',
                              style: TextStyles.heading2,
                              textAlign: TextAlign.center,
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
