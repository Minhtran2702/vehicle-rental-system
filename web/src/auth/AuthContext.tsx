import { createContext, useCallback, useContext, useEffect, useMemo, useState, ReactNode } from 'react'
import { api, delay, tokenStore, USE_MOCKS } from '../api/client'
import { mockUsers } from '../mocks/data'
import type { ApiResponse, AuthUser, Role, TokenPair } from '../types'

interface AuthState {
  user: AuthUser | null
  loading: boolean
  login: (email: string, password: string) => Promise<AuthUser>
  logout: () => void
  hasRole: (...roles: Role[]) => boolean
}

const Ctx = createContext<AuthState | null>(null)
const USER_KEY = 'vrs_user'

/**
 * KHUNG: login ở đây chạy được với mocks (xem mocks/data.ts, mật khẩu 123456).
 * Khi làm việc "login" ở giai đoạn 5, Minh nối với API thật POST /api/auth/login.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    try {
      const raw = localStorage.getItem(USER_KEY)
      if (raw && tokenStore.access) setUser(JSON.parse(raw))
    } catch { /* bỏ qua dữ liệu hỏng */ }
    setLoading(false)
  }, [])

  const login = useCallback(async (email: string, password: string) => {
    if (USE_MOCKS) {
      await delay()
      const found = mockUsers.find((u) => u.email === email && u.password === password)
      if (!found) throw new Error('Sai email hoặc mật khẩu')
      const { password: _pw, ...u } = found
      tokenStore.set({ accessToken: `mock-access-${u.id}`, refreshToken: `mock-refresh-${u.id}` })
      localStorage.setItem(USER_KEY, JSON.stringify(u))
      setUser(u)
      return u
    }
    const res = await api.post<ApiResponse<{ user: AuthUser } & TokenPair>>('/api/auth/login', { email, password })
    const { user: u, accessToken, refreshToken } = res.data.data
    tokenStore.set({ accessToken, refreshToken })
    localStorage.setItem(USER_KEY, JSON.stringify(u))
    setUser(u)
    return u
  }, [])

  const logout = useCallback(() => {
    tokenStore.clear()
    localStorage.removeItem(USER_KEY)
    setUser(null)
  }, [])

  const hasRole = useCallback((...roles: Role[]) => !!user && roles.includes(user.role), [user])

  const value = useMemo(() => ({ user, loading, login, logout, hasRole }), [user, loading, login, logout, hasRole])
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>
}

export function useAuth() {
  const v = useContext(Ctx)
  if (!v) throw new Error('useAuth phải nằm trong AuthProvider')
  return v
}
