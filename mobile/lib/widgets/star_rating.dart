import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Hiển thị sao. Truyền onChanged để cho phép bấm chọn.
class StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;
  const StarRating({super.key, required this.value, this.onChanged, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final n = i + 1;
        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(n),
          child: Icon(n <= value ? Icons.star : Icons.star_border, size: size, color: n <= value ? AppColors.star : Colors.grey),
        );
      }),
    );
  }
}
