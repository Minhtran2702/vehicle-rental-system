import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lưu token và thông tin đăng nhập trong bộ nhớ an toàn của điện thoại.
class TokenStore {
  static const _storage = FlutterSecureStorage();
  static const _access = 'vrs_access';
  static const _refresh = 'vrs_refresh';
  static const _user = 'vrs_user';

  static Future<String?> get access => _storage.read(key: _access);
  static Future<String?> get refresh => _storage.read(key: _refresh);
  static Future<String?> get user => _storage.read(key: _user);

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _access, value: access);
    await _storage.write(key: _refresh, value: refresh);
  }

  static Future<void> saveUser(String json) => _storage.write(key: _user, value: json);

  static Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
    await _storage.delete(key: _user);
  }
}
