/// Một lần bảo dưỡng (khớp MaintenanceDto của Back-end).
class MaintenanceRecord {
  final int id;
  final String maintenanceType; // hạng mục: "Thay nhớt", "Đăng kiểm"...
  final String? description;
  final int cost;
  final String performedDate; // ngày làm, dạng 2026-10-30
  final String? nextDueDate; // ngày hẹn lần sau

  const MaintenanceRecord({
    required this.id,
    required this.maintenanceType,
    this.description,
    required this.cost,
    required this.performedDate,
    this.nextDueDate,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> j) => MaintenanceRecord(
    id: (j['id'] as num).toInt(),
    maintenanceType: j['maintenanceType'] as String,
    description: j['description'] as String?,
    cost: (j['cost'] as num).round(),
    performedDate: j['performedDate'] as String,
    nextDueDate: j['nextDueDate'] as String?,
  );
}

/// Dữ liệu người dùng nhập khi thêm một lần bảo dưỡng (khớp MaintenanceRequest).
class MaintenanceInput {
  final String maintenanceType;
  final String? description;
  final int cost;
  final String performedDate;
  final String? nextDueDate;

  const MaintenanceInput({
    required this.maintenanceType,
    this.description,
    required this.cost,
    required this.performedDate,
    this.nextDueDate,
  });

  Map<String, dynamic> toJson() => {
    'maintenanceType': maintenanceType,
    'description': description,
    'cost': cost,
    'performedDate': performedDate,
    'nextDueDate': nextDueDate,
  };
}