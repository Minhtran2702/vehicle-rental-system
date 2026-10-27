import { FormEvent, useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { errorMessage } from '../api/client'
import Button from '../components/Button'
import Input from '../components/Input'

/** Trang đăng nhập mẫu (chạy được với mocks: user@vrs.local / 123456). Minh làm lại đầy đủ ở việc "login". */
export default function Login() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const location = useLocation() as { state?: { from?: string; registered?: boolean } }
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function submit(e: FormEvent) {
    e.preventDefault()
    setError(''); setLoading(true)
    try {
      const u = await login(email, password)
      navigate(location.state?.from ?? (u.role === 'ADMIN' ? '/admin' : '/'), { replace: true })
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={submit} className="mx-auto mt-10 max-w-sm space-y-4 rounded-xl border bg-white p-6 shadow-sm">
      <img src="/logo.png" alt="Car Rental" className="mx-auto h-20 w-auto" />
      <h1 className="text-center text-xl font-semibold">Đăng nhập</h1>
      {location.state?.registered && <p className="rounded-lg bg-green-50 p-3 text-sm text-green-700">Đăng ký thành công, hãy đăng nhập.</p>}
      <Input label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
      <Input label="Mật khẩu" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
      {error && <p className="text-sm text-red-600">{error}</p>}
      <Button type="submit" loading={loading} className="w-full">Đăng nhập</Button>
      <p className="text-center text-sm text-slate-500">Chưa có tài khoản? <Link to="/register" className="text-brand-600">Đăng ký</Link></p>
      <p className="text-center text-xs text-slate-400">Demo: user@vrs.local / owner@vrs.local / admin@vrs.local – mật khẩu 123456</p>
    </form>
  )
}
