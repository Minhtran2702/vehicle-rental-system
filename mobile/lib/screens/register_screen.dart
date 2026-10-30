import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../auth/phone_otp.dart';
import '../core/api_client.dart';
import '../core/theme.dart';

/// Đăng ký 2 bước: (1) nhập thông tin → (2) nhập mã OTP gửi về số điện thoại.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _otpForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _otp = TextEditingController();

  int _step = 0; // 0 = nhập thông tin, 1 = nhập mã OTP
  bool _loading = false;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _otp.dispose();
    super.dispose();
  }

  // Bước 1: kiểm tra form rồi gửi mã OTP
  Future<void> _sendOtp() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await PhoneOtp.send(_phone.text.trim());
      if (!mounted) return;
      setState(() => _step = 1);
    } catch (e) {
      setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Bước 2: kiểm tra mã OTP, đúng thì mới tạo tài khoản
  Future<void> _verifyAndRegister() async {
    if (!_otpForm.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await PhoneOtp.verify(_otp.text.trim());
      if (!ok) throw Exception('Mã OTP không đúng');
      if (!mounted) return;
      await context.read<AuthProvider>().register(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công, hãy đăng nhập')));
      context.go('/login');
    } catch (e) {
      setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step == 0 ? _buildInfoStep() : _buildOtpStep(),
        ),
      ),
    );
  }

  Widget _buildInfoStep() {
    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined)),
            validator: (v) => RegExp(r'^0\d{9}$').hasMatch(v?.trim() ?? '') ? null : 'Số điện thoại gồm 10 số, bắt đầu bằng 0',
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: _hide,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _hide = !_hide)),
            ),
            validator: (v) {
              final p = v ?? '';
              if (p.length < 8 || p.length > 72) return 'Mật khẩu từ 8 đến 72 ký tự';
              if (!RegExp(r'[A-Za-z]').hasMatch(p) || !RegExp(r'\d').hasMatch(p)) return 'Mật khẩu phải có cả chữ và số';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirm,
            obscureText: _hide,
            decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu', prefixIcon: Icon(Icons.lock_outline)),
            validator: (v) => v != _password.text ? 'Mật khẩu nhập lại không khớp' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _sendOtp,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Gửi mã xác thực'),
          ),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Đã có tài khoản? Đăng nhập')),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return Form(
      key: _otpForm,
      child: Column(
        children: [
          const Icon(Icons.sms_outlined, size: 56, color: AppColors.brand),
          const SizedBox(height: 12),
          Text('Mã xác thực đã gửi tới ${_phone.text.trim()}', textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text('Demo: nhập 123456', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: const InputDecoration(counterText: ''),
            validator: (v) => (v == null || v.trim().length != 6) ? 'Nhập mã gồm 6 số' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _verifyAndRegister,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Xác nhận và đăng ký'),
          ),
          TextButton(
            onPressed: _loading ? null : () => setState(() { _step = 0; _error = null; _otp.clear(); }),
            child: const Text('Quay lại sửa thông tin'),
          ),
        ],
      ),
    );
  }
}