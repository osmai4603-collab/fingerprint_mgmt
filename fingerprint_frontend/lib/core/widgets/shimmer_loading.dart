import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  static Color _getBaseColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Theme.of(context).colorScheme.surfaceContainer
        : const Color(0xFFE0E0E0);
  }

  static Color _getHighlightColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _getBaseColor(context),
      highlightColor: _getHighlightColor(context),
      child: child,
    );
  }

  static Widget _box({
    double? width,
    double? height,
    double borderRadius = 6,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static List<int> _columnFlexes(int columns) {
    return switch (columns) {
      3 => [1, 2, 1],
      4 => [1, 2, 1, 1],
      5 => [1, 3, 2, 2, 2],
      6 => [1, 2, 2, 2, 2, 1],
      7 => [1, 2, 3, 2, 1, 1, 2],
      8 => [1, 2, 2, 2, 2, 1, 2, 2],
      9 => [1, 3, 2, 2, 2, 2, 2, 2, 2],
      10 => [1, 3, 2, 2, 2, 2, 2, 2, 2, 2],
      _ => List.generate(columns, (_) => 2),
    };
  }

  static Widget _shimmer({required Widget child}) {
    return Builder(
      builder: (context) {
        return Shimmer.fromColors(
          baseColor: _getBaseColor(context),
          highlightColor: _getHighlightColor(context),
          child: child,
        );
      },
    );
  }

  static Widget _row(double height, List<int> flexes, {double spacing = 8}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: flexes
            .map(
              (f) => Expanded(
                flex: f,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: spacing),
                  child: _box(height: height, borderRadius: 4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static Widget table({int rows = 50, int columns = 5}) {
    final flexes = _columnFlexes(columns);
    return _shimmer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(height: 38),
            const SizedBox(height: 8),
            ...List.generate(rows, (i) => _row(25, flexes)),
          ],
        ),
      ),
    );
  }

  static Widget dashboard() {
    return _shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 200, height: 28),
            const SizedBox(height: 8),
            _box(width: 300, height: 16),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: i < 2 ? 12 : 0),
                    child: _box(height: 80, borderRadius: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: i < 2 ? 12 : 0),
                    child: _box(height: 110, borderRadius: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _box(height: 80, borderRadius: 12),
              ),
            ),
            const SizedBox(height: 16),
            _box(width: 150, height: 20),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    _box(width: 36, height: 36, borderRadius: 18),
                    const SizedBox(width: 12),
                    Expanded(child: _box(height: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget list({int items = 5}) {
    return _shimmer(
      child: Column(
        children: List.generate(
          items,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              children: [
                _box(width: 32, height: 32, borderRadius: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(height: 14),
                      const SizedBox(height: 6),
                      _box(width: 120, height: 12),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                _box(width: 24, height: 24, borderRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget box({
    double? width,
    double height = 56,
    double borderRadius = 8,
  }) {
    return _shimmer(
      child: _box(width: width, height: height, borderRadius: borderRadius),
    );
  }

  static Widget cardGrid() {
    return _shimmer(
      child: Column(
        children: [
          Row(
            children: List.generate(
              2,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: i == 0 ? 8 : 0),
                  child: _box(height: 80, borderRadius: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              2,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: i == 0 ? 8 : 0),
                  child: _box(height: 80, borderRadius: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget logRows({int rows = 4}) {
    return _shimmer(
      child: Column(
        children: List.generate(
          rows + 1,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                _box(width: 40, height: i == 0 ? 18 : 14),
                const SizedBox(width: 16),
                _box(width: 100, height: i == 0 ? 18 : 14),
                const SizedBox(width: 16),
                _box(width: 100, height: i == 0 ? 18 : 14),
                const SizedBox(width: 16),
                _box(width: 60, height: i == 0 ? 18 : 14),
                const SizedBox(width: 16),
                _box(width: 40, height: i == 0 ? 18 : 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
