import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../core/theme.dart';

/// Tab "Tài khoản": chưa đăng nhập thì mời đăng nhập; đã đăng nhập thì hiện thông tin và các mục chức năng.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: u == null ? _guest(context) : _member(context, auth),
    );
  }

  // ---- chưa đăng nhập ----
  Widget _guest(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_icon.png', height: 84),
            const SizedBox(height: 20),
            const Text('Đăng nhập để bắt đầu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 6),
            const Text('Đặt xe, đăng xe cho thuê và theo dõi chuyến đi của bạn.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Đăng nhập')),
            const SizedBox(height: 4),
            TextButton(onPressed: () => context.go('/register'), child: const Text('Tạo tài khoản mới')),
          ],
        ),
      ),
    );
  }

  // ---- đã đăng nhập ----
  Widget _member(BuildContext context, AuthProvider auth) {
    final u = auth.user!;
    final words = u.fullName.trim().split(RegExp(r'\s+'));
    final initial = words.isEmpty || words.last.isEmpty ? '?' : words.last[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.brand,
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 2),
                      Text(u.email, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                      if (u.isAdmin) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(999)),
                          child: const Text('Quản trị viên', style: TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _section('Cá nhân'),
        _group([
          _tile(context, Icons.person_outline, 'Hồ sơ của tôi', '/me/profile'),
          _tile(context, Icons.location_on_outlined, 'Sổ địa chỉ', '/me/addresses'),
          _tile(context, Icons.star_outline, 'Đánh giá của tôi', '/me/reviews'),
        ]),
        _section('Cho thuê xe'),
        _group([
          _tile(context, Icons.directions_car_outlined, 'Xe của tôi', '/me/vehicles'),
        ]),
        if (u.isAdmin) ...[
          _section('Quản trị'),
          _group([
            _tile(context, Icons.admin_panel_settings_outlined, 'Trang quản trị', '/admin', go: true),
          ]),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () async {
            await auth.logout();
            if (context.mounted) context.go('/');
          },
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
          ),
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.muted)),
      );

  /// Gom các dòng vào một thẻ, ngăn cách bằng đường kẻ mảnh.
  Widget _group(List<Widget> tiles) {
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      if (i > 0) children.add(const Divider(height: 1, indent: 68));
      children.add(tiles[i]);
    }
    return Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Column(children: children));
  }

  Widget _tile(BuildContext context, IconData icon, String title, String route, {bool go = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.brand, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: () => go ? context.go(route) : context.push(route),
    );
  }
}
