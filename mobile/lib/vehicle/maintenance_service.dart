import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import 'maintenance_models.dart';

/// Sổ bảo dưỡng của từng xe. Dữ liệu giả lưu trong bộ nhớ theo mã xe.
class MaintenanceService {
  static final Map<String, List<MaintenanceRecord>> _mock = {
    'mock-1': [
      const MaintenanceRecord(
        id: 1,
        maintenanceType: 'Thay nhớt',
        description: 'Thay nhớt và lọc nhớt',
        cost: 650000,
        performedDate: '2026-09-15',
        nextDueDate: '2027-03-15',
      ),
    ],
  };
  static int _seq = 100;

  static Future<List<MaintenanceRecord>> list(String vehicleId) async {
    if (AppConfig.useMocks) {
      await delay();
      return List.of(_mock[vehicleId] ?? []);
    }
    return _call(() async => _parse(await ApiClient.instance.dio.get('/api/owner/vehicles/$vehicleId/maintenance')));
  }

  static Future<List<MaintenanceRecord>> add(String vehicleId, MaintenanceInput input) async {
    if (AppConfig.useMocks) {
      await delay();
      final items = _mock.putIfAbsent(vehicleId, () => []);
      items.add(MaintenanceRecord(
        id: _seq++,
        maintenanceType: input.maintenanceType,
        description: input.description,
        cost: input.cost,
        performedDate: input.performedDate,
        nextDueDate: input.nextDueDate,
      ));
      return List.of(items);
    }
    return _call(() async =>
        _parse(await ApiClient.instance.dio.post('/api/owner/vehicles/$vehicleId/maintenance', data: input.toJson())));
  }

  static Future<List<MaintenanceRecord>> delete(String vehicleId, int recordId) async {
    if (AppConfig.useMocks) {
      await delay();
      final items = _mock[vehicleId] ?? [];
      items.removeWhere((r) => r.id == recordId);
      return List.of(items);
    }
    return _call(() async =>
        _parse(await ApiClient.instance.dio.delete('/api/owner/vehicles/$vehicleId/maintenance/$recordId')));
  }

  static List<MaintenanceRecord> _parse(Response res) =>
      (res.data['data'] as List).map((e) => MaintenanceRecord.fromJson(e as Map<String, dynamic>)).toList();

  static Future<T> _call<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw Exception(errorMessage(e));
    }
  }
}