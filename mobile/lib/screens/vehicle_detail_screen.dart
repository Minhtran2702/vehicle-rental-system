import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../vehicle/vehicle_models.dart';
import '../vehicle/vehicle_service.dart';
import '../widgets/status_badge.dart';

/// Trang quản lý một xe của chủ xe: thông tin, trạng thái, ảnh, tiện ích, vị trí.
class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  VehicleDetail? _v;
  bool _loading = true;
  bool _busy = false; // đang gửi một thay đổi lên (hiện thanh chạy ở trên cùng)
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await VehicleService.get(widget.vehicleId);
      if (!mounted) return;
      setState(() { _v = v; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = errorMessage(e); _loading = false; });
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  /// Chạy một thay đổi (đổi trạng thái, thêm ảnh...): bật thanh chạy, gọi API, cập nhật xe, báo kết quả.
  Future<void> _run(Future<VehicleDetail> Function() action, [String? okMessage]) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final v = await action();
      if (!mounted) return;
      setState(() => _v = v);
      if (okMessage != null) _toast(okMessage);
    } catch (e) {
      if (mounted) _toast(errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit() async {
    await context.push('/me/vehicles/${widget.vehicleId}/edit');
    if (mounted) _load();
  }

  // ---- các hộp thoại nhỏ ----
  Future<bool> _confirm(String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đồng ý')),
        ],
      ),
    );
    return ok == true;
  }

  /// Hộp thoại hỏi một dòng chữ. Trả về chữ đã nhập, hoặc null nếu bấm Huỷ.
  Future<String?> _askText(String title, String label, String? Function(String) check) {
    final form = GlobalKey<FormState>();
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Form(
          key: form,
          child: TextFormField(
            controller: c,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
            validator: (v) => check((v ?? '').trim()),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          TextButton(
            onPressed: () { if (form.currentState!.validate()) Navigator.pop(ctx, c.text.trim()); },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<VehicleLocation?> _askLocation(VehicleLocation? cur) {
    final form = GlobalKey<FormState>();
    final lat = TextEditingController(text: cur?.latitude.toString() ?? '');
    final lng = TextEditingController(text: cur?.longitude.toString() ?? '');
    double? parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));
    const kb = TextInputType.numberWithOptions(decimal: true, signed: true);
    return showDialog<VehicleLocation>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vị trí xe'),
        content: Form(
          key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: lat,
              keyboardType: kb,
              decoration: const InputDecoration(labelText: 'Vĩ độ (-90 đến 90)'),
              validator: (v) {
                final n = parse(v ?? '');
                if (n == null) return 'Vui lòng nhập số';
                return (n < -90 || n > 90) ? 'Từ -90 đến 90' : null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: lng,
              keyboardType: kb,
              decoration: const InputDecoration(labelText: 'Kinh độ (-180 đến 180)'),
              validator: (v) {
                final n = parse(v ?? '');
                if (n == null) return 'Vui lòng nhập số';
                return (n < -180 || n > 180) ? 'Từ -180 đến 180' : null;
              },
            ),
            const SizedBox(height: 8),
            const Text('Ví dụ TP. Hồ Chí Minh: 10.7769, 106.7009', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, VehicleLocation(parse(lat.text)!, parse(lng.text)!));
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // ---- các thao tác ----
  Future<void> _addImage() async {
    final url = await _askText('Thêm ảnh', 'Đường dẫn ảnh (https://...)', (s) {
      if (!s.startsWith('http://') && !s.startsWith('https://')) return 'Đường dẫn phải bắt đầu bằng http hoặc https';
      return s.length > 500 ? 'Tối đa 500 ký tự' : null;
    });
    if (url == null) return;
    _run(() => VehicleService.addImage(widget.vehicleId, url), 'Đã thêm ảnh');
  }

  Future<void> _removeImage(VehicleImage img) async {
    if (!await _confirm('Xoá ảnh này?')) return;
    _run(() => VehicleService.removeImage(widget.vehicleId, img.id), 'Đã xoá ảnh');
  }

  Future<void> _addFeature(VehicleDetail v) async {
    if (v.features.length >= 30) return _toast('Tối đa 30 tiện ích');
    final name = await _askText('Thêm tiện ích', 'Tên tiện ích', (s) {
      if (s.isEmpty) return 'Vui lòng nhập tên tiện ích';
      return s.length > 50 ? 'Tối đa 50 ký tự' : null;
    });
    if (name == null) return;
    if (v.features.any((f) => f.toLowerCase() == name.toLowerCase())) return _toast('Tiện ích này đã có');
    _run(() => VehicleService.saveFeatures(widget.vehicleId, [...v.features, name]), 'Đã thêm tiện ích');
  }

  Future<void> _editLocation(VehicleDetail v) async {
    final loc = await _askLocation(v.location);
    if (loc == null) return;
    _run(() => VehicleService.saveLocation(widget.vehicleId, loc), 'Đã lưu vị trí');
  }

  // ---- giao diện ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý xe'),
        actions: [
          if (_v != null) IconButton(tooltip: 'Sửa thông tin', icon: const Icon(Icons.edit_outlined), onPressed: _edit),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final v = _v;
    if (v == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Không tải được xe', style: const TextStyle(color: AppColors.danger)),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Thử lại'),
          ),
        ]),
      );
    }
    return Column(
      children: [
        if (_busy) const LinearProgressIndicator(minHeight: 3),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _infoCard(v),
              const SizedBox(height: 20),
              _sectionTitle('Hình ảnh (${v.images.length})', 'Thêm ảnh', Icons.add_photo_alternate_outlined, _addImage),
              _images(v),
              const SizedBox(height: 20),
              _sectionTitle('Tiện ích', null, null, null),
              _features(v),
              const SizedBox(height: 20),
              _sectionTitle('Vị trí', v.location == null ? 'Đặt vị trí' : 'Đổi vị trí', Icons.place_outlined, () => _editLocation(v)),
              Text(
                v.location == null
                    ? 'Chưa đặt vị trí'
                    : 'Vĩ độ ${v.location!.latitude.toStringAsFixed(5)}, kinh độ ${v.location!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Bảo dưỡng', null, null, null),
              OutlinedButton.icon(
                onPressed: () => context.push('/me/vehicles/${v.id}/maintenance'),
                icon: const Icon(Icons.build_circle_outlined),
                label: const Text('Xem lịch sử bảo dưỡng'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String? action, IconData? icon, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          if (action != null) TextButton.icon(onPressed: _busy ? null : onTap, icon: Icon(icon, size: 18), label: Text(action)),
        ],
      ),
    );
  }

  Widget _infoCard(VehicleDetail v) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${v.licensePlate} · ${v.brand} · ${v.category} · ${v.seats} chỗ',
                style: const TextStyle(color: AppColors.muted)),
            Text('${transmissionLabel(v.transmission)} · ${fuelLabel(v.fuelType)} · ${v.year} · ${v.mileage} km',
                style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            Text('${vnd(v.pricePerDay)} / ngày', style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w700, fontSize: 18)),
            Text('Tiền cọc: ${vnd(v.securityDeposit)}', style: const TextStyle(color: AppColors.muted)),
            if (v.description != null && v.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(v.description!),
            ],
            const Divider(height: 28),
            Row(
              children: [
                StatusBadge(status: v.status, label: statusLabel(v.status)),
                const Spacer(),
                const Text('Đổi trạng thái: ', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                DropdownButton<String>(
                  value: v.status,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Cho thuê')),
                    DropdownMenuItem(value: 'INACTIVE', child: Text('Tạm ẩn')),
                    DropdownMenuItem(value: 'MAINTENANCE', child: Text('Bảo dưỡng')),
                  ],
                  onChanged: _busy ? null : (s) => _run(() => VehicleService.setStatus(v.id, s!), 'Đã đổi trạng thái'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _images(VehicleDetail v) {
    if (v.images.isEmpty) {
      return const Text('Chưa có ảnh. Xe có ảnh đẹp sẽ dễ được thuê hơn.', style: TextStyle(color: AppColors.muted));
    }
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: v.images.length,
        itemBuilder: (_, i) {
          final img = v.images[i];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    img.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.brandSoft, child: const Icon(Icons.broken_image, color: AppColors.muted)),
                  ),
                  if (img.primaryImage)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Ảnh bìa', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (s) {
                          if (s == 'primary') {
                            _run(() => VehicleService.setPrimaryImage(v.id, img.id), 'Đã đặt làm ảnh bìa');
                          } else {
                            _removeImage(img);
                          }
                        },
                        itemBuilder: (_) => [
                          if (!img.primaryImage) const PopupMenuItem(value: 'primary', child: Text('Đặt làm ảnh bìa')),
                          const PopupMenuItem(value: 'delete', child: Text('Xoá ảnh')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _features(VehicleDetail v) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final f in v.features)
          InputChip(
            label: Text(f),
            onDeleted: _busy
                ? null
                : () => _run(() => VehicleService.saveFeatures(v.id, v.features.where((x) => x != f).toList()), 'Đã xoá tiện ích'),
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Thêm'),
          onPressed: _busy ? null : () => _addFeature(v),
        ),
      ],
    );
  }
}