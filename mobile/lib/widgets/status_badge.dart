import 'package:flutter/material.dart';

/// Nhãn trạng thái (đơn đặt xe, xe, thanh toán…). Truyền status viết hoa như trong DB.
class StatusBadge extends StatelessWidget {
  final String status;
  final String? label;
  const StatusBadge({super.key, required this.status, this.label});

  static const _colors = <String, List<Color>>{
    'PENDING': [Color(0xFFFEF3C7), Color(0xFF92400E)],
    'CONFIRMED': [Color(0xFFDBEAFE), Color(0xFF1E40AF)],
    'IN_PROGRESS': [Color(0xFFE0E7FF), Color(0xFF3730A3)],
    'COMPLETED': [Color(0xFFDCFCE7), Color(0xFF166534)],
    'CANCELLED': [Color(0xFFE2E8F0), Color(0xFF334155)],
    'REJECTED': [Color(0xFFFEE2E2), Color(0xFF991B1B)],
    'ACTIVE': [Color(0xFFDCFCE7), Color(0xFF166534)],
    'INACTIVE': [Color(0xFFE2E8F0), Color(0xFF334155)],
    'MAINTENANCE': [Color(0xFFFFEDD5), Color(0xFF9A3412)],
    'PAID': [Color(0xFFDCFCE7), Color(0xFF166534)],
    'REFUNDED': [Color(0xFFF3E8FF), Color(0xFF6B21A8)],
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors[status] ?? const [Color(0xFFF1F5F9), Color(0xFF334155)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c[0], borderRadius: BorderRadius.circular(999)),
      child: Text(label ?? status, style: TextStyle(color: c[1], fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
