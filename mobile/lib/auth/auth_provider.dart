import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../core/models.dart';
import '../core/token_store.dart';
import '../mocks/mock_data.dart';

/// Trạng thái đăng nhập. Chạy được với dữ liệu giả (mật khẩu 123456).
/// Khi làm việc "login" ở giai đoạn 5, nối với API thật POST /api/auth/login.
class AuthProvider extends ChangeNotifier {
  AuthUser? user;
  bool loading = true;
  final List<MockUser> _registered = [];

  bool get isLoggedIn => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  Future<void> init() async {
    try {
      final raw = await TokenStore.user;
      final token = await TokenStore.access;
      if (raw != null && token != null) {
        user = AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // dữ liệu hỏng thì bỏ qua
    }
    loading = false;
    notifyListeners();
  }

  Future<AuthUser> login(String email, String password) async {
    AuthUser u;
    if (AppConfig.useMocks) {
      await delay();
      final found = [...mockUsers, ..._registered].where((m) => m.user.email == email && m.password == password);
      if (found.isEmpty) throw Exception('Sai email hoặc mật khẩu');
      u = found.first.user;
      await TokenStore.saveTokens('mock-access-${u.id}', 'mock-refresh-${u.id}');
    } else {
      try {
        final res = await ApiClient.instance.dio.post('/api/auth/login', data: {'email': email, 'password': password});
        final data = res.data['data'];
        await TokenStore.saveTokens(data['accessToken'], data['refreshToken']);
        u = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
      } on DioException catch (e) {
        throw Exception(errorMessage(e));
      }
    }
    await TokenStore.saveUser(jsonEncode(u.toJson()));
    user = u;
    notifyListeners();
    return u;
  }

  /// Đăng ký tài khoản khách thuê. Không tự đăng nhập: đăng ký xong người dùng quay lại màn đăng nhập.
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (AppConfig.useMocks) {
      await delay();
      final exists = [...mockUsers, ..._registered]
          .any((m) => m.user.email.toLowerCase() == email.toLowerCase());
      if (exists) throw Exception('Email đã được sử dụng');
      final id = 100 + _registered.length;
      _registered.add(MockUser(AuthUser(id: id, email: email, fullName: fullName, role: 'CUSTOMER'), password));
    } else {
      try {
        await ApiClient.instance.dio.post('/api/auth/register', data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        });
      } on DioException catch (e) {
        throw Exception(errorMessage(e));
      }
    }
  }

  /// Gọi sau khi sửa hồ sơ để tên hiển thị trong app đổi theo.
  Future<void> updateName(String fullName) async {
    final u = user;
    if (u == null) return;
    final updated = AuthUser(id: u.id, email: u.email, fullName: fullName, role: u.role, avatarUrl: u.avatarUrl);
    await TokenStore.saveUser(jsonEncode(updated.toJson()));
    user = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    await TokenStore.clear();
    user = null;
    notifyListeners();
  }
}
