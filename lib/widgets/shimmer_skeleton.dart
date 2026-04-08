import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// GitHub dark theme colors for shimmer
class ShimmerColors {
  static const Color baseColor = Color(0xFF21262d);
  static const Color highlightColor = Color(0xFF30363d);
  static const Color cardBackground = Color(0xFF161b22);
  static const Color border = Color(0xFF30363d);
}

/// Shimmer skeleton for the user profile card
class UserCardSkeleton extends StatelessWidget {
  const UserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ShimmerColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: ShimmerColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: ShimmerColors.baseColor,
          highlightColor: ShimmerColors.highlightColor,
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ShimmerColors.baseColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username placeholder
                    Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: ShimmerColors.baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Contribution count placeholder
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: ShimmerColors.baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the contribution graph card
class ContributionGraphSkeleton extends StatelessWidget {
  final int weeksToShow;
  final double cellSize;
  final double cellSpacing;

  const ContributionGraphSkeleton({
    super.key,
    this.weeksToShow = 20,
    this.cellSize = 10,
    this.cellSpacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ShimmerColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: ShimmerColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Shimmer.fromColors(
              baseColor: ShimmerColors.baseColor,
              highlightColor: ShimmerColors.highlightColor,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ShimmerColors.baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: ShimmerColors.baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Contribution grid skeleton
            _buildGridSkeleton(),
            const SizedBox(height: 12),
            // Legend skeleton
            _buildLegendSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShimmerColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShimmerColors.border),
      ),
      child: Shimmer.fromColors(
        baseColor: ShimmerColors.baseColor,
        highlightColor: ShimmerColors.highlightColor,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeksToShow, (weekIndex) {
              return Padding(
                padding: EdgeInsets.only(right: cellSpacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(7, (dayIndex) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: cellSpacing),
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendSkeleton() {
    return Shimmer.fromColors(
      baseColor: ShimmerColors.baseColor,
      highlightColor: ShimmerColors.highlightColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 10,
            decoration: BoxDecoration(
              color: ShimmerColors.baseColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: ShimmerColors.baseColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          Container(
            width: 30,
            height: 10,
            decoration: BoxDecoration(
              color: ShimmerColors.baseColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Combined loading skeleton for the entire configured view
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        UserCardSkeleton(),
        SizedBox(height: 16),
        ContributionGraphSkeleton(),
      ],
    );
  }
}