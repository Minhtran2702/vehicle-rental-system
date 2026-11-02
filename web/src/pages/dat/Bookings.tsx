import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Booking, myBookings, statusLabel } from '../../api/dat'
import { errorMessage } from '../../api/client'
import Badge from '../../components/Badge'
import Spinner from '../../components/Spinner'
import { vnd } from '../../components/CarCard'

export const fmtTime = (iso: string) => new Date(iso).toLocaleString('vi-VN', { dateStyle: 'short', timeStyle: 'short' })

/** Đơn của tôi (với tư cách người thuê). */
export default function Bookings() {
  const [items, setItems] = useState<Booking[] | null>(null)
  const [err, setErr] = useState('')
  useEffect(() => { myBookings().then(setItems).catch((e) => setErr(errorMessage(e))) }, [])
  if (!items) return err ? <p className="text-red-600">{err}</p> : <Spinner />

  return (
    <div>
      <h1 className="mb-4 text-2xl font-extrabold text-brand-900">Đơn của tôi</h1>
      {items.length === 0 ? <p className="text-slate-600">Bạn chưa có đơn đặt xe nào.</p> : (
        <ul className="space-y-3">
          {items.map((b) => (
            <li key={b.id}>
              <Link to={`/bookings/${b.id}`} className="flex items-center justify-between gap-4 rounded-2xl border bg-white p-4 transition hover:-translate-y-0.5 hover:border-road-500 hover:shadow">
                <div>
                  <p className="font-bold text-brand-900">{b.vehicleName}</p>
                  <p className="text-sm text-slate-600">{fmtTime(b.pickupDatetime)} → {fmtTime(b.returnDatetime)} · {b.totalDays} ngày</p>
                </div>
                <div className="text-right">
                  <p className="font-bold">{vnd(b.totalAmount)}</p>
                  <Badge status={b.status} label={statusLabel[b.status] ?? b.status} />
                </div>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
