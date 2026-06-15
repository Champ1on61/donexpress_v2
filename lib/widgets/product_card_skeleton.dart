// lib/widgets/product_card_skeleton.dart
import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: const SkeletonLoader(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(width: 60, height: 20),
                SizedBox(height: 8),
                SkeletonLoader(width: double.infinity, height: 14),
                SizedBox(height: 4),
                SkeletonLoader(width: 100, height: 14),
                SizedBox(height: 12),
                SkeletonLoader(width: double.infinity, height: 36, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}