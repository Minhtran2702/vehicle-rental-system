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
      final found = mockUsers.where((m) => m.user.email == email && m.password == password);
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

  Future<void> logout() async {
    await TokenStore.clear();
    user = null;
    notifyListeners();
  }
}
