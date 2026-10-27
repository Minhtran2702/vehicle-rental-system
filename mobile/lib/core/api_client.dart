import 'package:dio/dio.dart';

import 'config.dart';
import 'token_store.dart';

/// Dio dùng chung: tự gắn JWT, tự làm mới token khi gặp 401 (chỉ làm mới 1 lần dù nhiều request cùng lỗi).
/// Phản hồi của Back-end luôn có dạng { success, message, data, timestamp }.
class ApiClient {
  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStore.access;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) async {
        final req = e.requestOptions;
        final isAuthCall = req.path.contains('/api/auth/');
        if (e.response?.statusCode == 401 && !isAuthCall && req.extra['retried'] != true) {
          try {
            final newToken = await _refreshOnce();
            req.extra['retried'] = true;
            req.headers['Authorization'] = 'Bearer $newToken';
            return handler.resolve(await dio.fetch(req));
          } catch (_) {
            await TokenStore.clear();
          }
        }
        handler.next(e);
      },
    ));
  }

  static final ApiClient instance = ApiClient._();
  late final Dio dio;
  Future<String>? _refreshing;

  Future<String> _refreshOnce() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String> _doRefresh() async {
    final refresh = await TokenStore.refresh;
    if (refresh == null) throw Exception('Không có refresh token');
    // Endpoint do việc "login" làm ở Back-end: POST /api/auth/refresh
    final res = await Dio(BaseOptions(baseUrl: AppConfig.apiUrl))
        .post('/api/auth/refresh', data: {'refreshToken': refresh});
    final data = res.data['data'];
    await TokenStore.saveTokens(data['accessToken'], data['refreshToken']);
    return data['accessToken'] as String;
  }
}

/// Lấy thông báo lỗi dễ đọc từ lỗi Dio.
String errorMessage(Object e) {
  if (e is DioException) {
    final msg = e.response?.data is Map ? e.response?.data['message'] : null;
    if (msg is String) return msg;
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return 'Không kết nối được máy chủ. Kiểm tra Back-end đã bật và địa chỉ ${AppConfig.apiUrl}';
    }
    return e.message ?? 'Có lỗi xảy ra';
  }
  return e.toString().replaceFirst('Exception: ', '');
}

/// Giả lập độ trễ mạng khi dùng dữ liệu giả.
Future<void> delay([int ms = 300]) => Future.delayed(Duration(milliseconds: ms));
