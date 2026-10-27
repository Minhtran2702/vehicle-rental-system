# App (Flutter)

## Chạy lần đầu
Cần Flutter SDK 3.24 trở lên, Android Studio với Android Emulator.

```bash
cd mobile
flutter create --project-name vehicle_rental_app --org com.vehiclerental --platforms=android,ios .
flutter pub get
```
`flutter create .` chỉ bổ sung thư mục `android/`, `ios/` còn thiếu, KHÔNG ghi đè `lib/` và `pubspec.yaml` đang có.

### Bắt buộc sửa 1 file để gọi được Back-end (http, không phải https)
Mở `android/app/src/main/AndroidManifest.xml`:
1. Ngay trên thẻ `<application`, thêm dòng: `<uses-permission android:name="android.permission.INTERNET" />`
2. Trong thẻ `<application`, thêm thuộc tính: `android:usesCleartextTraffic="true"`

Với `flutter_secure_storage`: mở `android/app/build.gradle` (hoặc `build.gradle.kts`) và đặt `minSdk = 23` (hoặc `minSdkVersion 23`).

### Chạy
Mở Android Emulator, rồi:
```bash
flutter run
```
Mặc định app chạy bằng **dữ liệu giả**, không cần bật Back-end. Tài khoản giả: `user@vrs.local`, `owner@vrs.local`, `admin@vrs.local` – mật khẩu `123456`.

Gọi Back-end thật (đã bật ở máy tính):
```bash
flutter run --dart-define=USE_MOCKS=false
```
- Android Emulator gọi máy tính qua **`10.0.2.2`** (đã đặt mặc định), KHÔNG dùng `localhost`.
- Điện thoại thật: `flutter run --dart-define=USE_MOCKS=false --dart-define=API_URL=http://192.168.1.10:8080` (IP máy tính trong cùng wifi).

## Cấu trúc
```
lib/core/       config (địa chỉ API, dùng dữ liệu giả), theme (màu navy), api_client (dio gắn JWT, tự làm mới token), token_store, models
lib/auth/       AuthProvider (đăng nhập, đăng xuất, vai trò)
lib/widgets/    CarCard, StatusBadge, StarRating, ComingSoon
lib/screens/    Các màn hình
lib/mocks/      Dữ liệu giả
lib/router.dart Danh sách màn hình (Khách / Người dùng / Admin) + thanh điều hướng dưới
```

## Cách thêm một màn hình
1. Tạo file trong `lib/screens/`.
2. Thêm 1 `GoRoute` vào `lib/router.dart` đúng nhóm (hoặc thay `ComingSoon(...)` của tab).
3. Gọi API qua `ApiClient.instance.dio`; nếu `AppConfig.useMocks` thì trả dữ liệu giả (sau `await delay()`).
