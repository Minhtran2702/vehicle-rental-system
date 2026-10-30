import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../vehicle/vehicle_models.dart';
import '../vehicle/vehicle_service.dart';
import '../widgets/status_badge.dart';

/// Danh sách xe của chủ xe. Bấm vào xe để quản lý, bấm + để đăng xe mới.
class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  List<MyVehicle>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await VehicleService.listMine();
      if (!mounted) return;
      setState(() { _items = list; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = errorMessage(e); _loading = false; });
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // Mở một màn khác, quay lại thì tải lại danh sách (vì xe có thể vừa được thêm/sửa)
  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) _load();
  }

  Future<void> _setStatus(MyVehicle v, String status) async {
    try {
      await VehicleService.setStatus(v.id, status);
      if (!mounted) return;
      _toast('Đã chuyển "${v.name}" sang: ${statusLabel(status)}');
      _load();
    } catch (e) {
      if (mounted) _toast(errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xe của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open('/me/vehicles/new'),
        icon: const Icon(Icons.add),
        label: const Text('Đăng xe'),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Không tải được danh sách xe', style: const TextStyle(color: AppColors.danger)),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Thử lại'),
          ),
        ]),
      );
    }
    if (_items!.isEmpty) {
      return const Center(child: Text('Bạn chưa đăng xe nào. Bấm "Đăng xe" để bắt đầu.', style: TextStyle(color: AppColors.muted)));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: _items!.length,
        itemBuilder: (_, i) => _vehicleCard(_items![i]),
      ),
    );
  }

  Widget _vehicleCard(MyVehicle v) {
    return Card(
      clipBehavior: Clip.antiAlias, // cắt ảnh theo góc bo của thẻ
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _open('/me/vehicles/${v.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 120,
              child: v.coverImageUrl == null
                  ? Container(color: AppColors.brandSoft, child: const Icon(Icons.directions_car, size: 40, color: AppColors.brand))
                  : Image.network(
                v.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.brandSoft, child: const Icon(Icons.broken_image, color: AppColors.muted)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('${v.licensePlate} · ${v.seats} chỗ · ${transmissionLabel(v.transmission)}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('${vnd(v.pricePerDay)} / ngày', style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    StatusBadge(status: v.status, label: statusLabel(v.status)),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Đổi trạng thái',
              onSelected: (s) => _setStatus(v, s),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'ACTIVE', child: Text('Cho thuê')),
                PopupMenuItem(value: 'INACTIVE', child: Text('Tạm ẩn')),
                PopupMenuItem(value: 'MAINTENANCE', child: Text('Đang bảo dưỡng')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}