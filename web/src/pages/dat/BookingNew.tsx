import { FormEvent, useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Availability, Quote, checkAvailability, createBooking, getQuote } from '../../api/dat'
import { errorMessage } from '../../api/client'
import Button from '../../components/Button'
import Toast from '../../components/Toast'
import { vnd } from '../../components/CarCard'

const fmt = (iso: string) => new Date(iso).toLocaleString('vi-VN', { dateStyle: 'short', timeStyle: 'short' })

/** Đặt xe: chọn giờ nhận/trả, thấy giá tạm tính ngay, áp mã giảm giá rồi gửi yêu cầu cho chủ xe. */
export default function BookingNew() {
  const { vehicleId } = useParams()
  const navigate = useNavigate()
  const [from, setFrom] = useState('')
  const [to, setTo] = useState('')
  const [pickup, setPickup] = useState('')
  const [dropoff, setDropoff] = useState('')
  const [coupon, setCoupon] = useState('')
  const [appliedCoupon, setAppliedCoupon] = useState('')
  const [quote, setQuote] = useState<Quote | null>(null)
  const [avail, setAvail] = useState<Availability | null>(null)
  const [quoteErr, setQuoteErr] = useState('')
  const [busy, setBusy] = useState(false)
  const [err, setErr] = useState('')

  // Lịch bận của xe (xem ngay khi vào trang)
  useEffect(() => { if (vehicleId) checkAvailability(vehicleId).then(setAvail).catch((e) => setErr(errorMessage(e))) }, [vehicleId])

  // Có đủ giờ nhận/trả thì kiểm tra xe trống và tính giá
  useEffect(() => {
    if (!vehicleId || !from || !to) { setQuote(null); return }
    let alive = true
    setQuoteErr('')
    checkAvailability(vehicleId, from, to).then((a) => { if (alive) setAvail(a) }).catch(() => {})
    getQuote({ vehicleId, pickupDatetime: from, returnDatetime: to, couponCode: appliedCoupon })
      .then((q) => { if (alive) setQuote(q) })
      .catch((e) => { if (alive) { setQuote(null); setQuoteErr(errorMessage(e)) } })
    return () => { alive = false }
  }, [vehicleId, from, to, appliedCoupon])

  async function submit(e: FormEvent) {
    e.preventDefault()
    if (!vehicleId) return
    setBusy(true); setErr('')
    try {
      const b = await createBooking({ vehicleId, pickupDatetime: from, returnDatetime: to, pickupLocation: pickup, returnLocation: dropoff, couponCode: appliedCoupon })
      navigate(`/bookings/${b.id}`)
    } catch (e2) { setErr(errorMessage(e2)) } finally { setBusy(false) }
  }

  const blocked = avail && !avail.available && from && to
  const input = 'w-full rounded-lg border border-slate-300 px-3 py-2 text-sm'

  return (
    <div className="mx-auto max-w-4xl">
      <h1 className="mb-4 text-2xl font-extrabold text-brand-900">Đặt xe</h1>
      <div className="grid gap-6 md:grid-cols-[1.2fr_1fr]">
        <form onSubmit={submit} className="space-y-4 rounded-2xl border bg-white p-5">
          <div className="grid gap-3 sm:grid-cols-2">
            <label className="block text-sm"><span className="mb-1 block font-medium text-slate-700">Nhận xe lúc</span>
              <input type="datetime-local" required value={from} onChange={(e) => setFrom(e.target.value)} className={input} /></label>
            <label className="block text-sm"><span className="mb-1 block font-medium text-slate-700">Trả xe lúc</span>
              <input type="datetime-local" required min={from} value={to} onChange={(e) => setTo(e.target.value)} className={input} /></label>
          </div>
          <label className="block text-sm"><span className="mb-1 block font-medium text-slate-700">Nơi nhận xe</span>
            <input value={pickup} onChange={(e) => setPickup(e.target.value)} placeholder="Để trống = nhận tại chủ xe" className={input} /></label>
          <label className="block text-sm"><span className="mb-1 block font-medium text-slate-700">Nơi trả xe</span>
            <input value={dropoff} onChange={(e) => setDropoff(e.target.value)} placeholder="Để trống = trả tại chủ xe" className={input} /></label>
          <div className="flex items-end gap-2">
            <label className="block flex-1 text-sm"><span className="mb-1 block font-medium text-slate-700">Mã giảm giá</span>
              <input value={coupon} onChange={(e) => setCoupon(e.target.value.toUpperCase())} placeholder="VD: WELCOME10" className={input} /></label>
            <Button type="button" variant="secondary" onClick={() => setAppliedCoupon(coupon.trim())}>Áp dụng</Button>
          </div>

          {blocked && <p className="rounded-lg bg-red-50 p-3 text-sm text-red-700">{avail!.reason}</p>}
          {quoteErr && <p className="rounded-lg bg-amber-50 p-3 text-sm text-amber-800">{quoteErr}</p>}
          {avail && avail.busy.length > 0 && (
            <div className="text-sm text-slate-600">
              <p className="font-medium text-slate-700">Xe đã có lịch:</p>
              <ul className="mt-1 list-disc pl-5">{avail.busy.map((b, i) => <li key={i}>{fmt(b.from)} → {fmt(b.to)}</li>)}</ul>
            </div>
          )}
          <Button type="submit" loading={busy} disabled={!quote || !!blocked} className="w-full !py-3">Gửi yêu cầu đặt xe</Button>
        </form>

        <aside className="h-fit rounded-2xl border bg-white p-5">
          <h2 className="mb-3 font-bold text-brand-900">Tạm tính</h2>
          {!quote ? <p className="text-sm text-slate-500">Chọn giờ nhận và trả xe để xem giá.</p> : (
            <dl className="space-y-2 text-sm">
              <p className="font-semibold">{quote.vehicleName}</p>
              <Row k={`${vnd(quote.pricePerDay)} × ${quote.totalDays} ngày`} v={vnd(quote.subtotal)} />
              {quote.discount > 0 && <Row k={`Giảm giá (${quote.couponCode})`} v={`− ${vnd(quote.discount)}`} />}
              <Row k="Thuế VAT 10%" v={vnd(quote.tax)} />
              <div className="border-t pt-2"><Row k="Tổng tiền thuê" v={vnd(quote.totalAmount)} bold /></div>
              <p className="text-xs text-slate-500">Tiền cọc {vnd(quote.securityDeposit)} chủ xe thu riêng, chưa tính vào tổng.</p>
            </dl>
          )}
        </aside>
      </div>
      {err && <Toast type="error" text={err} onDone={() => setErr('')} />}
    </div>
  )
}

function Row({ k, v, bold }: { k: string; v: string; bold?: boolean }) {
  return <div className={`flex justify-between gap-3 ${bold ? 'text-base font-bold text-brand-900' : ''}`}><dt>{k}</dt><dd>{v}</dd></div>
}
