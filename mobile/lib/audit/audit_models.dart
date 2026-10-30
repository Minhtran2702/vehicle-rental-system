/// Một dòng nhật ký audit (khớp AuditLogDto của Back-end).
class AuditLog {
  final int id;
  final String time; // "2026-10-26 09:12:03"
  final String? actor; // email người thực hiện, null nếu là hệ thống
  final String action; // VEHICLE_STATUS_CHANGE, USER_LOCK...
  final String entity; // vehicle, user, booking...
  final String entityId;
  final String? ip;
  final Map<String, dynamic>? before; // dữ liệu trước khi đổi
  final Map<String, dynamic>? after; // dữ liệu sau khi đổi

  const AuditLog({
    required this.id,
    required this.time,
    this.actor,
    required this.action,
    required this.entity,
    required this.entityId,
    this.ip,
    this.before,
    this.after,
  });

  factory AuditLog.fromJson(Map<String, dynamic> j) {
    // Back-end trả "2026-10-26T09:12:03.123": đổi chữ T thành khoảng trắng và bỏ phần lẻ giây
    var t = (j['createdAt'] as String).replaceFirst('T', ' ');
    if (t.length > 19) t = t.substring(0, 19);
    return AuditLog(
      id: (j['id'] as num).toInt(),
      time: t,
      actor: j['userEmail'] as String?,
      action: j['action'] as String,
      entity: j['entityType'] as String,
      entityId: j['entityId']?.toString() ?? '',
      ip: j['ipAddress'] as String?,
      before: j['oldData'] as Map<String, dynamic>?,
      after: j['newData'] as Map<String, dynamic>?,
    );
  }
}