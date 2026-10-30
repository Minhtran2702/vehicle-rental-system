import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../user/profile_models.dart';
import '../user/profile_service.dart';

/// Ô nhập để trống thì gửi null lên Back-end (không gửi chuỗi rỗng).
String? _blank(String s) => s.trim().isEmpty ? null : s.trim();

/// Xem và sửa hồ sơ cá nhân.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController(); // dạng 2000-12-31
  final _bio = TextEditingController();
  final _idCard = TextEditingController();
  final _license = TextEditingController();

  Profile? _profile;
  String? _gender;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _dob.dispose();
    _bio.dispose();
    _idCard.dispose();
    _license.dispose();
    super.dispose();
  }

  // Tải hồ sơ rồi đổ vào các ô nhập
  Future<void> _load() async {
    try {
      final u = context.read<AuthProvider>().user!;
      final p = await ProfileService.getProfile(u);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _name.text = p.fullName;
        _phone.text = p.phone ?? '';
        _dob.text = p.dateOfBirth ?? '';
        _bio.text = p.bio ?? '';
        _idCard.text = p.idCardNumber ?? '';
        _license.text = p.driverLicenseNumber ?? '';
        _gender = p.gender;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = errorMessage(e); _loading = false; });
    }
  }

  // Mở hộp chọn ngày sinh
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dob.text) ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now.subtract(const Duration(days: 1)),
    );
    if (d != null) setState(() => _dob.text = d.toIso8601String().substring(0, 10));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final p = _profile!;
      final updated = await ProfileService.updateProfile(Profile(
        id: p.id,
        email: p.email,
        fullName: _name.text.trim(),
        phone: _blank(_phone.text),
        avatarUrl: p.avatarUrl,
        dateOfBirth: _blank(_dob.text),
        gender: _gender,
        bio: _blank(_bio.text),
        idCardNumber: _blank(_idCard.text),
        driverLicenseNumber: _blank(_license.text),
      ));
      if (!mounted) return;
      await context.read<AuthProvider>().updateName(updated.fullName);
      if (!mounted) return;
      setState(() => _profile = updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ')));
    } catch (e) {
      setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ của tôi')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_profile == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Không tải được hồ sơ', style: const TextStyle(color: AppColors.danger)),
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
          const Center(
            child: CircleAvatar(radius: 40, backgroundColor: AppColors.brandSoft, child: Icon(Icons.person, size: 44, color: AppColors.brand)),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _profile!.email,
            enabled: false,
            decoration: const InputDecoration(labelText: 'Email (không đổi được)', prefixIcon: Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined)),
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return null; // được để trống
              return RegExp(r'^0\d{9}$').hasMatch(s) ? null : 'Số điện thoại gồm 10 số, bắt đầu bằng 0';
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _dob,
            readOnly: true,
            onTap: _pickDob,
            decoration: const InputDecoration(labelText: 'Ngày sinh', prefixIcon: Icon(Icons.cake_outlined), suffixIcon: Icon(Icons.calendar_today)),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Giới tính', prefixIcon: Icon(Icons.wc)),
            items: const [
              DropdownMenuItem(value: 'MALE', child: Text('Nam')),
              DropdownMenuItem(value: 'FEMALE', child: Text('Nữ')),
              DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _idCard,
            decoration: const InputDecoration(labelText: 'Số CCCD', prefixIcon: Icon(Icons.badge_outlined)),
            validator: (v) => (v ?? '').length > 30 ? 'Tối đa 30 ký tự' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _license,
            decoration: const InputDecoration(labelText: 'Số giấy phép lái xe', prefixIcon: Icon(Icons.credit_card)),
            validator: (v) => (v ?? '').length > 30 ? 'Tối đa 30 ký tự' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bio,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Giới thiệu bản thân', alignLabelWithHint: true),
            validator: (v) => (v ?? '').length > 1000 ? 'Tối đa 1000 ký tự' : null,
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
                : const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }
}