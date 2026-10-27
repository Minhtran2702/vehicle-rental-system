import type { AuthUser, VehicleSummary } from '../types'

// Dữ liệu giả dùng chung. Mỗi người thêm dữ liệu giả của chức năng mình vào file riêng trong thư mục mocks.
export const mockUsers: (AuthUser & { password: string })[] = [
  { id: 1, email: 'admin@vrs.local', fullName: 'Quản trị viên', role: 'ADMIN', password: '123456' },
  { id: 2, email: 'owner@vrs.local', fullName: 'Nguyễn Chủ Xe', role: 'CUSTOMER', password: '123456' },
  { id: 3, email: 'user@vrs.local', fullName: 'Trần Khách Thuê', role: 'CUSTOMER', password: '123456' },
]

const img = (n: number) => `https://picsum.photos/seed/vrs${n}/640/400`

export const mockVehicles: VehicleSummary[] = [
  { id: 1, name: 'Toyota Vios 2022', brand: 'Toyota', category: 'Sedan', seats: 5, pricePerDay: 700000, city: 'TP. Hồ Chí Minh', rating: 4.8, reviewCount: 32, imageUrl: img(1) },
  { id: 2, name: 'Mazda CX-5 2021', brand: 'Mazda', category: 'SUV', seats: 5, pricePerDay: 1100000, city: 'Hà Nội', rating: 4.7, reviewCount: 21, imageUrl: img(2) },
  { id: 3, name: 'VinFast VF e34', brand: 'VinFast', category: 'Electric', seats: 5, pricePerDay: 1000000, city: 'Đà Nẵng', rating: 4.6, reviewCount: 14, imageUrl: img(3) },
  { id: 4, name: 'Kia Carnival 2023', brand: 'Kia', category: 'MPV', seats: 7, pricePerDay: 1600000, city: 'TP. Hồ Chí Minh', rating: 4.9, reviewCount: 18, imageUrl: img(4) },
  { id: 5, name: 'Honda SH 150i', brand: 'Honda', category: 'Motorbike', seats: 2, pricePerDay: 250000, city: 'Đà Nẵng', rating: 4.5, reviewCount: 40, imageUrl: img(5) },
  { id: 6, name: 'Mercedes C300', brand: 'Mercedes-Benz', category: 'Luxury', seats: 5, pricePerDay: 2500000, city: 'Hà Nội', rating: 4.9, reviewCount: 9, imageUrl: img(6) },
]
