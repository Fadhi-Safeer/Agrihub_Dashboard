import 'package:flutter/material.dart';

class HealthStatusLight extends StatelessWidget {
  final bool isHealthy;
  final double size;

  const HealthStatusLight({
    super.key,
    required this.isHealthy,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.lightbulb,
            size: size,
            color: isHealthy ? Colors.green : Colors.red,
          ),
          Icon(
            Icons.lightbulb_outline,
            size: size,
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
