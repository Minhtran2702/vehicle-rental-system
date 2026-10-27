import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import Button from '../components/Button'

const link = ({ isActive }: { isActive: boolean }) =>
  `rounded px-3 py-2 text-sm font-medium ${isActive ? 'bg-brand-50 text-brand-700' : 'text-slate-600 hover:text-brand-700'}`

/** Khung chung cho Khách + Người dùng. Menu đổi theo vai trò. Thêm mục menu mới ở mảng bên dưới. */
export default function MainLayout() {
  const { user, logout, hasRole } = useAuth()
  const navigate = useNavigate()

  const menu = [
    { to: '/', label: 'Trang chủ', show: true, end: true },
    { to: '/vehicles', label: 'Tìm xe', show: true },
    { to: '/ai', label: 'AI gợi ý', show: !!user },
    { to: '/bookings', label: 'Đơn của tôi', show: !!user },
    { to: '/my-vehicles', label: 'Xe của tôi', show: !!user },
    { to: '/reviews', label: 'Đánh giá', show: !!user },
    { to: '/favorites', label: 'Yêu thích', show: !!user },
    { to: '/admin', label: 'Quản trị', show: hasRole('ADMIN') },
  ].filter((m) => m.show)

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-40 border-b bg-white/95 backdrop-blur">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
          <Link to="/" className="flex items-center" aria-label="Car Rental"><img src="/logo.png" alt="Car Rental" className="h-11 w-auto" /></Link>
          <nav className="hidden gap-1 md:flex">
            {menu.map((m) => <NavLink key={m.to} to={m.to} end={m.end} className={link}>{m.label}</NavLink>)}
          </nav>
          <div className="flex items-center gap-2 text-sm">
            {user ? (
              <>
                <Link to="/profile" className="hidden text-slate-700 hover:underline sm:block">{user.fullName}</Link>
                <Button variant="secondary" onClick={() => { logout(); navigate('/') }}>Đăng xuất</Button>
              </>
            ) : (
              <>
                <Button variant="ghost" onClick={() => navigate('/login')}>Đăng nhập</Button>
                <Button onClick={() => navigate('/register')}>Đăng ký</Button>
              </>
            )}
          </div>
        </div>
        <nav className="flex gap-1 overflow-x-auto border-t px-4 py-1 md:hidden">
          {menu.map((m) => <NavLink key={m.to} to={m.to} end={m.end} className={link}>{m.label}</NavLink>)}
        </nav>
      </header>
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-6"><Outlet /></main>
      <footer className="border-t bg-white py-4 text-center text-xs text-slate-500">
        © 2026 Car Rental – Đồ án cuối kỳ
      </footer>
    </div>
  )
}
