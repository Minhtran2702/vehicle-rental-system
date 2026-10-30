import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../vehicle/vehicle_models.dart';
import '../vehicle/vehicle_service.dart';

String? _blank(String s) => s.trim().isEmpty ? null : s.trim();

/// Form đăng xe mới (vehicleId == null) hoặc sửa xe (có vehicleId).
class VehicleFormScreen extends StatefulWidget {
  final String? vehicleId;
  const VehicleFormScreen({super.key, this.vehicleId});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _form = GlobalKey<FormState>();
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _color = TextEditingController();
  final _seats = TextEditingController();
  final _year = TextEditingController();
  final _mileage = TextEditingController();
  final _price = TextEditingController();
  final _deposit = TextEditingController();
  final _desc = TextEditingController();

  List<Option> _brands = [];
  List<Option> _categories = [];
  int? _brandId;
  int? _categoryId;
  String _transmission = 'AUTO';
  String _fuel = 'GASOLINE';

  bool _loading = true; // đang tải danh mục (và xe cũ nếu là sửa)
  bool _ready = false; // tải xong, được phép hiện form
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_model, _plate, _color, _seats, _year, _mileage, _price, _deposit, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final lists = await Future.wait([VehicleService.brands(), VehicleService.categories()]);
      _brands = lists[0];
      _categories = lists[1];
      if (_isEdit) {
        final v = await VehicleService.get(widget.vehicleId!);
        _brandId = v.brandId;
        _categoryId = v.categoryId;
        _model.text = v.model;
        _plate.text = v.licensePlate;
        _color.text = v.color ?? '';
        _transmission = v.transmission;
        _fuel = v.fuelType;
        _seats.text = v.seats.toString();
        _year.text = v.year.toString();
        _mileage.text = v.mileage.toString();
        _price.text = v.pricePerDay.toString();
        _deposit.text = v.securityDeposit.toString();
        _desc.text = v.description ?? '';
      }
      if (!mounted) return;
      setState(() { _loading = false; _ready = true; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = errorMessage(e); });
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final input = VehicleInput(
        brandId: _brandId!,
        categoryId: _categoryId!,
        model: _model.text.trim(),
        licensePlate: _plate.text.trim(),
        color: _blank(_color.text),
        transmission: _transmission,
        fuelType: _fuel,
        seats: int.parse(_seats.text.trim()),
        year: int.parse(_year.text.trim()),
        mileage: int.parse(_mileage.text.trim()),
        pricePerDay: int.parse(_price.text.trim()),
        securityDeposit: int.parse(_deposit.text.trim()),
        description: _blank(_desc.text),
      );
      if (_isEdit) {
        await VehicleService.update(widget.vehicleId!, input);
      } else {
        await VehicleService.create(input);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'Đã cập nhật xe' : 'Đăng xe thành công')));
      context.pop();
    } catch (e) {
      setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa thông tin xe' : 'Đăng xe mới')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (!_ready) {
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
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField<int>(
            value: _brandId,
            decoration: const InputDecoration(labelText: 'Hãng xe', prefixIcon: Icon(Icons.directions_car_outlined)),
            items: _brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
            onChanged: (v) => setState(() => _brandId = v),
            validator: (v) => v == null ? 'Vui lòng chọn hãng xe' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            value: _categoryId,
            decoration: const InputDecoration(labelText: 'Loại xe', prefixIcon: Icon(Icons.category_outlined)),
            items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _categoryId = v),
            validator: (v) => v == null ? 'Vui lòng chọn loại xe' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _model,
            decoration: const InputDecoration(labelText: 'Dòng xe (Vios, CX-5...)'),
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Vui lòng nhập tên dòng xe';
              return s.length > 100 ? 'Tối đa 100 ký tự' : null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _plate,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Biển số', hintText: '51K-123.45'),
            validator: (v) => RegExp(r'^\d{2}[A-Za-z]{1,2}\d?-\d{3}\.\d{2}$').hasMatch((v ?? '').trim()) ? null : 'Biển số dạng 51K-123.45',
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _color,
            decoration: const InputDecoration(labelText: 'Màu xe'),
            validator: (v) => (v ?? '').length > 30 ? 'Tối đa 30 ký tự' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _transmission,
            decoration: const InputDecoration(labelText: 'Hộp số'),
            items: const [
              DropdownMenuItem(value: 'AUTO', child: Text('Số tự động')),
              DropdownMenuItem(value: 'MANUAL', child: Text('Số sàn')),
            ],
            onChanged: (v) => setState(() => _transmission = v!),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _fuel,
            decoration: const InputDecoration(labelText: 'Nhiên liệu'),
            items: const [
              DropdownMenuItem(value: 'GASOLINE', child: Text('Xăng')),
              DropdownMenuItem(value: 'DIESEL', child: Text('Dầu')),
              DropdownMenuItem(value: 'ELECTRIC', child: Text('Điện')),
              DropdownMenuItem(value: 'HYBRID', child: Text('Hybrid')),
            ],
            onChanged: (v) => setState(() => _fuel = v!),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _numField(_seats, 'Số chỗ', (n) => (n < 1 || n > 16) ? 'Từ 1 đến 16' : null)),
            const SizedBox(width: 12),
            Expanded(child: _numField(_year, 'Năm sản xuất', (n) => (n < 1990 || n > 2100) ? 'Năm không hợp lệ' : null)),
          ]),
          const SizedBox(height: 14),
          _numField(_mileage, 'Số km đã đi', (n) => null),
          const SizedBox(height: 14),
          _numField(_price, 'Giá thuê / ngày (đ)', (n) => n < 50000 ? 'Tối thiểu 50.000đ' : null),
          const SizedBox(height: 14),
          _numField(_deposit, 'Tiền cọc (đ)', (n) => null),
          const SizedBox(height: 14),
          TextFormField(
            controller: _desc,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Mô tả', alignLabelWithHint: true),
            validator: (v) => (v ?? '').length > 2000 ? 'Tối đa 2000 ký tự' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_isEdit ? 'Lưu thay đổi' : 'Đăng xe'),
          ),
        ],
      ),
    );
  }

  /// Ô nhập số nguyên: chỉ cho gõ chữ số, mỗi ô tự truyền thêm luật kiểm tra riêng.
  Widget _numField(TextEditingController c, String label, String? Function(int) check) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final n = int.tryParse((v ?? '').trim());
        if (n == null) return 'Vui lòng nhập số';
        return check(n);
      },
    );
  }
}