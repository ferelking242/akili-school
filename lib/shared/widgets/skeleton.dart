import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const _shimmerBase  = Color(0xFFEDE8E0);
const _shimmerHigh  = Color(0xFFF7F3EC);

/// Wraps any child in a shimmer effect for loading states.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:  _shimmerBase,
      highlightColor: _shimmerHigh,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A full skeleton card mimicking the stat cards on dashboards.
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHigh,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _shimmerBase,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Container(width: 60, height: 10, color: _shimmerBase,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(width: 40, height: 18, color: _shimmerBase,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a list row (e.g. schedule or grade entry).
class SkeletonListRow extends StatelessWidget {
  const SkeletonListRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _shimmerBase,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, color: _shimmerBase,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(width: 120, height: 10, color: _shimmerBase,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 40, height: 24, color: _shimmerBase,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8))),
          ],
        ),
      ),
    );
  }
}

/// A simple number skeleton — only the number part shimmers.
/// Use when you have static text + dynamic number:
/// e.g. "Il vous reste " + [SkeletonNumber] + " jours"
class SkeletonNumber extends StatelessWidget {
  final String? value;
  final TextStyle? style;
  const SkeletonNumber({super.key, this.value, this.style});

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return Text(value!, style: style);
    }
    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHigh,
      child: Container(
        width: 28,
        height: 14,
        decoration: BoxDecoration(
          color: _shimmerBase,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
