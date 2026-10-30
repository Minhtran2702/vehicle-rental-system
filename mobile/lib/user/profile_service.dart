import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../core/models.dart';
import 'profile_models.dart';

/// Lấy và lưu hồ sơ + sổ địa chỉ.
/// Dữ liệu giả: lưu tạm trong bộ nhớ (tắt app là mất). Dữ liệu thật: gọi /api/users/me.
class ProfileService {
  // ---- kho dữ liệu giả ----
  static final Map<String, Profile> _mockProfiles = {}; // khoá theo email
  static final List<Address> _mockAddresses = [
    const Address(id: 1, label: 'Nhà', addressLine: '12 Lê Lợi', ward: 'Bến Nghé', district: 'Quận 1', city: 'TP. Hồ Chí Minh', defaultAddress: true),
  ];
  static int _nextAddressId = 2;

  // ---- hồ sơ ----
  static Future<Profile> getProfile(AuthUser u) async {
    if (AppConfig.useMocks) {
      await delay();
      return _mockProfiles[u.email] ??= Profile(id: u.id.toString(), email: u.email, fullName: u.fullName);
    }
    return _call(() async {
      final res = await ApiClient.instance.dio.get('/api/users/me');
      return Profile.fromJson(res.data['data'] as Map<String, dynamic>);
    });
  }

  static Future<Profile> updateProfile(Profile p) async {
    if (AppConfig.useMocks) {
      await delay();
      _mockProfiles[p.email] = p;
      return p;
    }
    return _call(() async {
      final res = await ApiClient.instance.dio.put('/api/users/me', data: p.toUpdateJson());
      return Profile.fromJson(res.data['data'] as Map<String, dynamic>);
    });
  }

  // ---- sổ địa chỉ ----
  static Future<List<Address>> getAddresses() async {
    if (AppConfig.useMocks) {
      await delay();
      return List.of(_mockAddresses);
    }
    return _call(() async {
      final res = await ApiClient.instance.dio.get('/api/users/me/addresses');
      return _parseList(res.data['data']);
    });
  }

  /// Lưu địa chỉ: id == 0 thì thêm mới, ngược lại thì sửa. Trả về danh sách mới nhất.
  static Future<List<Address>> saveAddress(Address a) async {
    if (AppConfig.useMocks) {
      await delay();
      if (a.defaultAddress) _clearDefault();
      if (a.id == 0) {
        _mockAddresses.add(_withId(a, _nextAddressId++));
      } else {
        final i = _mockAddresses.indexWhere((x) => x.id == a.id);
        if (i >= 0) _mockAddresses[i] = a;
      }
      return List.of(_mockAddresses);
    }
    return _call(() async {
      final res = a.id == 0
          ? await ApiClient.instance.dio.post('/api/users/me/addresses', data: a.toJson())
          : await ApiClient.instance.dio.put('/api/users/me/addresses/${a.id}', data: a.toJson());
      return _parseList(res.data['data']);
    });
  }

  static Future<List<Address>> deleteAddress(int id) async {
    if (AppConfig.useMocks) {
      await delay();
      _mockAddresses.removeWhere((x) => x.id == id);
      return List.of(_mockAddresses);
    }
    return _call(() async {
      final res = await ApiClient.instance.dio.delete('/api/users/me/addresses/$id');
      return _parseList(res.data['data']);
    });
  }

  // ---- hàm phụ ----
  static List<Address> _parseList(dynamic data) =>
      (data as List).map((e) => Address.fromJson(e as Map<String, dynamic>)).toList();

  /// Chạy một lệnh gọi API; nếu lỗi mạng/Back-end thì đổi thành câu tiếng Việt dễ đọc.
  static Future<T> _call<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw Exception(errorMessage(e));
    }
  }

  // Chỉ một địa chỉ được là mặc định: khi chọn cái mới thì bỏ cờ mặc định của các cái cũ.
  static void _clearDefault() {
    for (var i = 0; i < _mockAddresses.length; i++) {
      final x = _mockAddresses[i];
      if (x.defaultAddress) _mockAddresses[i] = _copy(x, defaultAddress: false);
    }
  }

  static Address _withId(Address a, int id) => Address(
      id: id, label: a.label, addressLine: a.addressLine, ward: a.ward, district: a.district,
      city: a.city, country: a.country, postalCode: a.postalCode, defaultAddress: a.defaultAddress);

  static Address _copy(Address a, {required bool defaultAddress}) => Address(
      id: a.id, label: a.label, addressLine: a.addressLine, ward: a.ward, district: a.district,
      city: a.city, country: a.country, postalCode: a.postalCode, defaultAddress: defaultAddress);
}