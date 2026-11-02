import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import 'audit_models.dart';

/// Lấy nhật ký audit (chỉ admin xem được).
class AuditService {
  static final List<AuditLog> _mock = [
    AuditLog(id: 9001, time: '2026-10-26 09:12:03', actor: 'admin@vrs.local', action: 'VEHICLE_STATUS_CHANGE', entity: 'vehicle', entityId: '102', ip: '10.0.0.5', before: {'status': 'ACTIVE'}, after: {'status': 'MAINTENANCE'}),
    AuditLog(id: 9002, time: '2026-10-26 08:47:40', actor: 'admin@vrs.local', action: 'USER_LOCK', entity: 'user', entityId: '17', ip: '10.0.0.5', before: {'active': true}, after: {'active': false}),
    AuditLog(id: 9003, time: '2026-10-25 21:30:11', actor: 'owner@vrs.local', action: 'BOOKING_CONFIRM', entity: 'booking', entityId: '5003', ip: '113.161.22.9', before: {'status': 'PENDING'}, after: {'status': 'CONFIRMED'}),
    AuditLog(id: 9004, time: '2026-10-25 17:02:55', actor: 'user@vrs.local', action: 'PAYMENT_CREATE', entity: 'payment', entityId: '7002', ip: '27.74.10.8', after: {'amount': 2100000, 'method': 'MOMO'}),
    AuditLog(id: 9005, time: '2026-10-24 10:15:00', actor: 'admin@vrs.local', action: 'COUPON_UPDATE', entity: 'coupon', entityId: '3', ip: '10.0.0.5', before: {'discountValue': 100000}, after: {'discountValue': 150000}),
    AuditLog(id: 9006, time: '2026-10-23 14:20:32', actor: 'owner@vrs.local', action: 'VEHICLE_UPDATE_PRICE', entity: 'vehicle', entityId: '101', ip: '113.161.22.9', before: {'pricePerDay': 650000}, after: {'pricePerDay': 700000}),
  ];

  /// Lấy tối đa 100 dòng mới nhất. Việc tìm và lọc làm ngay trên điện thoại.
  static Future<List<AuditLog>> list() async {
    if (AppConfig.useMocks) {
      await delay();
      return List.of(_mock);
    }
    try {
      final res = await ApiClient.instance.dio.get('/api/admin/audit-logs', queryParameters: {'size': 100});
      final items = res.data['data']['items'] as List;
      return items.map((e) => AuditLog.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(errorMessage(e));
    }
  }
}