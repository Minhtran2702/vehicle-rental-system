/// Hồ sơ cá nhân (khớp ProfileDto của Back-end).
class Profile {
  final String id; // Back-end dùng UUID (chuỗi), không phải số
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? dateOfBirth; // dạng "2000-12-31"
  final String? gender; // MALE, FEMALE hoặc OTHER
  final String? bio;
  final String? idCardNumber;
  final String? driverLicenseNumber;

  const Profile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.idCardNumber,
    this.driverLicenseNumber,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    id: j['id'].toString(),
    email: j['email'] as String,
    fullName: j['fullName'] as String,
    phone: j['phone'] as String?,
    avatarUrl: j['avatarUrl'] as String?,
    dateOfBirth: j['dateOfBirth'] as String?,
    gender: j['gender'] as String?,
    bio: j['bio'] as String?,
    idCardNumber: j['idCardNumber'] as String?,
    driverLicenseNumber: j['driverLicenseNumber'] as String?,
  );

  /// Dữ liệu gửi lên khi sửa hồ sơ (Back-end không cho đổi email và vai trò nên không gửi).
  Map<String, dynamic> toUpdateJson() => {
    'fullName': fullName,
    'phone': phone,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'bio': bio,
    'avatarUrl': avatarUrl,
    'idCardNumber': idCardNumber,
    'driverLicenseNumber': driverLicenseNumber,
  };
}

/// Một địa chỉ trong sổ địa chỉ (khớp AddressDto / AddressRequest của Back-end).
class Address {
  final int id; // 0 = địa chỉ mới chưa lưu
  final String label; // tên gợi nhớ: "Nhà", "Công ty"
  final String addressLine; // số nhà, đường
  final String? ward;
  final String? district;
  final String city;
  final String? country;
  final String? postalCode;
  final bool defaultAddress;

  const Address({
    this.id = 0,
    required this.label,
    required this.addressLine,
    this.ward,
    this.district,
    required this.city,
    this.country,
    this.postalCode,
    this.defaultAddress = false,
  });

  factory Address.fromJson(Map<String, dynamic> j) => Address(
    id: (j['id'] as num).toInt(),
    label: j['label'] as String,
    addressLine: j['addressLine'] as String,
    ward: j['ward'] as String?,
    district: j['district'] as String?,
    city: j['city'] as String,
    country: j['country'] as String?,
    postalCode: j['postalCode'] as String?,
    defaultAddress: (j['defaultAddress'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    'addressLine': addressLine,
    'ward': ward,
    'district': district,
    'city': city,
    'country': country,
    'postalCode': postalCode,
    'defaultAddress': defaultAddress,
  };

  /// Dòng địa chỉ đầy đủ để hiển thị: "12 Lê Lợi, Bến Nghé, Quận 1, TP.HCM"
  String get fullText => [addressLine, ward, district, city]
      .where((s) => s != null && s.trim().isNotEmpty)
      .join(', ');
}