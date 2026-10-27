import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';

/// Khung màn hình Admin (bản rút gọn trên điện thoại). Thêm các mục quản trị vào danh sách bên dưới.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async { await context.read<AuthProvider>().logout(); if (context.mounted) context.go('/'); },
          ),
        ],
      ),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.bar_chart), title: Text('Thống kê'), subtitle: Text('Đang phát triển')),
          ListTile(leading: Icon(Icons.people), title: Text('Người dùng'), subtitle: Text('Đang phát triển')),
          ListTile(leading: Icon(Icons.directions_car), title: Text('Xe'), subtitle: Text('Đang phát triển')),
          ListTile(leading: Icon(Icons.receipt_long), title: Text('Đơn đặt xe và coupon'), subtitle: Text('Đang phát triển')),
          ListTile(leading: Icon(Icons.history), title: Text('Nhật ký audit'), subtitle: Text('Đang phát triển')),
        ],
      ),
    );
  }
}
