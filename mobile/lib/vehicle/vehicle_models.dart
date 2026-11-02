/// Một lựa chọn trong danh sách thả xuống (hãng xe, loại xe).
class Option {
  final int id;
  final String name;
  const Option(this.id, this.name);

  factory Option.fromJson(Map<String, dynamic> j) => Option((j['id'] as num).toInt(), j['name'] as String);
}

class VehicleImage {
  final int id;
  final String imageUrl;
  bool primaryImage; // ảnh bìa

  VehicleImage({required this.id, required this.imageUrl, this.primaryImage = false});

  factory VehicleImage.fromJson(Map<String, dynamic> j) => VehicleImage(
    id: (j['id'] as num).toInt(),
    imageUrl: j['imageUrl'] as String,
    primaryImage: (j['primaryImage'] as bool?) ?? false,
  );
}

class VehicleLocation {
  final double latitude;
  final double longitude;
  const VehicleLocation(this.latitude, this.longitude);

  factory VehicleLocation.fromJson(Map<String, dynamic> j) =>
      VehicleLocation((j['latitude'] as num).toDouble(), (j['longitude'] as num).toDouble());
}

/// Xe trong danh sách "Xe của tôi" (khớp VehicleSummary của Back-end).
class MyVehicle {
  final String id; // UUID
  final String name;
  final String licensePlate;
  final int seats;
  final String transmission;
  final String fuelType;
  final int pricePerDay;
  final String status;
  final String? coverImageUrl;
  final double rating;
  final int totalReviews;

  const MyVehicle({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.pricePerDay,
    required this.status,
    this.coverImageUrl,
    this.rating = 0,
    this.totalReviews = 0,
  });

  factory MyVehicle.fromJson(Map<String, dynamic> j) => MyVehicle(
    id: j['id'].toString(),
    name: j['name'] as String,
    licensePlate: j['licensePlate'] as String,
    seats: (j['seats'] as num).toInt(),
    transmission: j['transmission'] as String,
    fuelType: j['fuelType'] as String,
    pricePerDay: (j['pricePerDay'] as num).round(),
    status: j['status'] as String,
    coverImageUrl: j['coverImageUrl'] as String?,
    rating: (j['averageRating'] as num?)?.toDouble() ?? 0,
    totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
  );
}

/// Chi tiết đầy đủ một xe (khớp VehicleDetail của Back-end).
class VehicleDetail {
  final String id;
  final int brandId;
  final String brand;
  final int categoryId;
  final String category;
  final String model;
  final String name;
  final String licensePlate;
  final String? color;
  final String transmission;
  final String fuelType;
  final int seats;
  final int year;
  final int mileage;
  final int pricePerDay;
  final int securityDeposit;
  final String? description;
  final double rating;
  final int totalReviews;
  // 4 thứ này đổi được sau khi tạo xe nên không đặt final
  String status;
  List<VehicleImage> images;
  List<String> features;
  VehicleLocation? location;

  VehicleDetail({
    required this.id,
    required this.brandId,
    required this.brand,
    required this.categoryId,
    required this.category,
    required this.model,
    required this.name,
    required this.licensePlate,
    this.color,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.year,
    required this.mileage,
    required this.pricePerDay,
    required this.securityDeposit,
    this.description,
    this.rating = 0,
    this.totalReviews = 0,
    required this.status,
    this.images = const [],
    this.features = const [],
    this.location,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> j) => VehicleDetail(
    id: j['id'].toString(),
    brandId: (j['brandId'] as num).toInt(),
    brand: j['brand'] as String,
    categoryId: (j['categoryId'] as num).toInt(),
    category: j['category'] as String,
    model: j['model'] as String,
    name: j['name'] as String,
    licensePlate: j['licensePlate'] as String,
    color: j['color'] as String?,
    transmission: j['transmission'] as String,
    fuelType: j['fuelType'] as String,
    seats: (j['seats'] as num).toInt(),
    year: (j['year'] as num).toInt(),
    mileage: (j['mileage'] as num).toInt(),
    pricePerDay: (j['pricePerDay'] as num).round(),
    securityDeposit: (j['securityDeposit'] as num).round(),
    description: j['description'] as String?,
    rating: (j['averageRating'] as num?)?.toDouble() ?? 0,
    totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
    status: j['status'] as String,
    images: ((j['images'] as List?) ?? []).map((e) => VehicleImage.fromJson(e as Map<String, dynamic>)).toList(),
    features: ((j['features'] as List?) ?? []).map((e) => e.toString()).toList(),
    location: j['location'] == null ? null : VehicleLocation.fromJson(j['location'] as Map<String, dynamic>),
  );

  /// Ảnh bìa: ảnh được đánh dấu chính, không có thì lấy ảnh đầu, không có ảnh nào thì null.
  String? get coverUrl {
    for (final i in images) {
      if (i.primaryImage) return i.imageUrl;
    }
    return images.isEmpty ? null : images.first.imageUrl;
  }

  MyVehicle toSummary() => MyVehicle(
    id: id,
    name: name,
    licensePlate: licensePlate,
    seats: seats,
    transmission: transmission,
    fuelType: fuelType,
    pricePerDay: pricePerDay,
    status: status,
    coverImageUrl: coverUrl,
    rating: rating,
    totalReviews: totalReviews,
  );
}

/// Dữ liệu người dùng nhập ở form đăng xe / sửa xe (khớp VehicleRequest của Back-end).
class VehicleInput {
  final int brandId;
  final int categoryId;
  final String model;
  final String licensePlate;
  final String? color;
  final String transmission;
  final String fuelType;
  final int seats;
  final int year;
  final int mileage;
  final int pricePerDay;
  final int securityDeposit;
  final String? description;

  const VehicleInput({
    required this.brandId,
    required this.categoryId,
    required this.model,
    required this.licensePlate,
    this.color,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.year,
    required this.mileage,
    required this.pricePerDay,
    required this.securityDeposit,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'brandId': brandId,
    'categoryId': categoryId,
    'model': model,
    'licensePlate': licensePlate,
    'color': color,
    'transmission': transmission,
    'fuelType': fuelType,
    'seats': seats,
    'year': year,
    'mileage': mileage,
    'pricePerDay': pricePerDay,
    'securityDeposit': securityDeposit,
    'description': description,
  };
}

// ---- đổi mã của Back-end sang chữ tiếng Việt để hiển thị ----
String statusLabel(String s) => switch (s) {
  'ACTIVE' => 'Đang cho thuê',
  'INACTIVE' => 'Tạm ẩn',
  'MAINTENANCE' => 'Đang bảo dưỡng',
  _ => s,
};

String transmissionLabel(String s) => s == 'AUTO' ? 'Số tự động' : 'Số sàn';

String fuelLabel(String s) => switch (s) {
  'GASOLINE' => 'Xăng',
  'DIESEL' => 'Dầu',
  'ELECTRIC' => 'Điện',
  'HYBRID' => 'Hybrid',
  _ => s,
};