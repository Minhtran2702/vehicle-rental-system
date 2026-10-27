/// Kiểu dữ liệu dùng chung (khớp với Back-end và bản web).
class AuthUser {
  final int id;
  final String email;
  final String fullName;
  final String role; // 'CUSTOMER' hoặc 'ADMIN'
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'ADMIN';

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: (j['id'] as num).toInt(),
        email: j['email'] as String,
        fullName: j['fullName'] as String,
        role: j['role'] as String,
        avatarUrl: j['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role,
        'avatarUrl': avatarUrl,
      };
}

class VehicleSummary {
  final int id;
  final String name;
  final String brand;
  final String category;
  final int seats;
  final int pricePerDay;
  final String city;
  final double rating;
  final int reviewCount;
  final String imageUrl;

  const VehicleSummary({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.seats,
    required this.pricePerDay,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
  });
}

/// 1.500.000 -> "1.500.000 đ"
String vnd(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '$b đ';
}
