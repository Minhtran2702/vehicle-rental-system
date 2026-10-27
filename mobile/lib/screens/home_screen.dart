import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../mocks/mock_data.dart';
import '../widgets/car_card.dart';

/// Trang chủ mẫu để thấy khung chạy được. Sẽ làm lại khi làm việc "search".
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Image.asset('assets/images/logo.png', height: 36)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.brand, AppColors.brandLight]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thuê xe dễ dàng,\nđi ngay hôm nay', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Hàng trăm xe từ chủ xe uy tín, giá minh bạch.', style: TextStyle(color: Color(0xFFD9E5F2))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Xe nổi bật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          for (final v in mockVehicles) ...[
            CarCard(v: v),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
