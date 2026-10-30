import '../core/api_client.dart';

/// Gửi và kiểm tra mã OTP qua số điện thoại.
/// HIỆN TẠI: giả lập, mã đúng luôn là 123456.
/// SAU NÀY: thay phần ruột 2 hàm này bằng Firebase (verifyPhoneNumber), màn hình không phải sửa.
class PhoneOtp {
  /// Gửi mã về số điện thoại.
  static Future<void> send(String phone) async {
    await delay();
    // TODO(Firebase): gọi FirebaseAuth.instance.verifyPhoneNumber(...)
  }

  /// Trả về true nếu mã nhập đúng.
  static Future<bool> verify(String code) async {
    await delay();
    // TODO(Firebase): xác thực mã bằng PhoneAuthProvider.credential(...)
    return code == '123456';
  }
}