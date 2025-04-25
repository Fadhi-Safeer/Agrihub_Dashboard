import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class HealthCardGrid extends StatefulWidget {
  final int n; // Number of cards to display
  final Widget Function(int index) childBuilder; // Card builder callback
  final bool isExpanded; // Whether the grid is expanded
  final VoidCallback onToggleExpand; // Callback to toggle expand state

  const HealthCardGrid({
    super.key,
    required this.n,
    required this.childBuilder,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  State<HealthCardGrid> createState() => _HealthCardGridState();
}

class _HealthCardGridState extends State<HealthCardGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrowVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrowVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrowVisibility() {
    setState(() {
      _canScrollLeft = _scrollController.offset > 0;
      _canScrollRight =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 200).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 200).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.isExpanded) {
          // Expanded mode - show cards in a 2-row grid
          return Column(
            children: [
              // Expand/collapse button at the top
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    widget.isExpanded
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: AppColors.sidebarGradientStart,
                  ),
                  onPressed: widget.onToggleExpand,
                ),
              ),
              Expanded(
                child: _buildExpandedGrid(constraints),
              ),
            ],
          );
        } else {
          // Scrollable mode
          return Stack(
            children: [
              // Scrollable card grid
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Row(
                  children: List.generate(widget.n, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: constraints.maxHeight * 0.8,
                        height: constraints.maxHeight,
                        child: widget.childBuilder(index),
                      ),
                    );
                  }),
                ),
              ),
              // Expand button
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(
                    Icons.fullscreen,
                    color: AppColors.sidebarGradientStart,
                  ),
                  onPressed: widget.onToggleExpand,
                ),
              ),
              // Left Arrow Button
              if (!widget.isExpanded)
                Positioned(
                  left: 8,
                  top: (constraints.maxHeight - 48) / 2,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _canScrollLeft ? 1.0 : 0.0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_left, size: 48),
                      onPressed: _canScrollLeft ? _scrollLeft : null,
                    ),
                  ),
                ),
              // Right Arrow Button
              if (!widget.isExpanded)
                Positioned(
                  right: 8,
                  top: (constraints.maxHeight - 48) / 2,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _canScrollRight ? 1.0 : 0.0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_right, size: 48),
                      onPressed: _canScrollRight ? _scrollRight : null,
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }

  Widget _buildExpandedGrid(BoxConstraints constraints) {
    const int rows = 2; // Number of rows in expanded mode
    int cardsPerRow = (widget.n / rows).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        int startIndex = rowIndex * cardsPerRow;
        int endIndex = (startIndex + cardsPerRow).clamp(0, widget.n);

        if (startIndex >= widget.n) {
          return const SizedBox.shrink();
        }

        return Expanded(
          child: Row(
            children: List.generate(endIndex - startIndex, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.childBuilder(startIndex + index),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
