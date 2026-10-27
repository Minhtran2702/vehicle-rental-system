import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios'
import type { ApiResponse, TokenPair } from '../types'

export const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:8080'
// Mặc định dùng dữ liệu giả; chỉ gọi API thật khi đặt VITE_USE_MOCKS=false
export const USE_MOCKS = import.meta.env.VITE_USE_MOCKS !== 'false'

const ACCESS_KEY = 'vrs_access'
const REFRESH_KEY = 'vrs_refresh'

export const tokenStore = {
  get access() { return localStorage.getItem(ACCESS_KEY) },
  get refresh() { return localStorage.getItem(REFRESH_KEY) },
  set(t: TokenPair) {
    localStorage.setItem(ACCESS_KEY, t.accessToken)
    localStorage.setItem(REFRESH_KEY, t.refreshToken)
  },
  clear() {
    localStorage.removeItem(ACCESS_KEY)
    localStorage.removeItem(REFRESH_KEY)
  },
}

export const api = axios.create({ baseURL: API_URL, timeout: 15000 })

// Gắn JWT vào mọi request
api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const token = tokenStore.access
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Tự làm mới token khi gặp 401 (chỉ gọi refresh 1 lần dù nhiều request cùng lỗi)
let refreshing: Promise<string> | null = null

async function refreshAccessToken(): Promise<string> {
  const refreshToken = tokenStore.refresh
  if (!refreshToken) throw new Error('no refresh token')
  // Endpoint này do việc "login" làm ở backend: POST /api/auth/refresh
  const res = await axios.post<ApiResponse<TokenPair>>(`${API_URL}/api/auth/refresh`, { refreshToken })
  tokenStore.set(res.data.data)
  return res.data.data.accessToken
}

api.interceptors.response.use(
  (r) => r,
  async (error: AxiosError) => {
    const original = error.config as (InternalAxiosRequestConfig & { _retry?: boolean }) | undefined
    const isAuthCall = original?.url?.includes('/api/auth/')
    if (error.response?.status === 401 && original && !original._retry && !isAuthCall) {
      original._retry = true
      try {
        refreshing = refreshing ?? refreshAccessToken().finally(() => { refreshing = null })
        const newToken = await refreshing
        original.headers.Authorization = `Bearer ${newToken}`
        return api(original)
      } catch {
        tokenStore.clear()
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  },
)

/** Lấy thông báo lỗi dễ đọc từ lỗi axios (backend luôn trả { message }). */
export function errorMessage(e: unknown): string {
  const err = e as AxiosError<ApiResponse<unknown>>
  return err.response?.data?.message ?? err.message ?? 'Có lỗi xảy ra'
}

/** Giả lập độ trễ mạng khi dùng mocks. */
export const delay = (ms = 300) => new Promise((r) => setTimeout(r, ms))
