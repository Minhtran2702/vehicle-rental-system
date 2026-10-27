import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Màn hình tạm cho tab chưa làm. Thay bằng màn hình thật trong router.dart khi làm xong chức năng.
class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_icon.png', height: 72),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Text('Đang phát triển', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
