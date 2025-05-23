import 'package:flutter/material.dart';

class HealthStatusLight extends StatelessWidget {
  final bool isHealthy;
  final double size;

  const HealthStatusLight({
    super.key,
    required this.isHealthy,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isHealthy ? Colors.green : Colors.red,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/healthy_detector.png',
              width: size,
              height: size,
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/healthy_detector.png',
              width: size,
              height: size,
            ),
          ),
        ],
      ),
    );
  }
}
