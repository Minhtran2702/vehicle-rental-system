import { ChangeEvent, FormEvent, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { register } from '../../api/minh'
import { errorMessage } from '../../api/client'
import Button from '../../components/Button'
import Input from '../../components/Input'

export default function Register() {
  const navigate = useNavigate()
  const [f, setF] = useState({ fullName: '', email: '', phone: '', password: '', confirm: '' })
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [serverError, setServerError] = useState('')
  const [loading, setLoading] = useState(false)
  const set = (k: keyof typeof f) => (e: ChangeEvent<HTMLInputElement>) => setF({ ...f, [k]: e.target.value })

  function validate() {
    const e: Record<string, string> = {}
    if (f.fullName.trim().length < 2) e.fullName = 'Vui lòng nhập họ tên'
    if (!/^\S+@\S+\.\S+$/.test(f.email)) e.email = 'Email không hợp lệ'
    if (!/^0\d{9}$/.test(f.phone)) e.phone = 'Số điện thoại gồm 10 số, bắt đầu bằng 0'
    if (f.password.length < 8) e.password = 'Mật khẩu tối thiểu 8 ký tự'
    else if (!/[A-Za-z]/.test(f.password) || !/\d/.test(f.password)) e.password = 'Mật khẩu cần có cả chữ và số'
    if (f.confirm !== f.password) e.confirm = 'Mật khẩu nhập lại không khớp'
    setErrors(e)
    return Object.keys(e).length === 0
  }

  async function submit(ev: FormEvent) {
    ev.preventDefault(); setServerError('')
    if (!validate()) return
    setLoading(true)
    try {
      await register({ fullName: f.fullName, email: f.email, phone: f.phone, password: f.password })
      navigate('/login', { state: { registered: true } })
    } catch (err) { setServerError(errorMessage(err)) } finally { setLoading(false) }
  }

  return (
    <form onSubmit={submit} className="mx-auto mt-6 max-w-md space-y-4 rounded-xl border bg-white p-6 shadow-sm">
      <img src="/logo.png" alt="Car Rental" className="mx-auto h-20 w-auto" />
      <h1 className="text-center text-xl font-semibold">Tạo tài khoản</h1>
      <p className="text-sm text-slate-500">Một tài khoản dùng được cả để thuê xe và đăng xe cho thuê.</p>
      <Input label="Họ và tên" value={f.fullName} onChange={set('fullName')} error={errors.fullName} />
      <Input label="Email" type="email" value={f.email} onChange={set('email')} error={errors.email} />
      <Input label="Số điện thoại" value={f.phone} onChange={set('phone')} error={errors.phone} />
      <Input label="Mật khẩu" type="password" value={f.password} onChange={set('password')} error={errors.password} />
      <Input label="Nhập lại mật khẩu" type="password" value={f.confirm} onChange={set('confirm')} error={errors.confirm} />
      {serverError && <p className="text-sm text-red-600">{serverError}</p>}
      <Button type="submit" loading={loading} className="w-full">Đăng ký</Button>
      <p className="text-center text-sm text-slate-500">Đã có tài khoản? <Link to="/login" className="text-brand-600">Đăng nhập</Link></p>
    </form>
  )
}
