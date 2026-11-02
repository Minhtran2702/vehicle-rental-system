import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../user/profile_models.dart';
import '../user/profile_service.dart';

/// Sổ địa chỉ: xem, thêm, sửa, xoá địa chỉ.
class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  List<Address>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ProfileService.getAddresses();
      if (!mounted) return;
      setState(() { _items = list; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = errorMessage(e); _loading = false; });
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // Mở bảng nhập: truyền địa chỉ cũ vào thì là sửa, không truyền thì là thêm mới
  Future<void> _edit([Address? old]) async {
    final result = await showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddressForm(initial: old),
    );
    if (result == null || !mounted) return;
    try {
      final list = await ProfileService.saveAddress(result);
      if (!mounted) return;
      setState(() => _items = list);
      _toast(old == null ? 'Đã thêm địa chỉ' : 'Đã cập nhật địa chỉ');
    } catch (e) {
      if (mounted) _toast(errorMessage(e));
    }
  }

  Future<void> _delete(Address a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá địa chỉ?'),
        content: Text('Bạn muốn xoá địa chỉ "${a.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final list = await ProfileService.deleteAddress(a.id);
      if (!mounted) return;
      setState(() => _items = list);
      _toast('Đã xoá địa chỉ');
    } catch (e) {
      if (mounted) _toast(errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ địa chỉ')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(),
        child: const Icon(Icons.add),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Không tải được địa chỉ', style: const TextStyle(color: AppColors.danger)),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Thử lại'),
          ),
        ]),
      );
    }
    if (_items!.isEmpty) {
      return const Center(child: Text('Chưa có địa chỉ nào. Bấm + để thêm.', style: TextStyle(color: AppColors.muted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: _items!.length,
      itemBuilder: (_, i) {
        final a = _items![i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined, color: AppColors.brand),
            title: Row(children: [
              Flexible(child: Text(a.label, style: const TextStyle(fontWeight: FontWeight.w600))),
              if (a.defaultAddress) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Mặc định', style: TextStyle(fontSize: 11, color: AppColors.brand)),
                ),
              ],
            ]),
            subtitle: Text(a.fullText),
            trailing: PopupMenuButton<String>(
              onSelected: (v) => v == 'edit' ? _edit(a) : _delete(a),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Sửa')),
                PopupMenuItem(value: 'delete', child: Text('Xoá')),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bảng nhập địa chỉ (trượt từ dưới lên). Bấm Lưu thì trả về Address cho màn bên ngoài.
class _AddressForm extends StatefulWidget {
  final Address? initial;
  const _AddressForm({this.initial});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _form = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.initial?.label ?? '');
  late final _line = TextEditingController(text: widget.initial?.addressLine ?? '');
  late final _ward = TextEditingController(text: widget.initial?.ward ?? '');
  late final _district = TextEditingController(text: widget.initial?.district ?? '');
  late final _city = TextEditingController(text: widget.initial?.city ?? '');
  late final _country = TextEditingController(text: widget.initial?.country ?? 'Việt Nam');
  late bool _default = widget.initial?.defaultAddress ?? false;

  @override
  void dispose() {
    _label.dispose();
    _line.dispose();
    _ward.dispose();
    _district.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  String? _blank(String s) => s.trim().isEmpty ? null : s.trim();

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      Address(
        id: widget.initial?.id ?? 0, // giữ nguyên id khi sửa, 0 khi thêm mới
        label: _label.text.trim(),
        addressLine: _line.text.trim(),
        ward: _blank(_ward.text),
        district: _blank(_district.text),
        city: _city.text.trim(),
        country: _blank(_country.text),
        postalCode: widget.initial?.postalCode,
        defaultAddress: _default,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // chừa chỗ cho bàn phím để không che ô nhập
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.initial == null ? 'Thêm địa chỉ' : 'Sửa địa chỉ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _label,
              decoration: const InputDecoration(labelText: 'Tên gợi nhớ (Nhà, Công ty...)'),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Vui lòng nhập tên gợi nhớ';
                return s.length > 50 ? 'Tối đa 50 ký tự' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _line,
              decoration: const InputDecoration(labelText: 'Số nhà, đường'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số nhà, đường' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _ward, decoration: const InputDecoration(labelText: 'Phường / Xã')),
            const SizedBox(height: 12),
            TextFormField(controller: _district, decoration: const InputDecoration(labelText: 'Quận / Huyện')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'Tỉnh / Thành phố'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tỉnh / thành phố' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _country, decoration: const InputDecoration(labelText: 'Quốc gia')),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đặt làm địa chỉ mặc định'),
              value: _default,
              onChanged: (v) => setState(() => _default = v),
            ),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Lưu'))),
          ],
        ),
      ),
    );
  }
}