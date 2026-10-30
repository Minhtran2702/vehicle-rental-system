import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../vehicle/maintenance_models.dart';
import '../vehicle/maintenance_service.dart';

/// Lịch sử bảo dưỡng của một xe: xem, thêm, xoá.
class MaintenanceScreen extends StatefulWidget {
  final String vehicleId;
  const MaintenanceScreen({super.key, required this.vehicleId});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  List<MaintenanceRecord>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await MaintenanceService.list(widget.vehicleId);
      if (!mounted) return;
      setState(() { _items = list; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = errorMessage(e); _loading = false; });
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _add() async {
    final input = await showModalBottomSheet<MaintenanceInput>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _MaintenanceForm(),
    );
    if (input == null || !mounted) return;
    try {
      final list = await MaintenanceService.add(widget.vehicleId, input);
      if (!mounted) return;
      setState(() => _items = list);
      _toast('Đã thêm lần bảo dưỡng');
    } catch (e) {
      if (mounted) _toast(errorMessage(e));
    }
  }

  Future<void> _delete(MaintenanceRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá bản ghi?'),
        content: Text('Xoá lần bảo dưỡng "${r.maintenanceType}" ngày ${r.performedDate}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final list = await MaintenanceService.delete(widget.vehicleId, r.id);
      if (!mounted) return;
      setState(() => _items = list);
      _toast('Đã xoá');
    } catch (e) {
      if (mounted) _toast(errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử bảo dưỡng')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Không tải được dữ liệu', style: const TextStyle(color: AppColors.danger)),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Thử lại'),
          ),
        ]),
      );
    }
    if (_items!.isEmpty) {
      return const Center(child: Text('Chưa có lần bảo dưỡng nào. Bấm + để thêm.', style: TextStyle(color: AppColors.muted)));
    }
    // Mới nhất lên đầu (ngày dạng 2026-10-30 nên so sánh chữ cũng đúng thứ tự thời gian)
    final sorted = [..._items!]..sort((a, b) => b.performedDate.compareTo(a.performedDate));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final r = sorted[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.build_circle_outlined, color: AppColors.brand),
            title: Text(r.maintenanceType, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text([
              'Ngày làm: ${r.performedDate}',
              if (r.nextDueDate != null) 'Hẹn lần sau: ${r.nextDueDate}',
              if (r.description != null && r.description!.isNotEmpty) r.description!,
            ].join('\n')),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(vnd(r.cost), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.brand)),
                InkWell(
                  onTap: () => _delete(r),
                  child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.delete_outline, size: 20, color: AppColors.danger)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bảng nhập một lần bảo dưỡng.
class _MaintenanceForm extends StatefulWidget {
  const _MaintenanceForm();

  @override
  State<_MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<_MaintenanceForm> {
  final _form = GlobalKey<FormState>();
  final _type = TextEditingController();
  final _cost = TextEditingController();
  final _performed = TextEditingController();
  final _next = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _type.dispose();
    _cost.dispose();
    _performed.dispose();
    _next.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController c, {required bool future}) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(c.text) ?? now,
      firstDate: DateTime(future ? now.year - 1 : 2000),
      lastDate: DateTime(now.year + (future ? 10 : 0), 12, 31),
    );
    if (d != null) setState(() => c.text = d.toIso8601String().substring(0, 10));
  }

  String? _blank(String s) => s.trim().isEmpty ? null : s.trim();

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      MaintenanceInput(
        maintenanceType: _type.text.trim(),
        description: _blank(_desc.text),
        cost: int.parse(_cost.text.trim()),
        performedDate: _performed.text.trim(),
        nextDueDate: _blank(_next.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thêm lần bảo dưỡng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _type,
              decoration: const InputDecoration(labelText: 'Hạng mục (Thay nhớt, Đăng kiểm...)'),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Vui lòng nhập hạng mục';
                return s.length > 100 ? 'Tối đa 100 ký tự' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cost,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Chi phí (đ)'),
              validator: (v) => int.tryParse((v ?? '').trim()) == null ? 'Vui lòng nhập chi phí' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _performed,
              readOnly: true,
              onTap: () => _pickDate(_performed, future: false),
              decoration: const InputDecoration(labelText: 'Ngày thực hiện', suffixIcon: Icon(Icons.calendar_today)),
              validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng chọn ngày thực hiện' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _next,
              readOnly: true,
              onTap: () => _pickDate(_next, future: true),
              decoration: const InputDecoration(labelText: 'Hẹn lần sau (không bắt buộc)', suffixIcon: Icon(Icons.event)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _desc,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)', alignLabelWithHint: true),
              validator: (v) => (v ?? '').length > 1000 ? 'Tối đa 1000 ký tự' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Lưu'))),
          ],
        ),
      ),
    );
  }
}