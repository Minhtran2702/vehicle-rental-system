import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/theme.dart';

/// Thẻ xe dùng ở danh sách / trang chủ.
class CarCard extends StatelessWidget {
  final VehicleSummary v;
  final VoidCallback? onTap;
  const CarCard({super.key, required this.v, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                v.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.brandSoft, child: const Icon(Icons.directions_car, size: 48, color: AppColors.brand)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${v.brand} • ${v.category}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      Row(children: [
                        const Icon(Icons.star, size: 14, color: AppColors.star),
                        Text(' ${v.rating.toStringAsFixed(1)} (${v.reviewCount})', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text('${v.seats} chỗ • ${v.city}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: vnd(v.pricePerDay), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.brand)),
                    const TextSpan(text: ' / ngày', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
