import { api } from './client'
import type { ApiResponse } from '../types'

// API đặt xe của Đạt (CV50, 54, 58). Chỉ có bản thật, chưa có mock.

export interface Quote {
  vehicleId: string; vehicleName: string; imageUrl: string | null
  pricePerDay: number; totalDays: number; subtotal: number
  couponCode: string | null; discount: number; tax: number; totalAmount: number; securityDeposit: number
}
export interface Availability { available: boolean; reason: string | null; busy: { from: string; to: string }[] }
export interface BookingHistory { status: string; note: string | null; at: string }
export interface Booking {
  id: string; vehicleId: string; vehicleName: string; imageUrl: string | null
  customerId: string; customerName: string | null
  pickupDatetime: string; returnDatetime: string; pickupLocation: string; returnLocation: string
  totalDays: number; subtotal: number; discount: number; tax: number; totalAmount: number; securityDeposit: number | null
  couponCode: string | null; status: string; createdAt: string; history: BookingHistory[]
}
export interface BookingInput {
  vehicleId: string; pickupDatetime: string; returnDatetime: string
  pickupLocation?: string; returnLocation?: string; couponCode?: string
}

export const statusLabel: Record<string, string> = {
  PENDING: 'Chờ chủ xe duyệt', CONFIRMED: 'Đã xác nhận', REJECTED: 'Bị từ chối',
  IN_PROGRESS: 'Đang thuê', COMPLETED: 'Hoàn thành', CANCELLED: 'Đã huỷ',
}

/** Ô chọn giờ của trình duyệt trả "2026-12-01T09:00", backend cần thêm giây. */
export const toIso = (v: string) => (v.length === 16 ? `${v}:00` : v)

export async function checkAvailability(vehicleId: string, from?: string, to?: string): Promise<Availability> {
  const params: Record<string, string> = { vehicleId }
  if (from && to) { params.from = toIso(from); params.to = toIso(to) }
  return (await api.get<ApiResponse<Availability>>('/api/bookings/availability', { params })).data.data
}
export async function getQuote(d: Pick<BookingInput, 'vehicleId' | 'pickupDatetime' | 'returnDatetime' | 'couponCode'>): Promise<Quote> {
  const body = { ...d, pickupDatetime: toIso(d.pickupDatetime), returnDatetime: toIso(d.returnDatetime), couponCode: d.couponCode || null }
  return (await api.post<ApiResponse<Quote>>('/api/bookings/quote', body)).data.data
}
export async function createBooking(d: BookingInput): Promise<Booking> {
  const body = { ...d, pickupDatetime: toIso(d.pickupDatetime), returnDatetime: toIso(d.returnDatetime), couponCode: d.couponCode || null }
  return (await api.post<ApiResponse<Booking>>('/api/bookings', body)).data.data
}
export async function myBookings(): Promise<Booking[]> {
  return (await api.get<ApiResponse<Booking[]>>('/api/bookings/mine')).data.data
}
export async function getBooking(id: string): Promise<Booking> {
  return (await api.get<ApiResponse<Booking>>(`/api/bookings/${id}`)).data.data
}
