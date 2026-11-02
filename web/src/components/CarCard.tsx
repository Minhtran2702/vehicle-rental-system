import { useState } from 'react'
import { Link } from 'react-router-dom'
import type { VehicleSummary } from '../types'

export const vnd = (n: number) => n.toLocaleString('vi-VN') + ' đ'

/** Hình xe đơn giản, hiện khi xe chưa có ảnh hoặc ảnh không tải được. */
export function CarSilhouette({ className = '' }: { className?: string }) {
  return (
    <svg viewBox="0 0 480 200" className={className} aria-hidden="true">
      <path fill="currentColor" d="M20 140 L30 120 Q40 100 80 96 L150 92 Q175 62 215 56 L300 56 Q340 58 365 92 L420 100 Q450 106 456 130 L460 150 Q460 158 450 158 L420 158 A34 34 0 0 0 352 158 L150 158 A34 34 0 0 0 82 158 L30 158 Q20 158 20 148 Z" />
    </svg>
  )
}

export default function CarCard({ v }: { v: VehicleSummary }) {
  const [broken, setBroken] = useState(false)
  return (
    <Link to={`/vehicles/${v.id}`} className="group block overflow-hidden rounded-lg border border-slate-200 bg-white transition hover:-translate-y-1 hover:border-road-500 hover:shadow-lg">
      <div className="relative h-44 overflow-hidden bg-gradient-to-br from-brand-50 to-brand-100">
        {v.imageUrl && !broken ? (
          <img src={v.imageUrl} alt={v.name} loading="lazy" onError={() => setBroken(true)}
            className="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
        ) : (
          <div className="flex h-full items-center justify-center text-brand-500/40"><CarSilhouette className="w-44 transition duration-500 group-hover:translate-x-3" /></div>
        )}
        <span className="absolute left-3 top-3 rounded bg-white/95 px-2 py-0.5 text-xs font-semibold text-brand-900">{v.category}</span>
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-brand-900">{v.name}</h3>
        <p className="mt-0.5 text-sm text-slate-500">{v.seats} chỗ · {v.city}</p>
        <div className="mt-4 flex items-end justify-between">
          <p className="text-lg font-extrabold text-brand-900">{vnd(v.pricePerDay)}<span className="text-xs font-normal text-slate-500"> / ngày</span></p>
          <p className="text-sm text-slate-600"><span className="text-road-600">★</span> {v.rating.toFixed(1)} <span className="text-slate-400">({v.reviewCount})</span></p>
        </div>
      </div>
    </Link>
  )
}
