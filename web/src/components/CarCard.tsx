import { Link } from 'react-router-dom'
import type { VehicleSummary } from '../types'

export const vnd = (n: number) => n.toLocaleString('vi-VN') + ' đ'

export default function CarCard({ v }: { v: VehicleSummary }) {
  return (
    <Link to={`/vehicles/${v.id}`} className="group overflow-hidden rounded-xl border bg-white shadow-sm transition hover:shadow-md">
      <img src={v.imageUrl} alt={v.name} className="h-44 w-full object-cover transition group-hover:scale-105" loading="lazy" />
      <div className="p-4">
        <div className="mb-1 flex items-center justify-between text-xs text-slate-500">
          <span>{v.brand} • {v.category}</span>
          <span>★ {v.rating.toFixed(1)} ({v.reviewCount})</span>
        </div>
        <h3 className="font-semibold">{v.name}</h3>
        <p className="text-xs text-slate-500">{v.seats} chỗ • {v.city}</p>
        <p className="mt-2 text-lg font-bold text-brand-700">{vnd(v.pricePerDay)}<span className="text-xs font-normal text-slate-500"> / ngày</span></p>
      </div>
    </Link>
  )
}
