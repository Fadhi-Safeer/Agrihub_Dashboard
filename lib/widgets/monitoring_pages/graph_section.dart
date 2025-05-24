import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/text_styles.dart';

class GraphsSection extends StatelessWidget {
  final String title;
  final List<Widget> graphs;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color color; // <-- New color parameter

  const GraphsSection({
    Key? key,
    required this.title,
    required this.graphs,
    this.height = 300,
    this.padding = const EdgeInsets.all(16.0),
    this.color = AppColors.cardBackground, // <-- Default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: color, // <-- Use the passed or default color here
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.elevatedCardTitle,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: graphs.length <= 3
                  ? _buildFixedGraphsLayout()
                  : _buildScrollableGraphsLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedGraphsLayout() {
    return Row(
      children: List.generate(graphs.length, (index) {
        final bool isLast = index == graphs.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8.0,
              right: isLast ? 0 : 8.0,
            ),
            child: graphs[index],
          ),
        );
      }),
    );
  }

  Widget _buildScrollableGraphsLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(graphs.length, (index) {
          final bool isLast = index == graphs.length - 1;

          return Container(
            width: 300,
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8.0,
              right: isLast ? 0 : 8.0,
            ),
            child: graphs[index],
          );
        }),
      ),
    );
  }
}
