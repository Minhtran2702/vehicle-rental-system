import { api, delay, USE_MOCKS } from './client'
import {
  seedAddresses, seedAudit, seedMyReviews, seedPending, seedProfile, seedVehicles, BRANDS, CATEGORIES,
} from '../mocks/minh'
import { mockUsers } from '../mocks/data'
import type {
  Address, AuditLog, MaintenanceRecord, MyReview, OwnerVehicle, PendingReview, Profile,
  SeedVehicle, VehicleDraft, VehicleLocation,
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
let pending: PendingReview[] = clone(seedPending)
let myReviews: MyReview[] = clone(seedMyReviews)

// ---------- Đăng ký ----------
export async function register(data: { fullName: string; email: string; phone: string; password: string }) {
  if (!USE_MOCKS) {
    await api.post('/api/auth/register', data)
    return
  }
  await delay()
  if (mockUsers.some((u) => u.email === data.email)) throw new Error('Email đã được sử dụng')
  mockUsers.push({ id: String(newId()), email: data.email, fullName: data.fullName, role: 'CUSTOMER', password: data.password })
}

// ---------- Hồ sơ ----------
// Backend trả ProfileDto (dateOfBirth, có thể null); web dùng tên dob và chuỗi rỗng thay cho null
type ProfileDto = {
  email: string; fullName: string; phone: string | null; avatarUrl: string | null
  dateOfBirth: string | null; gender: string | null; bio: string | null
}
const fromDto = (d: ProfileDto): Profile => ({
  email: d.email, fullName: d.fullName, phone: d.phone ?? '', dob: d.dateOfBirth ?? '',
  gender: (d.gender ?? 'OTHER') as Profile['gender'], bio: d.bio ?? '', avatarUrl: d.avatarUrl ?? '',
})
export async function getProfile(): Promise<Profile> {
  if (!USE_MOCKS) return fromDto((await api.get('/api/users/me')).data.data)
  await delay(); return clone(profile)
}
export async function updateProfile(p: Profile): Promise<Profile> {
  if (!USE_MOCKS) {
    const res = await api.put('/api/users/me', {
      fullName: p.fullName, phone: p.phone || null, dateOfBirth: p.dob || null, gender: p.gender,
      bio: p.bio || null, avatarUrl: p.avatarUrl || null,
    })
    return fromDto(res.data.data)
  }
  await delay(); profile = clone(p); return clone(profile)
}
export async function changeAvatar(url: string): Promise<string> {
  // Upload ảnh thật cần API upload file (làm ở việc "ảnh xe"), nên tạm chưa đổi được ảnh khi chạy API thật
  if (!USE_MOCKS) throw new Error('Chưa có API tải ảnh lên, sẽ làm ở việc ảnh xe')
  await delay(); profile.avatarUrl = url; return url
}

// ---------- Sổ địa chỉ ----------
type AddressDto = { id: number; label: string; addressLine: string; district: string | null; city: string; defaultAddress: boolean }
const addrFromDto = (d: AddressDto): Address => ({
  id: d.id, label: d.label, line: d.addressLine, district: d.district ?? '', city: d.city, isDefault: d.defaultAddress,
})
const addrList = (data: AddressDto[]) => data.map(addrFromDto)

export async function listAddresses(): Promise<Address[]> {
  if (!USE_MOCKS) return addrList((await api.get('/api/users/me/addresses')).data.data)
  await delay(); return clone(addresses)
}
export async function saveAddress(a: Omit<Address, 'id'> & { id?: number }): Promise<Address[]> {
  if (!USE_MOCKS) {
    const body = { label: a.label, addressLine: a.line, district: a.district || null, city: a.city, defaultAddress: a.isDefault }
    const res = a.id
      ? await api.put(`/api/users/me/addresses/${a.id}`, body)
      : await api.post('/api/users/me/addresses', body)
    return addrList(res.data.data)
  }
  await delay()
  if (a.isDefault) addresses = addresses.map((x) => ({ ...x, isDefault: false }))
  if (a.id) addresses = addresses.map((x) => (x.id === a.id ? { ...x, ...a, id: x.id } : x))
  else addresses = [...addresses, { ...a, id: newId() }]
  if (!addresses.some((x) => x.isDefault) && addresses[0]) addresses[0].isDefault = true
  return clone(addresses)
}
export async function deleteAddress(id: number): Promise<Address[]> {
  if (!USE_MOCKS) return addrList((await api.delete(`/api/users/me/addresses/${id}`)).data.data)
  await delay()
  addresses = addresses.filter((x) => x.id !== id)
  if (!addresses.some((x) => x.isDefault) && addresses[0]) addresses[0].isDefault = true
  return clone(addresses)
}

// ---------- Hãng xe / loại xe (danh mục dùng chung) ----------
export interface CatalogItem { id: number; name: string }
export interface Catalog { brands: CatalogItem[]; categories: CatalogItem[] }
let catalogCache: Catalog | null = null
export async function getCatalog(): Promise<Catalog> {
  if (catalogCache) return catalogCache
  if (!USE_MOCKS) {
    const [b, c] = await Promise.all([api.get('/api/brands'), api.get('/api/categories')])
    catalogCache = { brands: b.data.data, categories: c.data.data }
  } else {
    catalogCache = {
      brands: BRANDS.map((name, i) => ({ id: i + 1, name })),
      categories: CATEGORIES.map((name, i) => ({ id: i + 1, name })),
    }
  }
  return catalogCache
}

// ---------- Xe của chủ xe ----------
const DEFAULT_LOC: VehicleLocation = { address: '', city: '', lat: 10.7769, lng: 106.7009, pickupNote: '' }

/** Bổ sung các trường mới cho dữ liệu giả (model, màu, số km, id hãng / loại). */
const norm = (v: SeedVehicle): OwnerVehicle => ({
  ...v,
  model: v.name, color: '', mileage: 0,
  brandId: Math.max(1, BRANDS.indexOf(v.brand) + 1), categoryId: Math.max(1, CATEGORIES.indexOf(v.category) + 1),
})
let vehicles: OwnerVehicle[] = clone(seedVehicles).map(norm)

/* eslint-disable @typescript-eslint/no-explicit-any */
const toMaintenance = (m: any): MaintenanceRecord => ({
  id: m.id, date: m.performedDate, type: m.maintenanceType, cost: Number(m.cost), note: m.description ?? '',
})
/** Chi tiết xe từ backend (VehicleDetail) -> OwnerVehicle của web. */
const fromDetail = (d: any, maintenance: MaintenanceRecord[] = []): OwnerVehicle => ({
  id: d.id, name: d.name, model: d.model, brand: d.brand, brandId: d.brandId, category: d.category, categoryId: d.categoryId,
  plate: d.licensePlate, color: d.color ?? '', mileage: d.mileage, year: d.year, seats: d.seats,
  transmission: d.transmission, fuel: d.fuelType, pricePerDay: Number(d.pricePerDay), deposit: Number(d.securityDeposit),
  description: d.description ?? '', status: d.status,
  images: (d.images ?? []).map((i: any) => ({ id: i.id, url: i.imageUrl, isPrimary: i.primaryImage })),
  features: d.features ?? [],
  location: d.location ? { ...DEFAULT_LOC, lat: Number(d.location.latitude), lng: Number(d.location.longitude) } : { ...DEFAULT_LOC },
  maintenance,
})
/** Dòng trong danh sách "Xe của tôi" (VehicleSummary): chưa đủ chi tiết, chỉ đủ để hiện thẻ xe. */
const fromSummary = (d: any): OwnerVehicle => ({
  id: d.id, name: d.name, model: d.name, brand: '', brandId: 0, category: '', categoryId: 0, plate: d.licensePlate,
  color: '', mileage: 0, year: 0, seats: d.seats, transmission: d.transmission, fuel: d.fuelType,
  pricePerDay: Number(d.pricePerDay), deposit: 0, description: '', status: d.status,
  images: d.coverImageUrl ? [{ id: 0, url: d.coverImageUrl, isPrimary: true }] : [],
  features: [], location: { ...DEFAULT_LOC }, maintenance: [],
})
const toRequest = (d: VehicleDraft) => ({
  brandId: d.brandId, categoryId: d.categoryId, model: d.model.trim(), licensePlate: d.plate.trim(),
  color: d.color.trim() || null, transmission: d.transmission, fuelType: d.fuel, seats: d.seats, year: d.year,
  mileage: d.mileage, pricePerDay: d.pricePerDay, securityDeposit: d.deposit, description: d.description.trim() || null,
})

export async function listMyVehicles(): Promise<OwnerVehicle[]> {
  if (!USE_MOCKS) return (await api.get('/api/owner/vehicles')).data.data.map(fromSummary)
  await delay(); return clone(vehicles)
}
export async function getMyVehicle(id: string): Promise<OwnerVehicle> {
  if (!USE_MOCKS) {
    const [d, m] = await Promise.all([api.get(`/api/owner/vehicles/${id}`), api.get(`/api/owner/vehicles/${id}/maintenance`)])
    return fromDetail(d.data.data, m.data.data.map(toMaintenance))
  }
  await delay()
  const v = vehicles.find((x) => x.id === id)
  if (!v) throw new Error('Không tìm thấy xe')
  return clone(v)
}
export async function createVehicle(
  d: VehicleDraft, images: string[], features: string[], location: VehicleLocation,
): Promise<OwnerVehicle> {
  if (!USE_MOCKS) {
    const res = await api.post('/api/owner/vehicles', {
      vehicle: toRequest(d), imageUrls: images, features, location: { latitude: location.lat, longitude: location.lng },
    })
    return fromDetail(res.data.data)
  }
  await delay()
  if (vehicles.some((v) => v.plate.toLowerCase() === d.plate.toLowerCase())) throw new Error('Biển số đã tồn tại')
  const v: OwnerVehicle = {
    ...d, name: `${d.brand} ${d.model}`.trim(), id: String(newId()),
    images: images.map((url, i) => ({ id: newId(), url, isPrimary: i === 0 })),
    features, location, maintenance: [],
  }
  vehicles = [v, ...vehicles]
  return clone(v)
}
function mutate(id: string, fn: (v: OwnerVehicle) => void): OwnerVehicle {
  const v = vehicles.find((x) => x.id === id)
  if (!v) throw new Error('Không tìm thấy xe')
  fn(v)
  return clone(v)
}
export async function updateVehicle(id: string, d: VehicleDraft) {
  if (!USE_MOCKS) { await api.put(`/api/owner/vehicles/${id}`, toRequest(d)); return getMyVehicle(id) }
  await delay()
  if (vehicles.some((v) => v.id !== id && v.plate.toLowerCase() === d.plate.toLowerCase())) throw new Error('Biển số đã tồn tại')
  return mutate(id, (v) => Object.assign(v, d, { name: `${d.brand} ${d.model}`.trim() }))
}
export async function setVehicleStatus(id: string, status: OwnerVehicle['status']) {
  if (!USE_MOCKS) { await api.patch(`/api/owner/vehicles/${id}/status`, { status }); return getMyVehicle(id) }
  await delay(150); return mutate(id, (v) => { v.status = status })
}
/** Thêm ảnh bằng đường dẫn (URL). Khi chạy API thật, ảnh phải là link; tải file lên sẽ làm khi có API upload. */
export async function addImage(id: string, url: string) {
  if (!USE_MOCKS) { await api.post(`/api/owner/vehicles/${id}/images`, { imageUrl: url }); return getMyVehicle(id) }
  await delay(); return mutate(id, (v) => { v.images.push({ id: newId(), url, isPrimary: v.images.length === 0 }) })
}
export async function removeImage(id: string, imageId: number) {
  if (!USE_MOCKS) { await api.delete(`/api/owner/vehicles/${id}/images/${imageId}`); return getMyVehicle(id) }
  await delay(150)
  return mutate(id, (v) => {
    const wasPrimary = v.images.find((i) => i.id === imageId)?.isPrimary
    v.images = v.images.filter((i) => i.id !== imageId)
    if (wasPrimary && v.images[0]) v.images[0].isPrimary = true
  })
}
export async function setPrimaryImage(id: string, imageId: number) {
  if (!USE_MOCKS) { await api.patch(`/api/owner/vehicles/${id}/images/${imageId}/primary`); return getMyVehicle(id) }
  await delay(150); return mutate(id, (v) => { v.images.forEach((i) => { i.isPrimary = i.id === imageId }) })
}
export async function saveFeatures(id: string, features: string[]) {
  if (!USE_MOCKS) { await api.put(`/api/owner/vehicles/${id}/features`, { features }); return getMyVehicle(id) }
  await delay(); return mutate(id, (v) => { v.features = features })
}
export async function saveLocation(id: string, loc: VehicleLocation) {
  if (!USE_MOCKS) { await api.put(`/api/owner/vehicles/${id}/location`, { latitude: loc.lat, longitude: loc.lng }); return getMyVehicle(id) }
  await delay(); return mutate(id, (v) => { v.location = loc })
}
export async function addMaintenance(id: string, m: Omit<MaintenanceRecord, 'id'>) {
  if (!USE_MOCKS) {
    await api.post(`/api/owner/vehicles/${id}/maintenance`, {
      maintenanceType: m.type, description: m.note || null, cost: m.cost, performedDate: m.date, nextDueDate: null,
    })
    return getMyVehicle(id)
  }
  await delay()
  return mutate(id, (v) => { v.maintenance = [{ ...m, id: newId() }, ...v.maintenance].sort((a, b) => b.date.localeCompare(a.date)) })
}
export async function deleteMaintenance(id: string, recId: number) {
  if (!USE_MOCKS) { await api.delete(`/api/owner/vehicles/${id}/maintenance/${recId}`); return getMyVehicle(id) }
  await delay(150); return mutate(id, (v) => { v.maintenance = v.maintenance.filter((m) => m.id !== recId) })
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
export async function listAudit(): Promise<AuditLog[]> {
  if (!USE_MOCKS) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const items: any[] = (await api.get('/api/admin/audit-logs', { params: { size: 100 } })).data.data.items
    return items.map((a) => ({
      id: a.id, time: String(a.createdAt).replace('T', ' ').slice(0, 19), actor: a.userEmail ?? '—',
      action: a.action, entity: a.entityType, entityId: a.entityId ?? '', ip: a.ipAddress ?? '—',
      before: a.oldData ?? null, after: a.newData ?? null,
    }))
  }
  await delay(); return clone(seedAudit)
}
