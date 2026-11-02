import { FormEvent, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import CarCard, { CarSilhouette } from '../components/CarCard'
import { mockVehicles } from '../mocks/data'
import { useAuth } from '../auth/AuthContext'

const CITIES = ['TP. Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng']
const TYPES = ['Sedan', 'SUV', 'MPV', 'Hatchback', 'Pickup', 'Luxury', 'Electric', 'Motorbike']
const today = () => new Date().toISOString().slice(0, 10)

// Toà nhà của dải phố phía sau xe: [x, rộng, cao]
const FAR: [number, number, number][] = [[0, 70, 70], [70, 50, 105], [120, 80, 62], [200, 45, 120], [245, 90, 80], [335, 55, 100], [390, 70, 58], [460, 50, 115], [510, 85, 75], [595, 60, 98], [655, 75, 64], [730, 50, 112], [780, 90, 72], [870, 55, 104], [925, 80, 60], [1005, 50, 118], [1055, 70, 80], [1125, 75, 66]]
const NEAR: [number, number, number][] = [[0, 90, 46], [90, 60, 78], [150, 100, 40], [250, 55, 88], [305, 80, 52], [385, 110, 36], [495, 60, 84], [555, 90, 48], [645, 70, 92], [715, 100, 42], [815, 60, 80], [875, 95, 50], [970, 65, 90], [1035, 85, 44], [1120, 80, 70]]

/** Dải phố lúc hoàng hôn: hai lớp toà nhà, cửa sổ sáng đèn. */
function Skyline() {
  return (
    <svg viewBox="0 0 1200 140" preserveAspectRatio="xMidYMax slice" className="absolute inset-x-0 bottom-0 h-[120px] w-full sm:h-[150px]" aria-hidden="true">
      {FAR.map(([x, w, h], i) => <rect key={`f${i}`} x={x} y={140 - h} width={w} height={h} fill="#2b5788" opacity="0.55" />)}
      {NEAR.map(([x, w, h], i) => (
        <g key={`n${i}`}>
          <rect x={x} y={140 - h} width={w} height={h} fill="#17314d" />
          {Array.from({ length: Math.floor(h / 22) }).map((_, r) => (r + i) % 3 === 0
            ? <rect key={r} x={x + 10 + ((r * 17 + i * 7) % Math.max(10, w - 26))} y={140 - h + 8 + r * 20} width="6" height="8" fill="#f6c453" opacity="0.85" />
            : null)}
        </g>
      ))}
    </svg>
  )
}

/** Xe vàng có chùm đèn pha chiếu phía trước. */
function HeroCar() {
  return (
    <svg viewBox="0 0 640 200" className="hero-car absolute bottom-[-6px] right-0 w-[330px] sm:right-10 sm:w-[560px]" aria-hidden="true">
      <defs>
        <linearGradient id="beam" x1="0" x2="1"><stop offset="0" stopColor="#ffe9a8" stopOpacity="0.65" /><stop offset="1" stopColor="#ffe9a8" stopOpacity="0" /></linearGradient>
      </defs>
      <polygon points="452,128 640,86 640,166 452,150" fill="url(#beam)" />
      <path fill="#f2b632" d="M20 140 L30 120 Q40 100 80 96 L150 92 Q175 62 215 56 L300 56 Q340 58 365 92 L420 100 Q450 106 456 130 L460 150 Q460 158 450 158 L420 158 A34 34 0 0 0 352 158 L150 158 A34 34 0 0 0 82 158 L30 158 Q20 158 20 148 Z" />
      <path fill="#c98d0e" d="M20 138 L456 138 L460 150 Q460 158 450 158 L20 158 Z" opacity="0.35" />
      <path fill="#142a42" d="M182 92 Q198 70 222 68 L262 68 L262 92 Z M274 68 L300 68 Q326 70 340 92 L274 92 Z" />
      <path fill="#fff6d6" d="M184 90 Q199 72 222 70 L236 70 L214 90 Z" opacity="0.45" />
      <rect x="440" y="124" width="18" height="10" rx="4" fill="#fff6d6" />
      <circle cx="116" cy="158" r="30" fill="#0b1826" /><circle cx="116" cy="158" r="12" fill="#c9d6e6" />
      <circle cx="386" cy="158" r="30" fill="#0b1826" /><circle cx="386" cy="158" r="12" fill="#c9d6e6" />
    </svg>
  )
}

const REASONS = [
  { title: 'Giá và tiền cọc rõ ràng', text: 'Giá thuê theo ngày và tiền đặt cọc hiện ngay trên từng xe, trước khi bạn quyết định đặt.' },
  { title: 'Một tài khoản, hai vai trò', text: 'Hôm nay thuê xe đi chơi, mai đăng xe của mình lên cho thuê. Không cần tạo thêm tài khoản.' },
  { title: 'Xe do chủ xe tự quản lý', text: 'Chủ xe tự cập nhật ảnh, tiện ích, nơi nhận xe và lịch bảo dưỡng để xe luôn sẵn sàng.' },
]

/** Trang chủ. Danh sách "Xe nổi bật" đang dùng dữ liệu giả; Hiển nối API tìm xe thật ở việc "search". */
export default function Home() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const [city, setCity] = useState(CITIES[0])
  const [from, setFrom] = useState(today())
  const [to, setTo] = useState('')

  function search(e: FormEvent) {
    e.preventDefault()
    const q = new URLSearchParams({ city, from, ...(to ? { to } : {}) })
    navigate(`/vehicles?${q.toString()}`)
  }

  return (
    <div className="-mx-4 sm:mx-0">
      {/* Hero: hoàng hôn trên phố, xe vàng đỗ trên đường, ô tìm xe nằm trên mặt đường */}
      <section className="overflow-hidden bg-[#0b1826] text-white sm:rounded-3xl">
        <div className="relative px-6 pt-12 sm:px-12 sm:pt-16" style={{ background: 'linear-gradient(180deg,#0f2237 0%,#1f4063 38%,#3a6ea5 68%,#f08a4b 100%)' }}>
          <h1 className="max-w-2xl text-5xl font-extrabold leading-[1.05] tracking-tight sm:text-7xl">Thuê xe tự lái,<br />nhận chìa là đi.</h1>
          <p className="mt-5 max-w-md text-base leading-relaxed text-brand-100 sm:text-lg">
            Chọn xe từ chủ xe trong thành phố. Giá và tiền cọc rõ ngay từ đầu, nhận xe đúng giờ đã hẹn.
          </p>

          <div className="relative -mx-6 mt-6 h-[190px] sm:-mx-12 sm:h-[230px]" aria-hidden="true">
            <div className="absolute bottom-[56px] right-[14%] h-24 w-24 rounded-full bg-gradient-to-b from-[#ffe9a8] to-[#ffb457] shadow-[0_0_80px_30px_rgba(255,190,90,0.45)] sm:h-36 sm:w-36" />
            <Skyline />
            <HeroCar />
          </div>
        </div>

        {/* mặt đường: vạch kẻ vàng và ô tìm xe */}
        <div className="hero-road h-1" aria-hidden="true" />
        <form onSubmit={search} className="px-6 pb-8 pt-7 sm:px-12 sm:pb-10">
          <div className="grid gap-3 rounded-2xl bg-white p-4 text-slate-800 shadow-2xl sm:grid-cols-[1.4fr_1fr_1fr_auto] sm:items-end sm:p-5">
            <label className="block text-sm"><span className="mb-1 block font-medium text-slate-600">Nơi nhận xe</span>
              <select value={city} onChange={(e) => setCity(e.target.value)} className="w-full rounded-lg border border-slate-300 px-3 py-2.5">
                {CITIES.map((c) => <option key={c}>{c}</option>)}
              </select>
            </label>
            <label className="block text-sm"><span className="mb-1 block font-medium text-slate-600">Ngày nhận</span>
              <input type="date" min={today()} value={from} onChange={(e) => setFrom(e.target.value)} className="w-full rounded-lg border border-slate-300 px-3 py-2.5" required />
            </label>
            <label className="block text-sm"><span className="mb-1 block font-medium text-slate-600">Ngày trả</span>
              <input type="date" min={from} value={to} onChange={(e) => setTo(e.target.value)} className="w-full rounded-lg border border-slate-300 px-3 py-2.5" />
            </label>
            <button type="submit" className="rounded-lg bg-road-500 px-8 py-3 font-bold text-brand-900 shadow-md transition hover:-translate-y-0.5 hover:bg-road-400 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-900 focus-visible:ring-offset-2">Tìm xe</button>
          </div>
        </form>
      </section>

      <div className="px-4 sm:px-0">
        <section className="mt-10">
          <h2 className="mb-3 text-xl font-extrabold text-brand-900">Bạn muốn đi bằng xe nào?</h2>
          <div className="flex flex-wrap gap-2">
            {TYPES.map((t) => (
              <Link key={t} to={`/vehicles?category=${encodeURIComponent(t)}`}
                className="rounded-full border border-slate-300 bg-white px-5 py-2 text-sm font-medium text-slate-700 transition hover:-translate-y-0.5 hover:border-road-500 hover:bg-road-500 hover:text-brand-900">{t}</Link>
            ))}
          </div>
        </section>

        <section className="mt-10">
          <div className="mb-4 flex items-end justify-between">
            <h2 className="text-2xl font-extrabold text-brand-900">Xe nổi bật</h2>
            <Link to="/vehicles" className="text-sm font-semibold text-brand-600 hover:underline">Xem tất cả xe</Link>
          </div>
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {mockVehicles.map((v) => <CarCard key={v.id} v={v} />)}
          </div>
        </section>

        <section className="mt-14">
          <h2 className="mb-6 text-2xl font-extrabold text-brand-900">Vì sao thuê xe ở đây</h2>
          <div className="grid gap-8 sm:grid-cols-3">
            {REASONS.map((r) => (
              <div key={r.title} className="border-l-4 border-road-500 pl-4">
                <h3 className="font-bold text-brand-900">{r.title}</h3>
                <p className="mt-1.5 text-sm leading-relaxed text-slate-600">{r.text}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="relative mt-14 overflow-hidden rounded-3xl bg-brand-900 p-8 text-white sm:p-12">
          <CarSilhouette className="pointer-events-none absolute -bottom-4 -right-8 w-72 text-white/10 sm:w-[28rem]" />
          <div className="relative max-w-xl">
            <h2 className="text-3xl font-extrabold leading-tight sm:text-4xl">Xe đang nằm không?<br />Cho thuê để có thêm thu nhập.</h2>
            <p className="mt-3 text-brand-100">Bạn tự đặt giá thuê, tiền cọc và chọn lúc nào xe nhận khách.</p>
            <Link to={user ? '/my-vehicles/new' : '/register'}
              className="mt-6 inline-block rounded-lg bg-road-500 px-7 py-3 font-bold text-brand-900 shadow-md transition hover:-translate-y-0.5 hover:bg-road-400 focus:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-brand-900">
              {user ? 'Đăng xe của bạn' : 'Tạo tài khoản để đăng xe'}
            </Link>
          </div>
        </section>
      </div>
    </div>
  )
}
