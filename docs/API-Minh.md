# API phần Minh (Back-end)

Base URL: `http://localhost:8080` · Swagger: `http://localhost:8080/swagger-ui.html`
Mọi response: `{ "success": true, "message": "...", "data": ..., "timestamp": "..." }`
Route cần đăng nhập: thêm header `Authorization: Bearer <accessToken>`.

Tài khoản mẫu (tự tạo lần chạy đầu, mật khẩu `123456`): `admin@vrs.local` (ADMIN), `owner@vrs.local`, `owner2@vrs.local`, `user@vrs.local`.

## Auth (công khai)
| Method | Path | Body |
|---|---|---|
| POST | /api/auth/register | `{"fullName","email","phone","password"}` |
| POST | /api/auth/login | `{"email","password"}` → `data.accessToken`, `data.refreshToken`, `data.user` |
| POST | /api/auth/refresh | `{"refreshToken"}` (xoay token: token cũ bị vô hiệu) |
| POST | /api/auth/logout | `{"refreshToken"}` |

## Hồ sơ & sổ địa chỉ (cần đăng nhập)
| Method | Path | Ghi chú |
|---|---|---|
| GET/PUT | /api/users/me | Xem / sửa hồ sơ |
| GET | /api/users/me/addresses | Danh sách địa chỉ |
| POST | /api/users/me/addresses | Thêm, trả về danh sách mới |
| PUT/DELETE | /api/users/me/addresses/{id} | Sửa / xóa, trả về danh sách mới |

## Danh mục (công khai)
GET /api/brands · GET /api/categories

## Xe của chủ xe (cần đăng nhập, chỉ xe của mình; ADMIN xem/đổi trạng thái/bảo dưỡng được mọi xe)
| Method | Path | Ghi chú |
|---|---|---|
| GET | /api/owner/vehicles | Xe của tôi |
| POST | /api/owner/vehicles | Đăng xe (body bên dưới) |
| GET/PUT | /api/owner/vehicles/{id} | Chi tiết / sửa thông tin |
| PATCH | /api/owner/vehicles/{id}/status | `{"status":"ACTIVE|INACTIVE|MAINTENANCE"}` (ACTIVE cần ≥1 ảnh) |
| POST | /api/owner/vehicles/{id}/images | `{"imageUrl"}` (tối đa 10) |
| DELETE | /api/owner/vehicles/{id}/images/{imageId} | |
| PATCH | /api/owner/vehicles/{id}/images/{imageId}/primary | Đặt ảnh bìa |
| PUT | /api/owner/vehicles/{id}/features | `{"features":["Bluetooth","Camera lùi"]}` |
| PUT | /api/owner/vehicles/{id}/location | `{"latitude":10.77,"longitude":106.70}` |
| GET/POST | /api/owner/vehicles/{id}/maintenance | `{"maintenanceType","description","cost","performedDate":"2026-10-01","nextDueDate":"2027-01-01"}` |
| DELETE | /api/owner/vehicles/{id}/maintenance/{recordId} | |

Body đăng xe:
```json
{
  "vehicle": {
    "brandId": 1, "categoryId": 1, "model": "Vios", "licensePlate": "51K-123.99",
    "color": "Trắng", "transmission": "AUTO", "fuelType": "GASOLINE",
    "seats": 5, "year": 2022, "mileage": 25000,
    "pricePerDay": 600000, "securityDeposit": 3000000, "description": "..."
  },
  "imageUrls": ["https://placehold.co/800x500"],
  "features": ["Bluetooth"],
  "location": { "latitude": 10.77, "longitude": 106.70 }
}
```
Biển số trùng → 409. Xe người khác → 403. Chưa đăng nhập → 401.

## Admin
GET /api/admin/audit-logs?entityType=vehicle&action=VEHICLE_CREATE&page=0&size=20 (chỉ ADMIN)

## Ghi chú cho cả nhóm
- `entity/` và `repository/` là package dùng chung: Mẫn/Hiển cần bảng nào thêm entity + repository vào đó.
- Muốn ghi audit: inject `AuditService` rồi `audit.log("ACTION", "entityType", id, oldMap, newMap)`.
- Lấy user đang đăng nhập: `SecurityUtils.current()` (id, email, role).
- JWT + SecurityConfig đã xong (trùng với task bảo mật của Hiển, Hiển khỏi làm lại).
