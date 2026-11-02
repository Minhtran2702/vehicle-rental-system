import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import Button from '../components/Button'

const link = ({ isActive }: { isActive: boolean }) =>
  `whitespace-nowrap border-b-2 px-3 py-2 text-sm font-medium transition-colors ${isActive ? 'border-road-500 text-brand-900' : 'border-transparent text-slate-600 hover:text-brand-700'}`

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
        <nav className="no-scrollbar flex gap-1 overflow-x-auto border-t px-4 md:hidden">
          {menu.map((m) => <NavLink key={m.to} to={m.to} end={m.end} className={link}>{m.label}</NavLink>)}
        </nav>
      </header>
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 pb-6 pt-4"><Outlet /></main>
      <footer className="relative mt-6 overflow-hidden bg-brand-900 text-brand-100">
        <div className="hero-road h-1" aria-hidden="true" />
        <div className="mx-auto grid max-w-6xl gap-10 px-4 py-12 sm:grid-cols-2 lg:grid-cols-[1.4fr_0.9fr_1fr_1.5fr]">
          <div>
            <img src="/logo.png" alt="Car Rental" className="h-12 w-auto rounded-lg bg-white p-1.5" />
            <p className="mt-4 max-w-xs text-sm leading-relaxed">Nền tảng kết nối người cần thuê xe với chủ xe trong thành phố. Giá rõ ràng, nhận xe đúng hẹn.</p>
            <Link to={user ? '/vehicles' : '/register'} className="mt-5 inline-block rounded-lg bg-road-500 px-5 py-2.5 text-sm font-bold text-brand-900 shadow transition hover:-translate-y-0.5 hover:bg-road-400">
              {user ? 'Tìm xe ngay' : 'Đăng ký miễn phí'}
            </Link>
          </div>
          <div>
            <h3 className="mb-3 text-sm font-bold uppercase tracking-wider text-road-400">Khám phá</h3>
            <ul className="space-y-2 text-sm">
              <li><Link to="/vehicles" className="hover:text-white hover:underline">Tìm xe</Link></li>
              <li><Link to="/vehicles?category=SUV" className="hover:text-white hover:underline">Xe SUV</Link></li>
              <li><Link to="/vehicles?category=Sedan" className="hover:text-white hover:underline">Xe Sedan</Link></li>
              <li><Link to="/vehicles?category=Electric" className="hover:text-white hover:underline">Xe điện</Link></li>
            </ul>
          </div>
          <div>
            <h3 className="mb-3 text-sm font-bold uppercase tracking-wider text-road-400">Dành cho chủ xe</h3>
            <ul className="space-y-2 text-sm">
              <li><Link to={user ? '/my-vehicles/new' : '/register'} className="hover:text-white hover:underline">Đăng xe cho thuê</Link></li>
              <li><Link to={user ? '/my-vehicles' : '/login'} className="hover:text-white hover:underline">Quản lý xe của tôi</Link></li>
              <li><Link to={user ? '/profile' : '/login'} className="hover:text-white hover:underline">Hồ sơ cá nhân</Link></li>
            </ul>
          </div>
          <div>
            <h3 className="mb-3 text-sm font-bold uppercase tracking-wider text-road-400">Địa chỉ</h3>
            <p className="mb-3 text-sm">84A Nguyên Hồng, TP. Hồ Chí Minh</p>
            <iframe
              title="Bản đồ 84A Nguyên Hồng"
              src={`https://maps.google.com/maps?q=${encodeURIComponent('84A Nguyên Hồng, Hồ Chí Minh')}&z=16&output=embed`}
              className="h-44 w-full rounded-xl border-0 shadow-lg"
              loading="lazy"
              referrerPolicy="no-referrer-when-downgrade"
            />
          </div>
        </div>
        <div className="border-t border-white/10 py-4 text-center text-xs text-brand-100/70">
          © 2026 Car Rental · Đồ án cuối kỳ – Vehicle Rental System
        </div>
      </footer>
    </div>
  )
}
