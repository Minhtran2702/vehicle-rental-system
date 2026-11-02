import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../mocks/mock_data.dart';
import '../widgets/car_card.dart';

/// Trang chủ: lời chào, ô tìm xe, lọc theo loại xe và danh sách xe nổi bật.
/// Sẽ làm lại khi làm việc "search".
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _all = 'Tất cả';
  String _category = _all;

  @override
  Widget build(BuildContext context) {
    final categories = [_all, ...{for (final v in mockVehicles) v.category}];
    final vehicles = _category == _all ? mockVehicles : mockVehicles.where((v) => v.category == _category).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_icon.png', height: 28),
            const SizedBox(width: 8),
            const Text('Car Rental', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.ink)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _hero(context),
          const SizedBox(height: 22),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in categories) _categoryChip(c),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _category == _all ? 'Xe nổi bật' : 'Xe $_category',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 14),
          for (final v in vehicles) ...[
            CarCard(v: v),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }


  /// Nút lọc theo loại xe: đang chọn thì nền navy chữ trắng.
  Widget _categoryChip(String c) {
    final on = _category == c;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: Material(
          color: on ? AppColors.brand : Colors.white,
          shape: StadiumBorder(side: BorderSide(color: on ? AppColors.brand : AppColors.line)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => setState(() => _category = c),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                c,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.text),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          // Logo mờ ở góc: nhắc lại thẻ chìa khoá của thương hiệu
          Positioned(
            right: -36,
            top: -6,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white.withValues(alpha: 0.09), BlendMode.srcIn),
              child: Image.asset('assets/images/logo_icon.png', width: 210),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thuê xe tự lái,\nnhận chìa là đi',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                ),
                const SizedBox(height: 8),
                const Text('Chọn xe, chọn ngày, nhận chìa.', style: TextStyle(color: Color(0xFFB9CBE0))),
                const SizedBox(height: 20),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.go('/vehicles'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.muted),
                          SizedBox(width: 10),
                          Text('Bạn muốn thuê xe ở đâu?', style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
