# Vehicle Rental System

Nền tảng cho thuê xe trực tuyến: **Back-end** (Spring Boot) + **Web** (React) + **App** (Flutter) + **CSDL** (PostgreSQL).
Nhóm: Trần Nhựt Minh, Hoàng Mẫn Đạt, Dương Hiển Đạt.

## Cấu trúc thư mục
```
backend/   Spring Boot 3 + Java 21 (package theo module: auth, user, vehicle, booking, payment, review, notification, admin, ai, storage)
web/       React + Vite + TypeScript + Tailwind        (khung do Minh dựng, xem web/README.md; mỗi người tự thêm trang)
mobile/    Flutter                                     (khung do Minh dựng, xem mobile/README.md)
postman/   Postman collection + environment
docs/      Tài liệu, sơ đồ, báo cáo
docker-compose.yml   PostgreSQL 16 chạy 1 lệnh
```

## Chạy dự án trên máy
Cần: Java 21, Maven 3.9+, Docker Desktop (cho PostgreSQL).

```bash
git clone <URL-repo>
cd vehicle-rental-system
cp .env.example .env              # Windows: copy .env.example .env
docker compose up -d db           # bật PostgreSQL
cd backend
mvn spring-boot:run               # Flyway tự tạo 21 bảng + dữ liệu tham chiếu
```
Kiểm tra: mở http://localhost:8080/api/health (phải trả `UP`) và Swagger UI http://localhost:8080/swagger-ui.html.

Reset CSDL sạch: `docker compose down -v && docker compose up -d db`.

## Quy ước làm việc nhóm
- Nhánh: `main` (bản ổn định, chỉ Minh gộp) ← `develop` (gộp hằng ngày) ← `feature/<module>-<việc>` ví dụ `feature/booking-quote`.
- **Ai làm giao diện (Web + App) của chức năng nào thì làm luôn Back-end (API) của chức năng đó.** Không tách riêng người làm FE, người làm BE.
- Mỗi người chỉ code trong module của mình; muốn sửa module người khác thì nhắn người đó.
- Commit: `feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...` (viết tiếng Việt hoặc Anh đều được, ngắn gọn).
- Trước khi tạo Pull Request: `git pull origin develop`, chạy được `mvn test`, chạy thử API bằng Postman.
- Không commit: file `.env`, khoá Firebase (`*service-account.json`, `google-services.json`), thư mục `uploads/`.
- Thay đổi CSDL: **không sửa** `V1__schema.sql`. Tạo file mới `V3__mo_ta.sql`, `V4__...` (Flyway chạy theo số thứ tự). Báo cả nhóm trước khi thêm.

## Cách thêm một module mới (ví dụ `vehicle`)
```
backend/src/main/java/com/vehiclerental/vehicle/
    controller/VehicleController.java      @RestController, đường dẫn /api/vehicles
    service/VehicleService.java            nghiệp vụ, ném AppException khi lỗi
    repository/VehicleRepository.java      Spring Data JPA
    entity/Vehicle.java                    khớp bảng vehicles trong V1__schema.sql
    dto/...                                request / response
```
- Trả về luôn bọc `ApiResponse.ok(data)`; danh sách phân trang dùng `PageResponse.of(page)`.
- Lỗi nghiệp vụ: `throw AppException.notFound("Không tìm thấy xe")` – đã có sẵn bộ bắt lỗi chung.

## CSDL
21 bảng: roles, users, refresh_tokens, user_profiles, addresses, brands, categories, vehicles, vehicle_images,
vehicle_features, vehicle_locations, maintenance_records, coupons, bookings, booking_status_history,
payment_methods, payments, reviews, favorites, notifications, audit_logs.
Dữ liệu tham chiếu có sẵn (V2): 2 vai trò, 12 hãng, 8 loại xe, 5 phương thức thanh toán, 3 mã coupon.

## Trạng thái khung
| Phần | Trạng thái |
|---|---|
| Back-end + CSDL | Khung xong; Security đang cho phép mọi request (việc `sec_core` sẽ siết lại) |
| Web React | Khung xong + các trang phần Minh (dữ liệu giả); Hiển và Mẫn thêm trang của mình |
| App Flutter | Khung xong (chạy bằng dữ liệu giả, xem mobile/README.md) |

## Back-end: chạy và test
1. Mở `backend` bằng NetBeans (Open Project → Maven), đảm bảo PostgreSQL đang chạy và có database `vehicle_rental` (user `vrs`, pass `vrs_password`, hoặc tạo `backend/application-local.yml`, xem mục dưới).
2. Run project → lần đầu Flyway tạo bảng và `DataInitializer` tạo tài khoản + xe mẫu (mật khẩu `123456`).
3. Test bằng Postman: xem `docs/API-Minh.md` và `postman/`. Swagger: http://localhost:8080/swagger-ui.html

### Cấu hình database riêng của máy bạn
Mặc định BE kết nối `localhost:5432`, database `vehicle_rental`, user `vrs`, mật khẩu `vrs_password`.
Nếu máy bạn dùng user/mật khẩu khác, tạo file `backend/application-local.yml` (Git đã bỏ qua file này):
```yaml
spring:
  datasource:
    username: postgres
    password: "mat-khau-cua-ban"
```
Cần tạo sẵn database rỗng `vehicle_rental`; lần chạy đầu Flyway tự tạo bảng và dữ liệu mẫu.
