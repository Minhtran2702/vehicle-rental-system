import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../core/theme.dart';

/// Tab "Tài khoản": nếu chưa đăng nhập thì mời đăng nhập; nếu đã đăng nhập thì hiện thông tin + đăng xuất.
/// Sẽ làm lại thành trang hồ sơ đầy đủ ở việc "profile".
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: Center(
        child: u == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo_icon.png', height: 80),
                  const SizedBox(height: 16),
                  const Text('Đăng nhập để đặt xe và đăng xe cho thuê'),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Đăng nhập')),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: AppColors.brandSoft, child: Icon(Icons.person, size: 44, color: AppColors.brand)),
                  const SizedBox(height: 12),
                  Text(u.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  Text(u.email, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(children: [
                      if (u.isAdmin) ...[
                        ElevatedButton(onPressed: () => context.go('/admin'), child: const Text('Vào trang quản trị')),
                        const SizedBox(height: 10),
                      ],
                      OutlinedButton(
                        onPressed: () async { await auth.logout(); if (context.mounted) context.go('/'); },
                        child: const Text('Đăng xuất'),
                      ),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }
}
