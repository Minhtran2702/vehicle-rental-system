# Vehicle Rental System

Hệ thống thuê xe gồm 3 phần: **backend** (Spring Boot), **web** (React), **mobile** (Flutter).

## 1. Cài sẵn trên máy
- JDK 21, Apache NetBeans (hoặc IDE mở được Maven)
- PostgreSQL + pgAdmin
- Node.js 18 trở lên + VS Code
- Flutter SDK + Android Studio (có máy ảo Android)

## 2. Tải code
```
git clone https://github.com/Minhtran2702/vehicle-rental-system.git
```

## 3. Database (làm 1 lần)
Mở pgAdmin, tạo database rỗng tên `vehicle_rental`. Bảng và dữ liệu mẫu **tự tạo** khi chạy backend.

Backend mặc định dùng user `vrs`, mật khẩu `vrs_password`. Có 2 cách:
- Tạo user đó: chạy trong Query Tool
  ```sql
  CREATE USER vrs WITH PASSWORD 'vrs_password';
  ALTER DATABASE vehicle_rental OWNER TO vrs;
  ```
- Hoặc dùng user `postgres` của bạn: tạo file `backend/application-local.yml` (Git bỏ qua file này)
  ```yaml
  spring:
    datasource:
      username: postgres
      password: "mat-khau-cua-ban"
  ```

## 4. Chạy backend
Mở thư mục `backend` bằng NetBeans → bấm **Run**.
Thấy dòng `Started VehicleRentalApplication` là xong. API: http://localhost:8080/swagger-ui.html

Tài khoản mẫu (mật khẩu `123456`): `admin@vrs.local`, `owner@vrs.local`, `owner2@vrs.local`, `user@vrs.local`

## 5. Chạy web
```
cd web
npm install
npm run dev
```
Mở http://localhost:5173. Mặc định chạy bằng dữ liệu giả. Muốn gọi backend thật: sửa `web/.env.development` thành `VITE_USE_MOCKS=false`.

## 6. Chạy mobile
Mở thư mục `mobile` bằng Android Studio → **Pub get** → bật máy ảo → chọn máy ảo ở thanh trên → **Run**.
Mặc định chạy bằng dữ liệu giả. Muốn gọi backend thật:
```
flutter run --dart-define=USE_MOCKS=false
```
(Máy ảo Android gọi máy tính qua `10.0.2.2`, đã cấu hình sẵn.)

## Thư mục
`backend/` · `web/` · `mobile/` · `docs/` · `postman/`
Danh sách API: `docs/API-Minh.md`
