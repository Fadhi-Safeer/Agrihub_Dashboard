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

  Widget _buildEdgeGradient(BuildContext context, Alignment alignment) {
    return SizedBox(
      width: 60, // Width of the gradient area
      child: Align(
        alignment: alignment,
        child: Container(
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                alignment == Alignment.centerLeft
                    ? AppColors.sidebarGradientStart.withOpacity(0.1)
                    : AppColors.sidebarGradientEnd.withOpacity(0.1),
              ],
              stops: const [0.0, 1.0],
              begin: alignment == Alignment.centerLeft
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              end: alignment,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalArrowButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback? onPressed,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isActive ? 1.0 : 0.3,
        child: IconButton(
          icon: Icon(
            icon,
            size: 28,
            color: AppColors.sidebarGradientEnd,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.7),
            shape: const CircleBorder(),
            elevation: 2,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.isExpanded) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    widget.isExpanded
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: AppColors.sidebarGradientEnd,
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
          return Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // Left gradient edge
                    _buildEdgeGradient(context, Alignment.centerLeft),
                    // Content cards
                    ...List.generate(widget.n, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: constraints.maxHeight * 0.8,
                          height: constraints.maxHeight,
                          child: widget.childBuilder(index),
                        ),
                      );
                    }),
                    // Right gradient edge
                    _buildEdgeGradient(context, Alignment.centerRight),
                  ],
                ),
              ),
              // Expand button
              Positioned(
                right: 16,
                top: 16,
                child: IconButton(
                  icon: Icon(
                    Icons.fullscreen,
                    color: AppColors.sidebarGradientEnd,
                  ),
                  onPressed: widget.onToggleExpand,
                ),
              ),
              // Left arrow button
              Positioned(
                left: 8,
                top: (constraints.maxHeight - 48) / 2,
                child: _buildMinimalArrowButton(
                  icon: Icons.arrow_left,
                  isActive: _canScrollLeft,
                  onPressed: _canScrollLeft ? _scrollLeft : null,
                  alignment: Alignment.centerLeft,
                ),
              ),
              // Right arrow button
              Positioned(
                right: 8,
                top: (constraints.maxHeight - 48) / 2,
                child: _buildMinimalArrowButton(
                  icon: Icons.arrow_right,
                  isActive: _canScrollRight,
                  onPressed: _canScrollRight ? _scrollRight : null,
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildExpandedGrid(BoxConstraints constraints) {
    const int rows = 2;
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
