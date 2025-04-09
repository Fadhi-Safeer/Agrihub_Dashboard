import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/yolo_provider.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

class RightPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rightPanel,
      padding: const EdgeInsets.all(16),
      child: Consumer<YOLOProvider>(
        builder: (context, yoloProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Classification Results",
                style: TextStyles.rightPanelHeadingText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: yoloProvider.classificationResults.isEmpty
                    ? Center(
                        child: Text(
                          'No Classification Data',
                          style: TextStyles.rightPanelHeadingText.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: yoloProvider.classificationResults.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry =
                              yoloProvider.classificationResults[index];
                          final classification = entry["classification"];
                          final encodedImage = entry["cropped_image"];

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.rightPanel.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (encodedImage != null)
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 120,
                                        maxHeight: 120,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(encodedImage),
                                          fit: BoxFit
                                              .contain, // Changed to contain
                                        ),
                                      ),
                                    ),
                                  if (encodedImage != null)
                                    const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(
                                            "Disease",
                                            classification["disease"]
                                                .toString()),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Growth",
                                            classification["growth"]
                                                .toString()),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                            "Health",
                                            classification["health"]
                                                .toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Text(
      '$label: $value', // Combines label and value with colon separator
      style: TextStyles.rightPanelHeadingText.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 19,
      ),
    );
  }
}
