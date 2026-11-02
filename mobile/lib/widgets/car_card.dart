import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/theme.dart';

/// Thẻ xe dùng ở danh sách / trang chủ: ảnh lớn, nhãn giá hình thẻ chìa khoá màu đồng thau.
class CarCard extends StatelessWidget {
  final VehicleSummary v;
  final VoidCallback? onTap;
  const CarCard({super.key, required this.v, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: ColoredBox(
                    color: AppColors.brandSoft,
                    child: Image.network(
                      v.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.directions_car, size: 48, color: AppColors.brand)),
                    ),
                  ),
                ),
                Positioned(left: 12, top: 12, child: _categoryPill()),
                Positioned(right: 12, top: 12, child: _ratingPill()),
                Positioned(left: 0, bottom: 14, child: _priceTag()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.brand, style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(v.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _meta(Icons.airline_seat_recline_normal, '${v.seats} chỗ'),
                      _meta(Icons.place_outlined, v.city),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      );

  Widget _categoryPill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(999)),
        child: Text(v.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  Widget _ratingPill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 14, color: AppColors.star),
            const SizedBox(width: 3),
            Text(v.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
            Text(' (${v.reviewCount})', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      );

  /// Nhãn giá giống thẻ chìa khoá: dính mép trái ảnh, có lỗ xỏ dây.
  Widget _priceTag() => Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
        decoration: const BoxDecoration(
          color: AppColors.brass,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink.withValues(alpha: 0.6), width: 1.6),
              ),
            ),
            const SizedBox(width: 8),
            Text(vnd(v.pricePerDay), style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
            const Text(' / ngày', style: TextStyle(color: AppColors.ink, fontSize: 12)),
          ],
        ),
      );
}
