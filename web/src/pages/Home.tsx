import { Link } from 'react-router-dom'
import CarCard from '../components/CarCard'
import { mockVehicles } from '../mocks/data'

/** Trang chủ mẫu để thấy khung chạy được. Hiển sẽ làm lại khi làm việc "search". */
export default function Home() {
  return (
    <div>
      <section className="mb-8 rounded-2xl bg-gradient-to-r from-brand-700 to-brand-500 p-8 text-white">
        <h1 className="mb-2 text-3xl font-bold">Thuê xe dễ dàng, đi ngay hôm nay</h1>
        <p className="mb-4 text-brand-100">Hàng trăm xe từ chủ xe uy tín, giá minh bạch.</p>
        <Link to="/vehicles" className="inline-block rounded-lg bg-white px-5 py-2 font-semibold text-brand-700">Tìm xe ngay</Link>
      </section>
      <h2 className="mb-4 text-lg font-semibold">Xe nổi bật</h2>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {mockVehicles.map((v) => <CarCard key={v.id} v={v} />)}
      </div>
    </div>
  )
}
