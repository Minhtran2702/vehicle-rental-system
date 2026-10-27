import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { listMyVehicles, setVehicleStatus } from '../../api/minh'
import Badge from '../../components/Badge'
import Button from '../../components/Button'
import Spinner from '../../components/Spinner'
import Toast from '../../components/Toast'
import { vnd } from '../../components/CarCard'
import type { OwnerVehicle, VehicleStatus } from '../../types/minh'

const statusLabel: Record<VehicleStatus, string> = { ACTIVE: 'Đang cho thuê', INACTIVE: 'Đang ẩn', MAINTENANCE: 'Đang bảo dưỡng' }

export default function MyVehicles() {
  const [items, setItems] = useState<OwnerVehicle[] | null>(null)
  const [filter, setFilter] = useState<'ALL' | VehicleStatus>('ALL')
  const [msg, setMsg] = useState('')

  useEffect(() => { listMyVehicles().then(setItems) }, [])
  if (!items) return <Spinner />

  const shown = filter === 'ALL' ? items : items.filter((v) => v.status === filter)

  async function toggle(v: OwnerVehicle) {
    const next: VehicleStatus = v.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'
    const updated = await setVehicleStatus(v.id, next)
    setItems((cur) => (cur ?? []).map((x) => (x.id === v.id ? updated : x)))
    setMsg(next === 'ACTIVE' ? 'Đã hiện tin đăng' : 'Đã ẩn tin đăng')
  }

  return (
    <div>
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Xe của tôi</h1>
          <p className="text-sm text-slate-500">{items.length} xe • {items.filter((v) => v.status === 'ACTIVE').length} xe đang cho thuê</p>
        </div>
        <Link to="/my-vehicles/new"><Button>+ Đăng xe mới</Button></Link>
      </div>

      <div className="mb-5 flex flex-wrap gap-2 text-sm">
        {(['ALL', 'ACTIVE', 'INACTIVE', 'MAINTENANCE'] as const).map((s) => (
          <button key={s} onClick={() => setFilter(s)}
            className={`rounded-full border px-3 py-1 ${filter === s ? 'border-brand-600 bg-brand-600 text-white' : 'bg-white hover:bg-slate-50'}`}>
            {s === 'ALL' ? 'Tất cả' : statusLabel[s]}
          </button>
        ))}
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        {shown.map((v) => {
          const cover = v.images.find((i) => i.isPrimary) ?? v.images[0]
          return (
            <div key={v.id} className="flex overflow-hidden rounded-xl border bg-white shadow-sm">
              <img src={cover?.url} alt={v.name} className="h-auto w-40 object-cover" />
              <div className="flex flex-1 flex-col p-4">
                <div className="mb-1 flex items-start justify-between gap-2">
                  <h3 className="font-semibold">{v.name}</h3>
                  <Badge status={v.status} label={statusLabel[v.status]} />
                </div>
                <p className="text-xs text-slate-500">{v.plate} • {v.seats} chỗ • {v.transmission === 'AUTO' ? 'Số tự động' : 'Số sàn'}</p>
                <p className="mt-1 font-bold text-brand-700">{vnd(v.pricePerDay)}<span className="text-xs font-normal text-slate-500"> / ngày</span></p>
                <div className="mt-auto flex gap-2 pt-3">
                  <Link to={`/my-vehicles/${v.id}`}><Button variant="secondary">Quản lý</Button></Link>
                  {v.status !== 'MAINTENANCE' && (
                    <Button variant="ghost" onClick={() => toggle(v)}>{v.status === 'ACTIVE' ? 'Ẩn tin' : 'Hiện tin'}</Button>
                  )}
                </div>
              </div>
            </div>
          )
        })}
        {shown.length === 0 && <p className="col-span-full rounded-xl border border-dashed bg-white p-10 text-center text-slate-500">Không có xe nào ở trạng thái này.</p>}
      </div>
      {msg && <Toast text={msg} onDone={() => setMsg('')} />}
    </div>
  )
}
