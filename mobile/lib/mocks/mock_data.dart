import '../core/models.dart';

/// Dữ liệu giả dùng chung. Mỗi người thêm dữ liệu giả của chức năng mình vào file riêng trong thư mục mocks.
class MockUser {
  final AuthUser user;
  final String password;
  const MockUser(this.user, this.password);
}

const mockUsers = <MockUser>[
  MockUser(AuthUser(id: 1, email: 'admin@vrs.local', fullName: 'Quản trị viên', role: 'ADMIN'), '123456'),
  MockUser(AuthUser(id: 2, email: 'owner@vrs.local', fullName: 'Nguyễn Chủ Xe', role: 'CUSTOMER'), '123456'),
  MockUser(AuthUser(id: 3, email: 'user@vrs.local', fullName: 'Trần Khách Thuê', role: 'CUSTOMER'), '123456'),
];

String _img(int n) => 'https://picsum.photos/seed/vrs$n/640/400';

final mockVehicles = <VehicleSummary>[
  VehicleSummary(id: 1, name: 'Toyota Vios 2022', brand: 'Toyota', category: 'Sedan', seats: 5, pricePerDay: 700000, city: 'TP. Hồ Chí Minh', rating: 4.8, reviewCount: 32, imageUrl: _img(1)),
  VehicleSummary(id: 2, name: 'Mazda CX-5 2021', brand: 'Mazda', category: 'SUV', seats: 5, pricePerDay: 1100000, city: 'Hà Nội', rating: 4.7, reviewCount: 21, imageUrl: _img(2)),
  VehicleSummary(id: 3, name: 'VinFast VF e34', brand: 'VinFast', category: 'Electric', seats: 5, pricePerDay: 1000000, city: 'Đà Nẵng', rating: 4.6, reviewCount: 14, imageUrl: _img(3)),
  VehicleSummary(id: 4, name: 'Kia Carnival 2023', brand: 'Kia', category: 'MPV', seats: 7, pricePerDay: 1600000, city: 'TP. Hồ Chí Minh', rating: 4.9, reviewCount: 18, imageUrl: _img(4)),
  VehicleSummary(id: 5, name: 'Honda SH 150i', brand: 'Honda', category: 'Motorbike', seats: 2, pricePerDay: 250000, city: 'Đà Nẵng', rating: 4.5, reviewCount: 40, imageUrl: _img(5)),
  VehicleSummary(id: 6, name: 'Mercedes C300', brand: 'Mercedes-Benz', category: 'Luxury', seats: 5, pricePerDay: 2500000, city: 'Hà Nội', rating: 4.9, reviewCount: 9, imageUrl: _img(6)),
];
