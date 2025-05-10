import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_status_provider.dart';
import 'health_status_bulb.dart';

class TopBar extends StatelessWidget {
  final String title;
  final double bulbSize;
  final TextStyle? textStyle;

  const TopBar({
    super.key,
    required this.title,
    this.bulbSize = 30,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              title,
              style: textStyle,
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Consumer<HealthStatusProvider>(
            builder: (context, healthProvider, _) {
              return HealthStatusLight(
                isHealthy: healthProvider.allFullyNutritional,
                size: bulbSize,
              );
            },
          ),
        ),
      ],
    );
  }
}
