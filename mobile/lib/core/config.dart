/// Cấu hình chung.
/// - Android Emulator gọi máy tính qua 10.0.2.2 (KHÔNG dùng localhost).
/// - Điện thoại thật: đổi thành IP máy tính trong mạng wifi, ví dụ http://192.168.1.10:8080
/// Có thể ghi đè khi chạy: flutter run --dart-define=API_URL=http://192.168.1.10:8080 --dart-define=USE_MOCKS=false
class AppConfig {
  static const String apiUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080');

  /// true = dùng dữ liệu giả (không cần Back-end); false = gọi API thật.
  static const bool useMocks =
      bool.fromEnvironment('USE_MOCKS', defaultValue: true);
}
