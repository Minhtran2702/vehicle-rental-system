import type { Address, AuditLog, MyReview, OwnerVehicle, PendingReview, Profile } from '../types/minh'

const img = (n: number) => `https://picsum.photos/seed/own${n}/640/400`

export const ALL_FEATURES = [
  'Điều hòa', 'Bluetooth', 'Camera lùi', 'Cảm biến va chạm', 'GPS / Bản đồ', 'Ghế da', 'Cửa sổ trời',
  'Cổng USB', 'Camera hành trình', 'Lốp dự phòng', 'ETC (thu phí tự động)', 'Màn hình giải trí',
]

export const BRANDS = ['Toyota', 'Honda', 'Mazda', 'Hyundai', 'Kia', 'VinFast', 'Ford', 'Mercedes-Benz', 'BMW', 'Tesla', 'Yamaha', 'Suzuki']
export const CATEGORIES = ['Sedan', 'SUV', 'Hatchback', 'MPV', 'Pickup', 'Luxury', 'Electric', 'Motorbike']

export const seedProfile: Profile = {
  fullName: 'Trần Nhựt Minh',
  email: 'owner@vrs.local',
  phone: '0901234567',
  dob: '2003-02-27',
  gender: 'MALE',
  bio: 'Chủ xe nhiệt tình, xe luôn sạch sẽ, giao nhận linh hoạt khu vực TP.HCM.',
  avatarUrl: 'https://i.pravatar.cc/200?img=12',
}

export const seedAddresses: Address[] = [
  { id: 1, label: 'Nhà', receiver: 'Trần Nhựt Minh', phone: '0901234567', line: '12 Nguyễn Văn Linh', district: 'Quận 7', city: 'TP. Hồ Chí Minh', isDefault: true },
  { id: 2, label: 'Công ty', receiver: 'Trần Nhựt Minh', phone: '0901234567', line: '45 Lê Lợi', district: 'Quận 1', city: 'TP. Hồ Chí Minh', isDefault: false },
]

export const seedVehicles: OwnerVehicle[] = [
  {
    id: 101, name: 'Toyota Vios 2022', brand: 'Toyota', category: 'Sedan', plate: '51K-123.45', year: 2022, seats: 5,
    transmission: 'AUTO', fuel: 'GASOLINE', pricePerDay: 700000, deposit: 3000000,
    description: 'Xe gia đình đời 2022, nội thất sạch, tiết kiệm xăng, phù hợp đi phố và đi tỉnh.',
    status: 'ACTIVE',
    images: [{ id: 1, url: img(1), isPrimary: true }, { id: 2, url: img(2), isPrimary: false }, { id: 3, url: img(3), isPrimary: false }],
    features: ['Điều hòa', 'Bluetooth', 'Camera lùi', 'Cổng USB', 'GPS / Bản đồ'],
    location: { address: '12 Nguyễn Văn Linh, Quận 7', city: 'TP. Hồ Chí Minh', lat: 10.7292, lng: 106.7215, pickupNote: 'Nhận xe tại bãi gửi tầng hầm B1, gọi trước 15 phút.' },
    maintenance: [
      { id: 1, date: '2026-08-10', type: 'Thay dầu nhớt', cost: 650000, odometer: 28500, note: 'Thay dầu + lọc dầu tại hãng.' },
      { id: 2, date: '2026-05-02', type: 'Kiểm tra phanh', cost: 400000, odometer: 22000, note: 'Thay má phanh trước.' },
    ],
  },
  {
    id: 102, name: 'Mazda CX-5 2021', brand: 'Mazda', category: 'SUV', plate: '51H-678.90', year: 2021, seats: 5,
    transmission: 'AUTO', fuel: 'GASOLINE', pricePerDay: 1100000, deposit: 5000000,
    description: 'SUV rộng rãi, cửa sổ trời, ghế da, êm ái cho chuyến đi xa.',
    status: 'MAINTENANCE',
    images: [{ id: 4, url: img(4), isPrimary: true }, { id: 5, url: img(5), isPrimary: false }],
    features: ['Điều hòa', 'Ghế da', 'Cửa sổ trời', 'Camera hành trình', 'Cảm biến va chạm'],
    location: { address: '45 Lê Lợi, Quận 1', city: 'TP. Hồ Chí Minh', lat: 10.7745, lng: 106.7003, pickupNote: 'Giao xe tận nơi trong nội thành (phụ thu 100.000đ).' },
    maintenance: [{ id: 3, date: '2026-10-20', type: 'Bảo dưỡng 40.000 km', cost: 2300000, odometer: 40120, note: 'Đang bảo dưỡng, dự kiến xong 30/10.' }],
  },
  {
    id: 103, name: 'Honda SH 150i', brand: 'Honda', category: 'Motorbike', plate: '59X1-234.56', year: 2023, seats: 2,
    transmission: 'AUTO', fuel: 'GASOLINE', pricePerDay: 250000, deposit: 2000000,
    description: 'Xe tay ga cao cấp, đi phố gọn nhẹ, tặng 2 nón bảo hiểm.',
    status: 'INACTIVE',
    images: [{ id: 6, url: img(6), isPrimary: true }],
    features: ['Cổng USB', 'Lốp dự phòng'],
    location: { address: '30 Hai Bà Trưng, Quận 3', city: 'TP. Hồ Chí Minh', lat: 10.7822, lng: 106.6991, pickupNote: 'Nhận xe tại cửa hàng 8h – 20h.' },
    maintenance: [],
  },
]

export const seedPending: PendingReview[] = [
  { bookingId: 5001, vehicleName: 'Kia Carnival 2023', imageUrl: img(11), from: '2026-10-10', to: '2026-10-13' },
  { bookingId: 5002, vehicleName: 'VinFast VF e34', imageUrl: img(12), from: '2026-09-28', to: '2026-09-30' },
]

export const seedMyReviews: MyReview[] = [
  { id: 1, vehicleName: 'Toyota Innova 2020', rating: 5, comment: 'Xe sạch, chủ xe thân thiện, giao nhận đúng giờ. Sẽ thuê lại!', createdAt: '2026-08-15' },
  { id: 2, vehicleName: 'Hyundai Accent 2021', rating: 4, comment: 'Xe ổn, chỉ hơi hao xăng một chút so với mô tả.', createdAt: '2026-07-02' },
]

export const seedAudit: AuditLog[] = [
  { id: 9001, time: '2026-10-26 09:12:03', actor: 'admin@vrs.local', action: 'VEHICLE_STATUS_CHANGE', entity: 'vehicle', entityId: 102, ip: '10.0.0.5', before: { status: 'ACTIVE' }, after: { status: 'MAINTENANCE' } },
  { id: 9002, time: '2026-10-26 08:47:40', actor: 'admin@vrs.local', action: 'USER_LOCK', entity: 'user', entityId: 17, ip: '10.0.0.5', before: { active: true }, after: { active: false } },
  { id: 9003, time: '2026-10-25 21:30:11', actor: 'owner@vrs.local', action: 'BOOKING_CONFIRM', entity: 'booking', entityId: 5003, ip: '113.161.22.9', before: { status: 'PENDING' }, after: { status: 'CONFIRMED' } },
  { id: 9004, time: '2026-10-25 17:02:55', actor: 'user@vrs.local', action: 'PAYMENT_CREATE', entity: 'payment', entityId: 7002, ip: '27.74.10.8', before: null, after: { amount: 2100000, method: 'MOMO' } },
  { id: 9005, time: '2026-10-24 10:15:00', actor: 'admin@vrs.local', action: 'COUPON_UPDATE', entity: 'coupon', entityId: 3, ip: '10.0.0.5', before: { discountValue: 100000 }, after: { discountValue: 150000 } },
  { id: 9006, time: '2026-10-23 14:20:32', actor: 'owner@vrs.local', action: 'VEHICLE_UPDATE_PRICE', entity: 'vehicle', entityId: 101, ip: '113.161.22.9', before: { pricePerDay: 650000 }, after: { pricePerDay: 700000 } },
]
