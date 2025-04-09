import 'package:flutter/material.dart';

class ElevatedInfoCard extends StatelessWidget {
  final String title;
  final String? image;
  final int number;
  final Color backgroundColor; // Allow dynamic background color
  final double heightMultiplier; // Allow dynamic height for specific cards

  const ElevatedInfoCard({
    super.key,
    required this.title,
    this.image,
    required this.number,
    this.backgroundColor =
        const Color(0xFFEDE7F6), // Default color (Purple[50])
    this.heightMultiplier = 1.0, // Default height multiplier
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120 * heightMultiplier, // Adjust height based on multiplier
      child: Card(
        color: backgroundColor, // Use dynamic background color
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
      ),
    );
  }
}
