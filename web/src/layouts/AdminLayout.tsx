import { NavLink, Outlet, Link } from 'react-router-dom'

const items = [
  { to: '/admin', label: 'Thống kê', end: true },
  { to: '/admin/users', label: 'Người dùng' },
  { to: '/admin/vehicles', label: 'Xe' },
  { to: '/admin/bookings', label: 'Đơn đặt xe' },
  { to: '/admin/coupons', label: 'Coupon' },
  { to: '/admin/audit', label: 'Nhật ký audit' },
]

/** Khung riêng cho Admin: thanh bên trái. Thêm mục mới vào mảng items. */
export default function AdminLayout() {
  return (
    <div className="flex min-h-screen">
      <aside className="w-56 shrink-0 bg-slate-900 p-4 text-slate-200">
        <Link to="/" className="mb-6 block rounded-lg bg-white p-2"><img src="/logo.png" alt="Car Rental" className="mx-auto h-12 w-auto" /><span className="mt-1 block text-center text-xs font-semibold text-brand-700">Quản trị</span></Link>
        <nav className="flex flex-col gap-1">
          {items.map((i) => (
            <NavLink key={i.to} to={i.to} end={i.end}
              className={({ isActive }) => `rounded px-3 py-2 text-sm ${isActive ? 'bg-brand-600 text-white' : 'hover:bg-slate-800'}`}>
              {i.label}
            </NavLink>
          ))}
        </nav>
        <Link to="/" className="mt-8 block text-xs text-slate-400 hover:text-white">← Về trang chủ</Link>
      </aside>
      <main className="flex-1 bg-slate-50 p-6"><Outlet /></main>
    </div>
  )
}
