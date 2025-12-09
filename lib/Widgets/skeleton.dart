import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const Skeleton({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class LanguageCardSkeleton extends StatelessWidget {
  const LanguageCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Skeleton(height: 20, width: 100),
                const SizedBox(height: 8),
                const Skeleton(height: 14, width: 60),
              ],
            ),
          ),
          const Skeleton(height: 40, width: 40, borderRadius: 20),
        ],
      ),
    );
  }
}