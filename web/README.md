# Web (React + Vite + TypeScript + Tailwind)

## Chạy
```bash
cd web
npm install

npm run dev                        # http://localhost:5173
```
Mặc định chạy bằng dữ liệu giả (file `.env.development`, không cần Back-end). Đổi `VITE_USE_MOCKS=false` rồi **tắt và chạy lại `npm run dev`** khi muốn nối API thật. Lỗi "Network Error" nghĩa là đang gọi API thật mà Back-end chưa bật.
Tài khoản giả: `user@vrs.local`, `owner@vrs.local`, `admin@vrs.local` – mật khẩu `123456`.

## Cấu trúc
```
src/api/client.ts      axios gắn JWT, tự làm mới token khi 401, USE_MOCKS, errorMessage, delay
src/auth/              AuthContext (login/logout/hasRole), RequireAuth (chặn route theo vai trò)
src/components/        Button, Input, Badge, Modal, Pagination, DataTable, CarCard, Spinner
src/layouts/           MainLayout (Khách + Người dùng), AdminLayout (Admin)
src/mocks/             Dữ liệu giả
src/pages/             Các trang
src/routes/index.tsx   Danh sách route (Khách / Người dùng / Admin)
src/types/             Kiểu dữ liệu dùng chung (khớp ApiResponse / PageResponse của backend)
```

## Trang đã có sẵn (phần của Minh, dữ liệu giả)
`/register`, `/profile` (hồ sơ + sổ địa chỉ), `/my-vehicles` (danh sách xe của tôi), `/my-vehicles/new` (đăng xe 4 bước), `/my-vehicles/:id` (sửa thông tin, ảnh, tiện ích, vị trí, bảo dưỡng), `/reviews` (đánh giá), `/admin/audit` (nhật ký audit, đăng nhập bằng admin@vrs.local).

## Cách thêm một trang
1. Tạo file trang trong `src/pages/` (dùng lại component trong `src/components`).
2. Thêm 1 dòng route vào `src/routes/index.tsx` đúng nhóm: Khách / Người dùng / Admin.
3. Hàm gọi API đặt trong `src/api/`: nếu `USE_MOCKS` thì trả dữ liệu giả (sau `await delay()`), ngược lại gọi `api.get('/api/...')`.
4. Khi Back-end xong thì đặt `VITE_USE_MOCKS=false` để chạy thật.

## Quy ước
- Đường dẫn API luôn bắt đầu bằng `/api`. Phản hồi bọc `ApiResponse<T>`; danh sách bọc `PageResponse<T>` (page bắt đầu từ 0).
- Style dùng Tailwind, màu chủ đạo `brand-*`. Thiếu component thì thêm vào `src/components`.
