import { delay, USE_MOCKS } from './client'
import {
  seedAddresses, seedAudit, seedMyReviews, seedPending, seedProfile, seedVehicles,
} from '../mocks/minh'
import { mockUsers } from '../mocks/data'
import type {
  Address, AuditLog, MaintenanceRecord, MyReview, OwnerVehicle, PendingReview, Profile,
  VehicleDraft, VehicleLocation,
} from '../types/minh'

/**
 * Hàm gọi API của Minh. Hiện chạy bằng dữ liệu giả lưu trong bộ nhớ (mất khi F5).
 * Khi làm Back-end ở giai đoạn 5: thay phần mock bằng api.get / api.post thật.
 */
const clone = <T,>(v: T): T => JSON.parse(JSON.stringify(v))
const mockOnly = () => { if (!USE_MOCKS) throw new Error('Chưa nối API thật – đặt VITE_USE_MOCKS=true') }
let nextId = 1000
const newId = () => ++nextId

let profile: Profile = clone(seedProfile)
let addresses: Address[] = clone(seedAddresses)
let vehicles: OwnerVehicle[] = clone(seedVehicles)
let pending: PendingReview[] = clone(seedPending)
let myReviews: MyReview[] = clone(seedMyReviews)

// ---------- Đăng ký ----------
export async function register(data: { fullName: string; email: string; phone: string; password: string }) {
  mockOnly(); await delay()
  if (mockUsers.some((u) => u.email === data.email)) throw new Error('Email đã được sử dụng')
  mockUsers.push({ id: newId(), email: data.email, fullName: data.fullName, role: 'CUSTOMER', password: data.password })
}

// ---------- Hồ sơ ----------
export async function getProfile(): Promise<Profile> { mockOnly(); await delay(); return clone(profile) }
export async function updateProfile(p: Profile): Promise<Profile> { mockOnly(); await delay(); profile = clone(p); return clone(profile) }
export async function changeAvatar(url: string): Promise<string> { mockOnly(); await delay(); profile.avatarUrl = url; return url }

// ---------- Sổ địa chỉ ----------
export async function listAddresses(): Promise<Address[]> { mockOnly(); await delay(); return clone(addresses) }
export async function saveAddress(a: Omit<Address, 'id'> & { id?: number }): Promise<Address[]> {
  mockOnly(); await delay()
  if (a.isDefault) addresses = addresses.map((x) => ({ ...x, isDefault: false }))
  if (a.id) addresses = addresses.map((x) => (x.id === a.id ? { ...x, ...a, id: x.id } : x))
  else addresses = [...addresses, { ...a, id: newId() }]
  if (!addresses.some((x) => x.isDefault) && addresses[0]) addresses[0].isDefault = true
  return clone(addresses)
}
export async function deleteAddress(id: number): Promise<Address[]> {
  mockOnly(); await delay()
  addresses = addresses.filter((x) => x.id !== id)
  if (!addresses.some((x) => x.isDefault) && addresses[0]) addresses[0].isDefault = true
  return clone(addresses)
}

// ---------- Xe của chủ xe ----------
export async function listMyVehicles(): Promise<OwnerVehicle[]> { mockOnly(); await delay(); return clone(vehicles) }
export async function getMyVehicle(id: number): Promise<OwnerVehicle> {
  mockOnly(); await delay()
  const v = vehicles.find((x) => x.id === id)
  if (!v) throw new Error('Không tìm thấy xe')
  return clone(v)
}
export async function createVehicle(
  d: VehicleDraft, images: string[], features: string[], location: VehicleLocation,
): Promise<OwnerVehicle> {
  mockOnly(); await delay()
  if (vehicles.some((v) => v.plate.toLowerCase() === d.plate.toLowerCase())) throw new Error('Biển số đã tồn tại')
  const v: OwnerVehicle = {
    ...d, id: newId(), images: images.map((url, i) => ({ id: newId(), url, isPrimary: i === 0 })),
    features, location, maintenance: [],
  }
  vehicles = [v, ...vehicles]
  return clone(v)
}
function mutate(id: number, fn: (v: OwnerVehicle) => void): OwnerVehicle {
  const v = vehicles.find((x) => x.id === id)
  if (!v) throw new Error('Không tìm thấy xe')
  fn(v)
  return clone(v)
}
export async function updateVehicle(id: number, d: VehicleDraft) {
  mockOnly(); await delay()
  if (vehicles.some((v) => v.id !== id && v.plate.toLowerCase() === d.plate.toLowerCase())) throw new Error('Biển số đã tồn tại')
  return mutate(id, (v) => Object.assign(v, d))
}
export async function setVehicleStatus(id: number, status: OwnerVehicle['status']) {
  mockOnly(); await delay(150); return mutate(id, (v) => { v.status = status })
}
export async function addImage(id: number, url: string) {
  mockOnly(); await delay(); return mutate(id, (v) => { v.images.push({ id: newId(), url, isPrimary: v.images.length === 0 }) })
}
export async function removeImage(id: number, imageId: number) {
  mockOnly(); await delay(150)
  return mutate(id, (v) => {
    const wasPrimary = v.images.find((i) => i.id === imageId)?.isPrimary
    v.images = v.images.filter((i) => i.id !== imageId)
    if (wasPrimary && v.images[0]) v.images[0].isPrimary = true
  })
}
export async function setPrimaryImage(id: number, imageId: number) {
  mockOnly(); await delay(150); return mutate(id, (v) => { v.images.forEach((i) => { i.isPrimary = i.id === imageId }) })
}
export async function saveFeatures(id: number, features: string[]) {
  mockOnly(); await delay(); return mutate(id, (v) => { v.features = features })
}
export async function saveLocation(id: number, loc: VehicleLocation) {
  mockOnly(); await delay(); return mutate(id, (v) => { v.location = loc })
}
export async function addMaintenance(id: number, m: Omit<MaintenanceRecord, 'id'>) {
  mockOnly(); await delay()
  return mutate(id, (v) => { v.maintenance = [{ ...m, id: newId() }, ...v.maintenance].sort((a, b) => b.date.localeCompare(a.date)) })
}
export async function deleteMaintenance(id: number, recId: number) {
  mockOnly(); await delay(150); return mutate(id, (v) => { v.maintenance = v.maintenance.filter((m) => m.id !== recId) })
}

// ---------- Đánh giá ----------
export async function listPendingReviews(): Promise<PendingReview[]> { mockOnly(); await delay(); return clone(pending) }
export async function listMyReviews(): Promise<MyReview[]> { mockOnly(); await delay(); return clone(myReviews) }
export async function submitReview(bookingId: number, rating: number, comment: string) {
  mockOnly(); await delay()
  const p = pending.find((x) => x.bookingId === bookingId)
  if (!p) throw new Error('Đơn này đã được đánh giá')
  pending = pending.filter((x) => x.bookingId !== bookingId)
  myReviews = [{ id: newId(), vehicleName: p.vehicleName, rating, comment, createdAt: new Date().toISOString().slice(0, 10) }, ...myReviews]
}

// ---------- Nhật ký audit (Admin) ----------
export async function listAudit(): Promise<AuditLog[]> { mockOnly(); await delay(); return clone(seedAudit) }
