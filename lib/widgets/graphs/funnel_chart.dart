import 'package:flutter/material.dart';

class CorrelationMatrix extends StatelessWidget {
  final List<String> axisLabels;
  final List<List<double>> matrixData;
  final List<String>? seriesLabels;
  final double cellSize;
  final Color minColor;
  final Color maxColor;
  final Color textColor;
  final TextStyle? axisTextStyle;
  final TextStyle? valueTextStyle;

  CorrelationMatrix({
    Key? key,
    this.axisLabels = const ['A', 'B', 'C', 'D', 'E'],
    this.matrixData = const [
      [1.0, 0.5, 0.3, -0.2, 0.1],
      [0.5, 1.0, 0.7, -0.1, 0.4],
      [0.3, 0.7, 1.0, 0.2, 0.6],
      [-0.2, -0.1, 0.2, 1.0, -0.3],
      [0.1, 0.4, 0.6, -0.3, 1.0],
    ],
    this.seriesLabels,
    this.cellSize = 60,
    this.minColor = Colors.blue,
    this.maxColor = Colors.red,
    this.textColor = Colors.black,
    this.axisTextStyle,
    this.valueTextStyle,
  }) : super(key: key) {
    assert(matrixData.length == axisLabels.length);
    assert(matrixData.every((row) => row.length == axisLabels.length));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final matrixLength = matrixData.length;
        final dynamicCellSize =
            (constraints.maxWidth - 100) / (matrixLength + 2);

        final axisStyle = axisTextStyle ??
            TextStyle(
              color: textColor,
              fontSize: dynamicCellSize * 0.3,
              fontWeight: FontWeight.bold,
            );
        final valueStyle = valueTextStyle ??
            TextStyle(
              color: textColor,
              fontSize: dynamicCellSize * 0.25,
              fontWeight: FontWeight.normal,
            );

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (seriesLabels != null) ...[
                _buildSeriesLegend(seriesLabels!, valueStyle, dynamicCellSize),
                const SizedBox(height: 10),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Y-axis labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: axisLabels
                        .map((label) => SizedBox(
                              height: dynamicCellSize,
                              child: Center(
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Text(label, style: axisStyle),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  // Heatmap
                  Container(
                    width: dynamicCellSize * matrixLength,
                    height: dynamicCellSize * matrixLength,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: matrixLength,
                        childAspectRatio: 1,
                      ),
                      itemCount: matrixLength * matrixLength,
                      itemBuilder: (context, index) {
                        final row = index ~/ matrixLength;
                        final col = index % matrixLength;
                        final value = matrixData[row][col];
                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _getColorForValue(value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              value.toStringAsFixed(1),
                              style: valueStyle.copyWith(
                                color: _getTextColorForValue(value),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Color scale
                  _buildColorScale(valueStyle, dynamicCellSize),
                ],
              ),
              // X-axis labels
              Padding(
                padding: EdgeInsets.only(left: dynamicCellSize),
                child: Row(
                  children: axisLabels
                      .map((label) => SizedBox(
                            width: dynamicCellSize,
                            child: Center(child: Text(label, style: axisStyle)),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeriesLegend(
      List<String> labels, TextStyle style, double dynamicCellSize) {
    return Wrap(
      spacing: 20,
      children: labels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dynamicCellSize * 0.5,
              height: dynamicCellSize * 0.5,
              decoration: BoxDecoration(
                color: _getColorForSeries(index),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 5),
            Text(label, style: style),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildColorScale(TextStyle style, double dynamicCellSize) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        children: [
          Container(
            width: dynamicCellSize * 0.5,
            height: dynamicCellSize * 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [minColor, Colors.white, maxColor],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text('1.0', style: style),
          Text('0', style: style),
          Text('-1.0', style: style),
        ],
      ),
    );
  }

  Color _getColorForValue(double value) {
    if (value >= 0) {
      return Color.lerp(Colors.white, maxColor, value)!;
    } else {
      return Color.lerp(Colors.white, minColor, -value)!;
    }
  }

  Color _getTextColorForValue(double value) {
    final luminance = _getColorForValue(value).computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Color _getColorForSeries(int index) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
    return colors[index % colors.length];
  }
}
