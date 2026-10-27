import { ChangeEvent, FormEvent, useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import {
  addImage, addMaintenance, deleteMaintenance, getMyVehicle, removeImage, saveFeatures, saveLocation,
  setPrimaryImage, setVehicleStatus, updateVehicle,
} from '../../api/minh'
import { errorMessage } from '../../api/client'
import Badge from '../../components/Badge'
import Button from '../../components/Button'
import DataTable from '../../components/DataTable'
import { vnd } from '../../components/CarCard'
import Input from '../../components/Input'
import { Textarea } from '../../components/Field'
import Modal from '../../components/Modal'
import Spinner from '../../components/Spinner'
import Toast from '../../components/Toast'
import type { MaintenanceRecord, OwnerVehicle, VehicleDraft, VehicleLocation } from '../../types/minh'
import { FeaturePicker, LocationFields, VehicleInfoFields, validateDraft } from './VehicleForm'

const TABS = ['Thông tin', 'Hình ảnh', 'Tiện ích', 'Vị trí', 'Bảo dưỡng'] as const
const statusLabel = { ACTIVE: 'Đang cho thuê', INACTIVE: 'Đang ẩn', MAINTENANCE: 'Đang bảo dưỡng' } as const

export default function VehicleManage() {
  const { id } = useParams()
  const [v, setV] = useState<OwnerVehicle | null>(null)
  const [tab, setTab] = useState<(typeof TABS)[number]>('Thông tin')
  const [msg, setMsg] = useState('')
  const [err, setErr] = useState('')

  useEffect(() => { getMyVehicle(Number(id)).then(setV).catch((e) => setErr(errorMessage(e))) }, [id])
  if (!v) return err ? <p className="text-red-600">{err}</p> : <Spinner />

  async function run(fn: () => Promise<OwnerVehicle>, ok: string) {
    try { setV(await fn()); setMsg(ok) } catch (e) { setErr(errorMessage(e)) }
  }

  return (
    <div>
      <Link to="/my-vehicles" className="text-sm text-brand-600">← Xe của tôi</Link>
      <div className="mb-4 mt-2 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <h1 className="text-2xl font-bold">{v.name}</h1>
          <Badge status={v.status} label={statusLabel[v.status]} />
        </div>
        <select value={v.status} onChange={(e) => run(() => setVehicleStatus(v.id, e.target.value as OwnerVehicle['status']), 'Đã đổi trạng thái')}
          className="rounded-lg border px-3 py-2 text-sm">
          <option value="ACTIVE">Đang cho thuê</option><option value="INACTIVE">Ẩn tin</option><option value="MAINTENANCE">Đang bảo dưỡng</option>
        </select>
      </div>

      <div className="mb-5 flex gap-1 overflow-x-auto border-b">
        {TABS.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`whitespace-nowrap px-4 py-2 text-sm font-medium ${tab === t ? 'border-b-2 border-brand-600 text-brand-700' : 'text-slate-500 hover:text-slate-800'}`}>{t}</button>
        ))}
      </div>

      {tab === 'Thông tin' && <InfoTab v={v} onSave={(d) => run(() => updateVehicle(v.id, d), 'Đã lưu thông tin xe')} />}
      {tab === 'Hình ảnh' && <ImagesTab v={v} run={run} />}
      {tab === 'Tiện ích' && <FeaturesTab v={v} onSave={(f) => run(() => saveFeatures(v.id, f), 'Đã lưu tiện ích')} />}
      {tab === 'Vị trí' && <LocationTab v={v} onSave={(l) => run(() => saveLocation(v.id, l), 'Đã lưu vị trí')} />}
      {tab === 'Bảo dưỡng' && <MaintenanceTab v={v} run={run} />}

      {msg && <Toast text={msg} onDone={() => setMsg('')} />}
      {err && <Toast type="error" text={err} onDone={() => setErr('')} />}
    </div>
  )
}

type Run = (fn: () => Promise<OwnerVehicle>, ok: string) => Promise<void>

function InfoTab({ v, onSave }: { v: OwnerVehicle; onSave: (d: VehicleDraft) => void }) {
  const { id: _i, images: _im, features: _f, location: _l, maintenance: _m, ...initial } = v
  const [d, setD] = useState<VehicleDraft>(initial)
  const [errors, setErrors] = useState<Record<string, string>>({})
  function submit(e: FormEvent) { e.preventDefault(); const er = validateDraft(d); setErrors(er); if (!Object.keys(er).length) onSave(d) }
  return (
    <form onSubmit={submit} className="rounded-xl border bg-white p-6 shadow-sm">
      <VehicleInfoFields d={d} set={setD} errors={errors} />
      <div className="mt-4 flex justify-end"><Button type="submit">Lưu thay đổi</Button></div>
    </form>
  )
}

function ImagesTab({ v, run }: { v: OwnerVehicle; run: Run }) {
  function onFiles(e: ChangeEvent<HTMLInputElement>) {
    const files = Array.from<File>(e.target.files ?? []).filter((f: File) => f.type.startsWith('image/') && f.size <= 5 * 1024 * 1024)
    files.forEach((f: File) => run(() => addImage(v.id, URL.createObjectURL(f)), 'Đã thêm ảnh'))
    e.target.value = ''
  }
  return (
    <div className="rounded-xl border bg-white p-6 shadow-sm">
      <p className="mb-3 text-sm text-slate-500">{v.images.length}/10 ảnh. Bấm "Đặt làm ảnh bìa" để đổi ảnh hiển thị đầu tiên.</p>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
        {v.images.map((i) => (
          <div key={i.id} className="overflow-hidden rounded-lg border">
            <div className="relative">
              <img src={i.url} alt="" className="h-32 w-full object-cover" />
              {i.isPrimary && <span className="absolute left-1 top-1 rounded bg-brand-600 px-1.5 text-[10px] text-white">Ảnh bìa</span>}
            </div>
            <div className="flex justify-between p-2 text-xs">
              {!i.isPrimary ? <button className="text-brand-600" onClick={() => run(() => setPrimaryImage(v.id, i.id), 'Đã đổi ảnh bìa')}>Đặt làm ảnh bìa</button> : <span />}
              <button className="text-red-600" onClick={() => { if (confirm('Xóa ảnh này?')) run(() => removeImage(v.id, i.id), 'Đã xóa ảnh') }}>Xóa</button>
            </div>
          </div>
        ))}
        {v.images.length < 10 && (
          <label className="flex h-40 cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed text-sm text-slate-500 hover:bg-slate-50">
            <span className="text-2xl">＋</span>Thêm ảnh
            <input type="file" accept="image/*" multiple className="hidden" onChange={onFiles} />
          </label>
        )}
      </div>
    </div>
  )
}

function FeaturesTab({ v, onSave }: { v: OwnerVehicle; onSave: (f: string[]) => void }) {
  const [f, setF] = useState(v.features)
  return (
    <div className="rounded-xl border bg-white p-6 shadow-sm">
      <FeaturePicker value={f} onChange={setF} />
      <div className="mt-4 flex items-center justify-between"><span className="text-sm text-slate-500">Đã chọn {f.length} tiện ích</span><Button onClick={() => onSave(f)}>Lưu tiện ích</Button></div>
    </div>
  )
}

function LocationTab({ v, onSave }: { v: OwnerVehicle; onSave: (l: VehicleLocation) => void }) {
  const [l, setL] = useState(v.location)
  return (
    <div className="rounded-xl border bg-white p-6 shadow-sm">
      <LocationFields loc={l} set={setL} />
      <div className="mt-4 flex justify-end"><Button onClick={() => onSave(l)}>Lưu vị trí</Button></div>
    </div>
  )
}

const TYPES = ['Thay dầu nhớt', 'Kiểm tra phanh', 'Thay lốp', 'Bảo dưỡng định kỳ', 'Sửa chữa', 'Rửa xe – vệ sinh', 'Khác']

function MaintenanceTab({ v, run }: { v: OwnerVehicle; run: Run }) {
  const [open, setOpen] = useState(false)
  const [f, setF] = useState<Omit<MaintenanceRecord, 'id'>>({ date: new Date().toISOString().slice(0, 10), type: TYPES[0], cost: 0, odometer: 0, note: '' })
  const total = v.maintenance.reduce((s, m) => s + m.cost, 0)

  async function submit(e: FormEvent) { e.preventDefault(); await run(() => addMaintenance(v.id, f), 'Đã thêm bản ghi bảo dưỡng'); setOpen(false) }

  return (
    <div>
      <div className="mb-3 flex items-center justify-between">
        <p className="text-sm text-slate-500">{v.maintenance.length} lần bảo dưỡng • Tổng chi phí <b>{vnd(total)}</b></p>
        <Button onClick={() => setOpen(true)}>+ Thêm bản ghi</Button>
      </div>
      <DataTable
        rows={v.maintenance} rowKey={(m) => m.id} empty="Chưa có lịch sử bảo dưỡng"
        columns={[
          { header: 'Ngày', render: (m) => m.date },
          { header: 'Hạng mục', render: (m) => m.type },
          { header: 'Số km', render: (m) => m.odometer.toLocaleString('vi-VN') },
          { header: 'Chi phí', render: (m) => vnd(m.cost) },
          { header: 'Ghi chú', render: (m) => m.note || '—' },
          { header: '', render: (m) => <button className="text-sm text-red-600" onClick={() => { if (confirm('Xóa bản ghi này?')) run(() => deleteMaintenance(v.id, m.id), 'Đã xóa bản ghi') }}>Xóa</button> },
        ]}
      />
      <Modal open={open} title="Thêm bản ghi bảo dưỡng" onClose={() => setOpen(false)}>
        <form onSubmit={submit} className="space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <Input label="Ngày" type="date" value={f.date} onChange={(e) => setF({ ...f, date: e.target.value })} required />
            <label className="block text-sm"><span className="mb-1 block font-medium text-slate-700">Hạng mục</span>
              <select value={f.type} onChange={(e) => setF({ ...f, type: e.target.value })} className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">{TYPES.map((t) => <option key={t}>{t}</option>)}</select>
            </label>
            <Input label="Số km hiện tại" type="number" value={f.odometer} onChange={(e) => setF({ ...f, odometer: Number(e.target.value) })} />
            <Input label="Chi phí (VNĐ)" type="number" value={f.cost} onChange={(e) => setF({ ...f, cost: Number(e.target.value) })} />
          </div>
          <Textarea label="Ghi chú" value={f.note} onChange={(e) => setF({ ...f, note: e.target.value })} />
          <div className="flex justify-end gap-2"><Button type="button" variant="secondary" onClick={() => setOpen(false)}>Hủy</Button><Button type="submit">Lưu</Button></div>
        </form>
      </Modal>
    </div>
  )
}
