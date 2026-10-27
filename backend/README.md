# BE nền — Vehicle Rental System

Phạm vi gói này chỉ là **khung backend nền** theo CV25 của Minh. Không triển khai nghiệp vụ riêng của Account, Vehicle, Booking, Payment, Review, AI hoặc Admin; các thành viên sẽ tự tạo entity/repository/service/controller và test cho module của mình.

## Công nghệ
- Java 21
- Spring Boot 3.3.5, Maven
- PostgreSQL 16
- Spring Data JPA; Flyway migration
- Spring Security (khung ban đầu)
- Jakarta Validation
- Swagger UI / OpenAPI

## Thành phần đã có
- `VehicleRentalApplication`: điểm khởi chạy Spring Boot.
- `common/ApiResponse.java`: định dạng response thống nhất.
- `common/PageResponse.java`: response phân trang (page bắt đầu từ 0).
- `common/AppException.java`: exception nghiệp vụ theo HTTP status.
- `common/GlobalExceptionHandler.java`: xử lý lỗi chung.
- `common/HealthController.java`: `GET /api/health`.
- `config/OpenApiConfig.java`: cấu hình Swagger.
- `config/SecurityConfig.java`: CORS, stateless session, PasswordEncoder và khung Spring Security.
- `db/migration/V1__schema.sql`: schema 21 bảng.
- `db/migration/V2__reference_data.sql`: dữ liệu tham chiếu ban đầu.
- package rỗng cho các module để nhóm tự phát triển.

## Chạy local
Yêu cầu: Java 21, Maven 3.9+, Docker Desktop.

1. Ở thư mục gốc `vehicle-rental-system`, tạo file `.env` từ `.env.example`.
2. Chạy PostgreSQL:

   ```bash
   docker compose up -d db
   ```

3. Chạy backend:

   ```bash
   cd backend
   mvn spring-boot:run
   ```

4. Kiểm tra:
   - Health: http://localhost:8080/api/health
   - Swagger UI: http://localhost:8080/swagger-ui.html

Flyway tự chạy `V1` và `V2` khi backend khởi động. Nếu muốn reset DB dùng dữ liệu local, lệnh `docker compose down -v` sẽ xóa volume dữ liệu PostgreSQL.

## Quy ước bắt buộc khi làm module
1. Package theo module, không tạo tất cả class vào `common`.
2. Mỗi module tự sở hữu `controller`, `service`, `repository`, `entity`, `dto` và test khi cần.
3. Controller nhận/trả DTO, không trả trực tiếp entity JPA.
4. Dùng `ApiResponse.ok(data)` cho kết quả thành công; lỗi nghiệp vụ ném `AppException`; không tự tạo format lỗi riêng.
5. Danh sách phân trang dùng `PageResponse.of(page)`.
6. Validate input bằng Jakarta Validation (`@Valid`, `@NotNull`, `@Size`, ...).
7. Không sửa `V1__schema.sql` sau khi đã chạy ở máy thành viên. Thay đổi schema thì tạo migration mới `V3__...sql` và báo nhóm.
8. Không commit `.env`, Firebase service-account, `google-services.json`, thông tin bí mật hoặc dữ liệu cá nhân thật.
9. Tên branch: `feature/<module>-<task>`; merge vào `develop` qua Pull Request. Chỉ merge `main` khi bản tích hợp ổn định.
10. API dùng prefix `/api`; đặt tên endpoint dạng danh từ số nhiều, ví dụ `/api/vehicles`.

## Cấu trúc module gợi ý
```text
com.vehiclerental
├── common/       # thành phần dùng chung, không chứa nghiệp vụ module
├── config/       # cấu hình ứng dụng
├── auth/         # để thành viên phụ trách tự triển khai
├── user/
├── vehicle/
├── booking/
├── payment/
├── review/
├── notification/
├── admin/
├── ai/
└── storage/
```

Ví dụ một module tự tạo:
```text
vehicle/
├── controller/
├── service/
├── repository/
├── entity/
├── dto/
└── mapper/       # tùy chọn nếu module cần
```

## Lưu ý bảo mật hiện tại
`SecurityConfig` đang ở **chế độ khung phát triển** và cho phép request đi qua để nhóm dựng API. Chưa có JWT authentication filter và chưa có phân quyền nghiệp vụ hoàn chỉnh. Không triển khai công khai hoặc dùng dữ liệu thật trước khi hoàn thành xác thực, phân quyền, kiểm tra quyền sở hữu tài nguyên và rà soát cấu hình secrets.
