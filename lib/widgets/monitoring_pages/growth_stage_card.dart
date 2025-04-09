import 'package:flutter/material.dart';

class GrowthStageCard extends StatelessWidget {
  final String title;
  final String? image;
  final int number;

  const GrowthStageCard({
    super.key,
    required this.title,
    this.image,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple[50],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // Number at top-right
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ),
            // Main content column (image + title)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (image != null)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
