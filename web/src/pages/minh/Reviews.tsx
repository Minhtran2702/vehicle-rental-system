import { FormEvent, useEffect, useState } from 'react'
import { listMyReviews, listPendingReviews, submitReview } from '../../api/minh'
import { errorMessage } from '../../api/client'
import Button from '../../components/Button'
import Modal from '../../components/Modal'
import Spinner from '../../components/Spinner'
import StarRating from '../../components/StarRating'
import Toast from '../../components/Toast'
import { Textarea } from '../../components/Field'
import type { MyReview, PendingReview } from '../../types/minh'

const hints = ['', 'Rất tệ', 'Chưa tốt', 'Bình thường', 'Hài lòng', 'Tuyệt vời']

export default function Reviews() {
  const [pending, setPending] = useState<PendingReview[] | null>(null)
  const [mine, setMine] = useState<MyReview[]>([])
  const [target, setTarget] = useState<PendingReview | null>(null)
  const [rating, setRating] = useState(5)
  const [comment, setComment] = useState('')
  const [msg, setMsg] = useState('')
  const [err, setErr] = useState('')

  const load = () => { listPendingReviews().then(setPending); listMyReviews().then(setMine) }
  useEffect(load, [])
  if (!pending) return <Spinner />

  async function submit(e: FormEvent) {
    e.preventDefault()
    if (!target) return
    if (comment.trim().length < 10) { setErr('Nhận xét tối thiểu 10 ký tự'); return }
    try { await submitReview(target.bookingId, rating, comment); setMsg('Cảm ơn bạn đã đánh giá!'); setTarget(null); setComment(''); setRating(5); load() }
    catch (x) { setErr(errorMessage(x)) }
  }

  return (
    <div className="mx-auto max-w-4xl space-y-8">
      <h1 className="text-2xl font-bold">Đánh giá chuyến thuê</h1>

      <section>
        <h2 className="mb-3 text-lg font-semibold">Chờ bạn đánh giá ({pending.length})</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          {pending.map((p) => (
            <div key={p.bookingId} className="flex gap-3 overflow-hidden rounded-xl border bg-white p-3 shadow-sm">
              <img src={p.imageUrl} alt="" className="h-20 w-28 rounded-lg object-cover" />
              <div className="flex-1">
                <p className="font-semibold">{p.vehicleName}</p>
                <p className="text-xs text-slate-500">{p.from} → {p.to}</p>
                <Button className="mt-2" onClick={() => setTarget(p)}>Viết đánh giá</Button>
              </div>
            </div>
          ))}
          {pending.length === 0 && <p className="text-sm text-slate-500">Bạn đã đánh giá hết các chuyến thuê.</p>}
        </div>
      </section>

      <section>
        <h2 className="mb-3 text-lg font-semibold">Đánh giá của tôi ({mine.length})</h2>
        <div className="space-y-3">
          {mine.map((r) => (
            <div key={r.id} className="rounded-xl border bg-white p-4 shadow-sm">
              <div className="flex items-center justify-between"><p className="font-semibold">{r.vehicleName}</p><span className="text-xs text-slate-400">{r.createdAt}</span></div>
              <StarRating value={r.rating} size="text-base" />
              <p className="mt-1 text-sm text-slate-600">{r.comment}</p>
            </div>
          ))}
        </div>
      </section>

      <Modal open={!!target} title={`Đánh giá ${target?.vehicleName ?? ''}`} onClose={() => setTarget(null)}>
        <form onSubmit={submit} className="space-y-4">
          <div className="text-center">
            <StarRating value={rating} onChange={setRating} size="text-4xl" />
            <p className="mt-1 text-sm text-slate-500">{hints[rating]}</p>
          </div>
          <Textarea label="Nhận xét của bạn" value={comment} onChange={(e) => setComment(e.target.value)} placeholder="Xe sạch không? Chủ xe có thân thiện? Giao nhận đúng hẹn?" />
          <div className="flex justify-end gap-2"><Button type="button" variant="secondary" onClick={() => setTarget(null)}>Hủy</Button><Button type="submit">Gửi đánh giá</Button></div>
        </form>
      </Modal>
      {msg && <Toast text={msg} onDone={() => setMsg('')} />}
      {err && <Toast type="error" text={err} onDone={() => setErr('')} />}
    </div>
  )
}
