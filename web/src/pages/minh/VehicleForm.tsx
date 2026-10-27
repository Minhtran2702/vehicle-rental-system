import { ChangeEvent, FormEvent, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { createVehicle } from '../../api/minh'
import { errorMessage } from '../../api/client'
import { ALL_FEATURES, BRANDS, CATEGORIES } from '../../mocks/minh'
import Button from '../../components/Button'
import Input from '../../components/Input'
import { Select, Textarea } from '../../components/Field'
import type { VehicleDraft, VehicleLocation } from '../../types/minh'

/** Thông tin cơ bản của xe – dùng cho form đăng xe (nhiều bước) và tab "Thông tin" khi sửa xe. */
export function VehicleInfoFields({ d, set, errors }: {
  d: VehicleDraft; set: (d: VehicleDraft) => void; errors: Record<string, string>
}) {
  const num = (k: 'year' | 'seats' | 'pricePerDay' | 'deposit') => (e: ChangeEvent<HTMLInputElement>) => set({ ...d, [k]: Number(e.target.value) })
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <div className="sm:col-span-2"><Input label="Tên xe (ví dụ: Toyota Vios 2022)" value={d.name} onChange={(e) => set({ ...d, name: e.target.value })} error={errors.name} /></div>
      <Select label="Hãng xe" value={d.brand} onChange={(e) => set({ ...d, brand: e.target.value })}>{BRANDS.map((b) => <option key={b}>{b}</option>)}</Select>
      <Select label="Loại xe" value={d.category} onChange={(e) => set({ ...d, category: e.target.value })}>{CATEGORIES.map((c) => <option key={c}>{c}</option>)}</Select>
      <Input label="Biển số" value={d.plate} onChange={(e) => set({ ...d, plate: e.target.value.toUpperCase() })} error={errors.plate} />
      <Input label="Năm sản xuất" type="number" value={d.year} onChange={num('year')} error={errors.year} />
      <Input label="Số chỗ ngồi" type="number" value={d.seats} onChange={num('seats')} error={errors.seats} />
      <Select label="Hộp số" value={d.transmission} onChange={(e) => set({ ...d, transmission: e.target.value as VehicleDraft['transmission'] })}>
        <option value="AUTO">Số tự động</option><option value="MANUAL">Số sàn</option>
      </Select>
      <Select label="Nhiên liệu" value={d.fuel} onChange={(e) => set({ ...d, fuel: e.target.value as VehicleDraft['fuel'] })}>
        <option value="GASOLINE">Xăng</option><option value="DIESEL">Dầu</option><option value="ELECTRIC">Điện</option><option value="HYBRID">Hybrid</option>
      </Select>
      <Input label="Giá thuê / ngày (VNĐ)" type="number" value={d.pricePerDay} onChange={num('pricePerDay')} error={errors.pricePerDay} />
      <Input label="Tiền đặt cọc (VNĐ)" type="number" value={d.deposit} onChange={num('deposit')} error={errors.deposit} />
      <div className="sm:col-span-2"><Textarea label="Mô tả" value={d.description} onChange={(e) => set({ ...d, description: e.target.value })} /></div>
    </div>
  )
}

export function validateDraft(d: VehicleDraft) {
  const e: Record<string, string> = {}
  if (d.name.trim().length < 3) e.name = 'Vui lòng nhập tên xe'
  if (!/^\d{2}[A-Z]{1,2}\d?-\d{3}\.\d{2}$/i.test(d.plate)) e.plate = 'Biển số dạng 51K-123.45'
  if (d.year < 1990 || d.year > new Date().getFullYear() + 1) e.year = 'Năm sản xuất không hợp lệ'
  if (d.seats < 1 || d.seats > 16) e.seats = 'Số chỗ từ 1 đến 16'
  if (d.pricePerDay < 50000) e.pricePerDay = 'Giá tối thiểu 50.000đ'
  if (d.deposit < 0) e.deposit = 'Tiền cọc không hợp lệ'
  return e
}

export function FeaturePicker({ value, onChange }: { value: string[]; onChange: (v: string[]) => void }) {
  const toggle = (f: string) => onChange(value.includes(f) ? value.filter((x) => x !== f) : [...value, f])
  return (
    <div className="flex flex-wrap gap-2">
      {ALL_FEATURES.map((f) => (
        <button type="button" key={f} onClick={() => toggle(f)}
          className={`rounded-full border px-3 py-1.5 text-sm ${value.includes(f) ? 'border-brand-600 bg-brand-50 text-brand-700' : 'bg-white hover:bg-slate-50'}`}>
          {value.includes(f) ? '✓ ' : ''}{f}
        </button>
      ))}
    </div>
  )
}

export function LocationFields({ loc, set }: { loc: VehicleLocation; set: (l: VehicleLocation) => void }) {
  const bbox = `${loc.lng - 0.01},${loc.lat - 0.007},${loc.lng + 0.01},${loc.lat + 0.007}`
  return (
    <div className="grid gap-4 md:grid-cols-2">
      <div className="space-y-3">
        <Input label="Địa chỉ nhận xe" value={loc.address} onChange={(e) => set({ ...loc, address: e.target.value })} />
        <Input label="Tỉnh / Thành phố" value={loc.city} onChange={(e) => set({ ...loc, city: e.target.value })} />
        <div className="grid grid-cols-2 gap-3">
          <Input label="Vĩ độ" type="number" step="0.0001" value={loc.lat} onChange={(e) => set({ ...loc, lat: Number(e.target.value) })} />
          <Input label="Kinh độ" type="number" step="0.0001" value={loc.lng} onChange={(e) => set({ ...loc, lng: Number(e.target.value) })} />
        </div>
        <Textarea label="Ghi chú nhận / trả xe" value={loc.pickupNote} onChange={(e) => set({ ...loc, pickupNote: e.target.value })} />
      </div>
      <iframe title="Bản đồ" className="h-72 w-full rounded-xl border"
        src={`https://www.openstreetmap.org/export/embed.html?bbox=${bbox}&layer=mapnik&marker=${loc.lat},${loc.lng}`} />
    </div>
  )
}

export const emptyDraft: VehicleDraft = {
  name: '', brand: 'Toyota', category: 'Sedan', plate: '', year: 2022, seats: 5, transmission: 'AUTO', fuel: 'GASOLINE',
  pricePerDay: 700000, deposit: 3000000, description: '', status: 'ACTIVE',
}
export const emptyLoc: VehicleLocation = { address: '', city: 'TP. Hồ Chí Minh', lat: 10.7769, lng: 106.7009, pickupNote: '' }

const STEPS = ['Thông tin', 'Hình ảnh', 'Tiện ích', 'Vị trí']

/** Đăng xe mới: 4 bước. */
export default function VehicleForm() {
  const navigate = useNavigate()
  const [step, setStep] = useState(0)
  const [d, setD] = useState<VehicleDraft>(emptyDraft)
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [images, setImages] = useState<string[]>([])
  const [features, setFeatures] = useState<string[]>([])
  const [loc, setLoc] = useState<VehicleLocation>(emptyLoc)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  function onFiles(e: ChangeEvent<HTMLInputElement>) {
    const files = Array.from<File>(e.target.files ?? []).filter((f: File) => f.type.startsWith('image/') && f.size <= 5 * 1024 * 1024)
    setImages((cur) => [...cur, ...files.map((f: File) => URL.createObjectURL(f))].slice(0, 10))
    e.target.value = ''
  }

  function next() {
    setError('')
    if (step === 0) { const e = validateDraft(d); setErrors(e); if (Object.keys(e).length) return }
    if (step === 1 && images.length < 1) { setError('Cần ít nhất 1 ảnh xe'); return }
    setStep(step + 1)
  }

  async function submit(ev: FormEvent) {
    ev.preventDefault()
    if (!loc.address.trim()) { setError('Vui lòng nhập địa chỉ nhận xe'); return }
    setLoading(true); setError('')
    try { const v = await createVehicle(d, images, features, loc); navigate(`/my-vehicles/${v.id}`) }
    catch (x) { setError(errorMessage(x)) } finally { setLoading(false) }
  }

  return (
    <form onSubmit={submit} className="mx-auto max-w-3xl">
      <h1 className="mb-4 text-2xl font-bold">Đăng xe cho thuê</h1>
      <ol className="mb-6 flex items-center gap-2 text-sm">
        {STEPS.map((s, i) => (
          <li key={s} className="flex flex-1 items-center gap-2">
            <span className={`flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold ${i <= step ? 'bg-brand-600 text-white' : 'bg-slate-200 text-slate-500'}`}>{i + 1}</span>
            <span className={i === step ? 'font-semibold' : 'text-slate-500'}>{s}</span>
            {i < STEPS.length - 1 && <span className="h-px flex-1 bg-slate-300" />}
          </li>
        ))}
      </ol>

      <div className="rounded-xl border bg-white p-6 shadow-sm">
        {step === 0 && <VehicleInfoFields d={d} set={setD} errors={errors} />}
        {step === 1 && (
          <div>
            <p className="mb-3 text-sm text-slate-500">Tải tối đa 10 ảnh (JPG/PNG ≤ 5MB). Ảnh đầu tiên là ảnh bìa.</p>
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
              {images.map((u, i) => (
                <div key={u} className="relative">
                  <img src={u} alt="" className="h-28 w-full rounded-lg object-cover" />
                  {i === 0 && <span className="absolute left-1 top-1 rounded bg-brand-600 px-1.5 text-[10px] text-white">Ảnh bìa</span>}
                  <button type="button" onClick={() => setImages(images.filter((x) => x !== u))} className="absolute right-1 top-1 rounded-full bg-black/60 px-1.5 text-xs text-white">✕</button>
                </div>
              ))}
              {images.length < 10 && (
                <label className="flex h-28 cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed text-sm text-slate-500 hover:bg-slate-50">
                  <span className="text-2xl">＋</span>Thêm ảnh
                  <input type="file" accept="image/*" multiple className="hidden" onChange={onFiles} />
                </label>
              )}
            </div>
          </div>
        )}
        {step === 2 && (<div><p className="mb-3 text-sm text-slate-500">Chọn các tiện ích xe có sẵn.</p><FeaturePicker value={features} onChange={setFeatures} /></div>)}
        {step === 3 && <LocationFields loc={loc} set={setLoc} />}
        {error && <p className="mt-4 text-sm text-red-600">{error}</p>}
      </div>

      <div className="mt-4 flex justify-between">
        <Button type="button" variant="secondary" disabled={step === 0} onClick={() => setStep(step - 1)}>Quay lại</Button>
        {step < STEPS.length - 1
          ? <Button type="button" onClick={next}>Tiếp tục</Button>
          : <Button type="submit" loading={loading}>Đăng xe</Button>}
      </div>
    </form>
  )
}
