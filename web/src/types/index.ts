// Khớp với backend: ApiResponse<T> và PageResponse<T>
export interface ApiResponse<T> {
  success: boolean
  message: string
  data: T
  timestamp: string
}

export interface PageResponse<T> {
  items: T[]
  page: number
  size: number
  totalItems: number
  totalPages: number
}

export type Role = 'CUSTOMER' | 'ADMIN'

export interface AuthUser {
  id: number
  email: string
  fullName: string
  role: Role
  avatarUrl?: string | null
}

export interface TokenPair {
  accessToken: string
  refreshToken: string
}

// Xe (rút gọn, đủ cho thẻ xe; mỗi người mở rộng thêm khi làm chức năng của mình)
export interface VehicleSummary {
  id: number
  name: string
  brand: string
  category: string
  seats: number
  pricePerDay: number
  city: string
  rating: number
  reviewCount: number
  imageUrl: string
}
