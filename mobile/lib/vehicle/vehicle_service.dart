import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import 'vehicle_models.dart';

/// Lấy và lưu xe của chủ xe + danh mục hãng/loại.
/// Dữ liệu giả: lưu trong bộ nhớ (tắt app là mất). Dữ liệu thật: gọi /api/owner/vehicles.
class VehicleService {
  // ---- danh mục (số id trùng với dữ liệu mẫu trong database) ----
  static const _mockBrands = [
    Option(1, 'Toyota'), Option(2, 'Honda'), Option(3, 'Mazda'), Option(4, 'Hyundai'), Option(5, 'Kia'), Option(6, 'VinFast'),
    Option(7, 'Ford'), Option(8, 'Mercedes-Benz'), Option(9, 'BMW'), Option(10, 'Tesla'), Option(11, 'Yamaha'), Option(12, 'Suzuki'),
  ];
  static const _mockCategories = [
    Option(1, 'Sedan'), Option(2, 'SUV'), Option(3, 'Hatchback'), Option(4, 'MPV'),
    Option(5, 'Pickup'), Option(6, 'Luxury'), Option(7, 'Electric'), Option(8, 'Motorbike'),
  ];

  static Future<List<Option>> brands() async {
    if (AppConfig.useMocks) return _mockBrands;
    return _call(() async => _options((await ApiClient.instance.dio.get('/api/brands')).data['data']));
  }

  static Future<List<Option>> categories() async {
    if (AppConfig.useMocks) return _mockCategories;
    return _call(() async => _options((await ApiClient.instance.dio.get('/api/categories')).data['data']));
  }

  // ---- kho xe giả ----
  static int _seq = 3;
  static final List<VehicleDetail> _store = [
    VehicleDetail(
      id: 'mock-1', brandId: 1, brand: 'Toyota', categoryId: 1, category: 'Sedan', model: 'Vios', name: 'Toyota Vios 2022',
      licensePlate: '51K-123.45', color: 'Trắng', transmission: 'AUTO', fuelType: 'GASOLINE', seats: 5, year: 2022, mileage: 24000,
      pricePerDay: 700000, securityDeposit: 3000000, description: 'Xe gia đình, sạch sẽ, tiết kiệm xăng.', status: 'ACTIVE',
      images: [VehicleImage(id: 1, imageUrl: 'https://picsum.photos/seed/vrs1/640/400', primaryImage: true)],
      features: ['Bluetooth', 'Camera lùi'],
      location: const VehicleLocation(10.7769, 106.7009),
    ),
    VehicleDetail(
      id: 'mock-2', brandId: 3, brand: 'Mazda', categoryId: 2, category: 'SUV', model: 'CX-5', name: 'Mazda CX-5 2021',
      licensePlate: '30G-678.90', color: 'Đỏ', transmission: 'AUTO', fuelType: 'GASOLINE', seats: 5, year: 2021, mileage: 41000,
      pricePerDay: 1100000, securityDeposit: 5000000, description: 'SUV rộng rãi, đi xa thoải mái.', status: 'INACTIVE',
      images: [VehicleImage(id: 2, imageUrl: 'https://picsum.photos/seed/vrs2/640/400', primaryImage: true)],
      features: ['Cửa sổ trời'],
    ),
  ];

  static VehicleDetail _find(String id) =>
      _store.firstWhere((v) => v.id == id, orElse: () => throw Exception('Không tìm thấy xe'));

  /// Tạo một VehicleDetail từ dữ liệu form (dùng cho cả thêm mới và sửa).
  static VehicleDetail _build(String id, VehicleInput i, {VehicleDetail? old}) {
    final brand = _mockBrands.firstWhere((b) => b.id == i.brandId).name;
    final category = _mockCategories.firstWhere((c) => c.id == i.categoryId).name;
    return VehicleDetail(
      id: id, brandId: i.brandId, brand: brand, categoryId: i.categoryId, category: category,
      model: i.model, name: '$brand ${i.model} ${i.year}', licensePlate: i.licensePlate.toUpperCase(), color: i.color,
      transmission: i.transmission, fuelType: i.fuelType, seats: i.seats, year: i.year, mileage: i.mileage,
      pricePerDay: i.pricePerDay, securityDeposit: i.securityDeposit, description: i.description,
      status: old?.status ?? 'ACTIVE', images: old?.images ?? [], features: old?.features ?? [], location: old?.location,
    );
  }

  // ---- xe của tôi ----
  static Future<List<MyVehicle>> listMine() async {
    if (AppConfig.useMocks) {
      await delay();
      return _store.map((v) => v.toSummary()).toList();
    }
    return _call(() async {
      final res = await ApiClient.instance.dio.get('/api/owner/vehicles');
      return (res.data['data'] as List).map((e) => MyVehicle.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  static Future<VehicleDetail> get(String id) async {
    if (AppConfig.useMocks) {
      await delay();
      return _find(id);
    }
    return _call(() async => _detail(await ApiClient.instance.dio.get('/api/owner/vehicles/$id')));
  }

  /// Đăng xe mới, có thể kèm luôn ảnh, tiện ích, vị trí.
  static Future<VehicleDetail> create(VehicleInput input,
      {List<String> imageUrls = const [], List<String> features = const [], VehicleLocation? location}) async {
    if (AppConfig.useMocks) {
      await delay();
      if (_store.any((v) => v.licensePlate.toUpperCase() == input.licensePlate.toUpperCase())) {
        throw Exception('Biển số này đã được đăng ký');
      }
      final v = _build('mock-${_seq++}', input);
      for (var n = 0; n < imageUrls.length; n++) {
        v.images.add(VehicleImage(id: _seq * 100 + n, imageUrl: imageUrls[n], primaryImage: n == 0));
      }
      v.features = List.of(features);
      v.location = location;
      _store.add(v);
      return v;
    }
    return _call(() async => _detail(await ApiClient.instance.dio.post('/api/owner/vehicles', data: {
      'vehicle': input.toJson(),
      'imageUrls': imageUrls,
      'features': features,
      'location': location == null ? null : {'latitude': location.latitude, 'longitude': location.longitude},
    })));
  }

  static Future<VehicleDetail> update(String id, VehicleInput input) async {
    if (AppConfig.useMocks) {
      await delay();
      final old = _find(id);
      final dup = _store.any((v) => v.id != id && v.licensePlate.toUpperCase() == input.licensePlate.toUpperCase());
      if (dup) throw Exception('Biển số này đã được đăng ký');
      final v = _build(id, input, old: old);
      _store[_store.indexOf(old)] = v;
      return v;
    }
    return _call(() async => _detail(await ApiClient.instance.dio.put('/api/owner/vehicles/$id', data: input.toJson())));
  }

  static Future<VehicleDetail> setStatus(String id, String status) async {
    if (AppConfig.useMocks) {
      await delay();
      return _find(id)..status = status;
    }
    return _call(() async => _detail(await ApiClient.instance.dio.patch('/api/owner/vehicles/$id/status', data: {'status': status})));
  }

  // ---- ảnh ----
  static Future<VehicleDetail> addImage(String id, String url) async {
    if (AppConfig.useMocks) {
      await delay();
      final v = _find(id);
      v.images = [...v.images, VehicleImage(id: DateTime.now().millisecondsSinceEpoch, imageUrl: url, primaryImage: v.images.isEmpty)];
      return v;
    }
    return _call(() async => _detail(await ApiClient.instance.dio.post('/api/owner/vehicles/$id/images', data: {'imageUrl': url})));
  }

  static Future<VehicleDetail> removeImage(String id, int imageId) async {
    if (AppConfig.useMocks) {
      await delay();
      final v = _find(id);
      v.images = v.images.where((i) => i.id != imageId).toList();
      if (v.images.isNotEmpty && !v.images.any((i) => i.primaryImage)) v.images.first.primaryImage = true;
      return v;
    }
    return _call(() async => _detail(await ApiClient.instance.dio.delete('/api/owner/vehicles/$id/images/$imageId')));
  }

  static Future<VehicleDetail> setPrimaryImage(String id, int imageId) async {
    if (AppConfig.useMocks) {
      await delay();
      final v = _find(id);
      for (final i in v.images) {
        i.primaryImage = i.id == imageId;
      }
      return v;
    }
    return _call(() async => _detail(await ApiClient.instance.dio.patch('/api/owner/vehicles/$id/images/$imageId/primary')));
  }

  // ---- tiện ích và vị trí ----
  static Future<VehicleDetail> saveFeatures(String id, List<String> features) async {
    if (AppConfig.useMocks) {
      await delay();
      return _find(id)..features = List.of(features);
    }
    return _call(() async => _detail(await ApiClient.instance.dio.put('/api/owner/vehicles/$id/features', data: {'features': features})));
  }

  static Future<VehicleDetail> saveLocation(String id, VehicleLocation loc) async {
    if (AppConfig.useMocks) {
      await delay();
      return _find(id)..location = loc;
    }
    return _call(() async => _detail(await ApiClient.instance.dio.put('/api/owner/vehicles/$id/location',
        data: {'latitude': loc.latitude, 'longitude': loc.longitude})));
  }

  // ---- hàm phụ ----
  static VehicleDetail _detail(Response res) => VehicleDetail.fromJson(res.data['data'] as Map<String, dynamic>);

  static List<Option> _options(dynamic data) =>
      (data as List).map((e) => Option.fromJson(e as Map<String, dynamic>)).toList();

  static Future<T> _call<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw Exception(errorMessage(e));
    }
  }
}