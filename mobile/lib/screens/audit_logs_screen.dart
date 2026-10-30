import 'dart:convert';

import 'package:flutter/material.dart';

import '../audit/audit_models.dart';
import '../audit/audit_service.dart';
import '../core/api_client.dart';
import '../core/theme.dart';

/// Nhật ký audit cho admin (bản rút gọn): tìm, lọc theo đối tượng, xem dữ liệu trước / sau.
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  List<AuditLog>? _logs;
  bool _loading = true;
  String? _error;
  String _query = '';
  String _entity = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await AuditService.list();
      if (!mounted) return;
      setState(() { _logs = list; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = errorMessage(e); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhật ký audit')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final logs = _logs;
    if (logs == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Không tải được nhật ký', style: const TextStyle(color: AppColors.danger)),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Thử lại'),
          ),
        ]),
      );
    }
    // Các loại đối tượng có trong dữ liệu, dùng làm nút lọc
    final entities = ['ALL', ...{for (final l in logs) l.entity}];
    final q = _query.trim().toLowerCase();
    final rows = logs.where((l) {
      if (_entity != 'ALL' && l.entity != _entity) return false;
      return '${l.actor ?? ''} ${l.action}'.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Tìm theo người thực hiện hoặc hành động', prefixIcon: Icon(Icons.search)),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              for (final e in entities)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(e == 'ALL' ? 'Tất cả' : e),
                    selected: _entity == e,
                    onSelected: (_) => setState(() => _entity = e),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? const Center(child: Text('Không có thao tác nào phù hợp.', style: TextStyle(color: AppColors.muted)))
              : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: rows.length,
              itemBuilder: (_, i) => _logCard(rows[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _logCard(AuditLog l) {
    return Card(
      child: ListTile(
        onTap: () => _showDetail(l),
        title: Container(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: Text(l.action, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${l.actor ?? 'Hệ thống'}\n${l.time}'),
        ),
        isThreeLine: true,
        trailing: Text('${l.entity} #${l.entityId}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ),
    );
  }

  void _showDetail(AuditLog l) {
    String pretty(Map<String, dynamic>? m) => m == null ? 'null' : const JsonEncoder.withIndent('  ').convert(m);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chi tiết #${l.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('Thời gian: ${l.time}'),
            Text('Người thực hiện: ${l.actor ?? 'Hệ thống'}'),
            Text('Hành động: ${l.action}'),
            Text('Đối tượng: ${l.entity} #${l.entityId}'),
            Text('Địa chỉ IP: ${l.ip ?? '-'}'),
            const SizedBox(height: 16),
            const Text('Trước', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
              child: SelectableText(pretty(l.before), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
            const SizedBox(height: 12),
            const Text('Sau', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
              child: SelectableText(pretty(l.after), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}