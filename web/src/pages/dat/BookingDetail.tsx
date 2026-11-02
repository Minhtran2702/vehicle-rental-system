import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { Booking, getBooking, statusLabel } from '../../api/dat'
import { errorMessage } from '../../api/client'
import Badge from '../../components/Badge'
import Spinner from '../../components/Spinner'
import { vnd } from '../../components/CarCard'
import { fmtTime } from './Bookings'

export default function BookingDetail() {
  const { id } = useParams()
  const [b, setB] = useState<Booking | null>(null)
  const [err, setErr] = useState('')
  useEffect(() => { if (id) getBooking(id).then(setB).catch((e) => setErr(errorMessage(e))) }, [id])
  if (!b) return err ? <p className="text-red-600">{err}</p> : <Spinner />

  return (
    <div className="mx-auto max-w-3xl space-y-5">
      <Link to="/bookings" className="text-sm text-brand-600 hover:underline">← Đơn của tôi</Link>
      <div className="flex items-center justify-between gap-3">
        <h1 className="text-2xl font-extrabold text-brand-900">{b.vehicleName}</h1>
        <Badge status={b.status} label={statusLabel[b.status] ?? b.status} />
      </div>
      <section className="grid gap-3 rounded-2xl border bg-white p-5 text-sm sm:grid-cols-2">
        <div><p className="text-slate-500">Nhận xe</p><p className="font-medium">{fmtTime(b.pickupDatetime)}</p><p>{b.pickupLocation}</p></div>
        <div><p className="text-slate-500">Trả xe</p><p className="font-medium">{fmtTime(b.returnDatetime)}</p><p>{b.returnLocation}</p></div>
      </section>
      <section className="space-y-2 rounded-2xl border bg-white p-5 text-sm">
        <Line k={`Tiền thuê (${b.totalDays} ngày)`} v={vnd(b.subtotal)} />
        {b.discount > 0 && <Line k={`Giảm giá${b.couponCode ? ` (${b.couponCode})` : ''}`} v={`− ${vnd(b.discount)}`} />}
        <Line k="Thuế VAT 10%" v={vnd(b.tax)} />
        <div className="border-t pt-2 text-base font-bold text-brand-900"><Line k="Tổng tiền thuê" v={vnd(b.totalAmount)} /></div>
        {b.securityDeposit != null && <p className="text-xs text-slate-500">Tiền cọc {vnd(b.securityDeposit)} chủ xe thu riêng.</p>}
      </section>
      <section className="rounded-2xl border bg-white p-5">
        <h2 className="mb-3 font-bold text-brand-900">Lịch sử trạng thái</h2>
        <ol className="space-y-2 border-l-2 border-road-500 pl-4 text-sm">
          {b.history.map((h, i) => (
            <li key={i}><span className="font-medium">{statusLabel[h.status] ?? h.status}</span> <span className="text-slate-500">· {fmtTime(h.at)}</span>{h.note && <p className="text-slate-600">{h.note}</p>}</li>
          ))}
        </ol>
      </section>
    </div>
  )
}

function Line({ k, v }: { k: string; v: string }) {
  return <div className="flex justify-between gap-3"><span>{k}</span><span>{v}</span></div>
}
