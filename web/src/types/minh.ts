// Kiểu dữ liệu cho các chức năng của Minh: hồ sơ, địa chỉ, xe của chủ xe, bảo dưỡng, đánh giá, audit
export interface Profile {
  fullName: string
  email: string
  phone: string
  dob: string
  gender: 'MALE' | 'FEMALE' | 'OTHER'
  bio: string
  avatarUrl: string
}

export interface Address {
  id: number
  label: string
  receiver: string
  phone: string
  line: string
  district: string
  city: string
  isDefault: boolean
}

export type VehicleStatus = 'ACTIVE' | 'INACTIVE' | 'MAINTENANCE'

export interface VehicleImage { id: number; url: string; isPrimary: boolean }
export interface VehicleLocation { address: string; city: string; lat: number; lng: number; pickupNote: string }
export interface MaintenanceRecord { id: number; date: string; type: string; cost: number; odometer: number; note: string }

export interface OwnerVehicle {
  id: number
  name: string
  brand: string
  category: string
  plate: string
  year: number
  seats: number
  transmission: 'AUTO' | 'MANUAL'
  fuel: 'GASOLINE' | 'DIESEL' | 'ELECTRIC' | 'HYBRID'
  pricePerDay: number
  deposit: number
  description: string
  status: VehicleStatus
  images: VehicleImage[]
  features: string[]
  location: VehicleLocation
  maintenance: MaintenanceRecord[]
}

export type VehicleDraft = Omit<OwnerVehicle, 'id' | 'images' | 'features' | 'location' | 'maintenance'>

export interface PendingReview { bookingId: number; vehicleName: string; imageUrl: string; from: string; to: string }
export interface MyReview { id: number; vehicleName: string; rating: number; comment: string; createdAt: string }

export interface AuditLog {
  id: number
  time: string
  actor: string
  action: string
  entity: string
  entityId: number
  ip: string
  before: Record<string, unknown> | null
  after: Record<string, unknown> | null
}
