import { ChangeEvent, FormEvent, useEffect, useState } from 'react'
import { changeAvatar, deleteAddress, getProfile, listAddresses, saveAddress, updateProfile } from '../../api/minh'
import { errorMessage } from '../../api/client'
import Button from '../../components/Button'
import Input from '../../components/Input'
import { Textarea, Select } from '../../components/Field'
import Modal from '../../components/Modal'
import Spinner from '../../components/Spinner'
import Toast from '../../components/Toast'
import type { Address, Profile as ProfileT } from '../../types/minh'

const emptyAddr: Omit<Address, 'id'> = { label: '', receiver: '', phone: '', line: '', district: '', city: '', isDefault: false }

export default function Profile() {
  const [p, setP] = useState<ProfileT | null>(null)
  const [addrs, setAddrs] = useState<Address[]>([])
  const [saving, setSaving] = useState(false)
  const [msg, setMsg] = useState('')
  const [err, setErr] = useState('')
  const [edit, setEdit] = useState<(Omit<Address, 'id'> & { id?: number }) | null>(null)

  useEffect(() => { getProfile().then(setP); listAddresses().then(setAddrs) }, [])
  if (!p) return <Spinner />

  const set = <K extends keyof ProfileT>(k: K, v: ProfileT[K]) => setP({ ...p, [k]: v })

  async function saveProfile(e: FormEvent) {
    e.preventDefault(); setSaving(true)
    try { await updateProfile(p!); setMsg('Đã lưu hồ sơ') } catch (x) { setErr(errorMessage(x)) } finally { setSaving(false) }
  }

  async function onAvatar(e: ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return
    if (!file.type.startsWith('image/')) { setErr('Chỉ chấp nhận file ảnh'); return }
    if (file.size > 5 * 1024 * 1024) { setErr('Ảnh tối đa 5MB'); return }
    const url = URL.createObjectURL(file)
    await changeAvatar(url); set('avatarUrl', url); setMsg('Đã đổi ảnh đại diện')
  }

  async function submitAddr(e: FormEvent) {
    e.preventDefault()
    if (!edit) return
    setAddrs(await saveAddress(edit)); setEdit(null); setMsg('Đã lưu địa chỉ')
  }

  return (
    <div className="mx-auto max-w-4xl space-y-8">
      <h1 className="text-2xl font-bold">Hồ sơ cá nhân</h1>

      <form onSubmit={saveProfile} className="grid gap-6 rounded-xl border bg-white p-6 shadow-sm md:grid-cols-[180px_1fr]">
        <div className="flex flex-col items-center gap-3">
          <img src={p.avatarUrl} alt="avatar" className="h-32 w-32 rounded-full object-cover ring-4 ring-brand-100" />
          <label className="cursor-pointer rounded-lg border px-3 py-1.5 text-sm hover:bg-slate-50">
            Đổi ảnh
            <input type="file" accept="image/*" className="hidden" onChange={onAvatar} />
          </label>
          <p className="text-center text-xs text-slate-400">JPG, PNG tối đa 5MB</p>
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          <Input label="Họ và tên" value={p.fullName} onChange={(e) => set('fullName', e.target.value)} required />
          <Input label="Email (không đổi được)" value={p.email} disabled className="bg-slate-100" />
          <Input label="Số điện thoại" value={p.phone} onChange={(e) => set('phone', e.target.value)} />
          <Input label="Ngày sinh" type="date" value={p.dob} onChange={(e) => set('dob', e.target.value)} />
          <Select label="Giới tính" value={p.gender} onChange={(e) => set('gender', e.target.value as ProfileT['gender'])}>
            <option value="MALE">Nam</option><option value="FEMALE">Nữ</option><option value="OTHER">Khác</option>
          </Select>
          <div className="sm:col-span-2"><Textarea label="Giới thiệu" value={p.bio} onChange={(e) => set('bio', e.target.value)} /></div>
          <div className="sm:col-span-2 flex justify-end"><Button type="submit" loading={saving}>Lưu thay đổi</Button></div>
        </div>
      </form>

      <section>
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-lg font-semibold">Sổ địa chỉ</h2>
          <Button onClick={() => setEdit({ ...emptyAddr })}>+ Thêm địa chỉ</Button>
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          {addrs.map((a) => (
            <div key={a.id} className="rounded-xl border bg-white p-4 shadow-sm">
              <div className="mb-1 flex items-center gap-2">
                <span className="font-semibold">{a.label}</span>
                {a.isDefault && <span className="rounded-full bg-brand-100 px-2 py-0.5 text-xs font-semibold text-brand-700">Mặc định</span>}
              </div>
              <p className="text-sm">{a.receiver} • {a.phone}</p>
              <p className="text-sm text-slate-500">{a.line}, {a.district}, {a.city}</p>
              <div className="mt-3 flex gap-2">
                <Button variant="secondary" onClick={() => setEdit(a)}>Sửa</Button>
                <Button variant="danger" onClick={async () => { if (confirm('Xóa địa chỉ này?')) { setAddrs(await deleteAddress(a.id)); setMsg('Đã xóa địa chỉ') } }}>Xóa</Button>
              </div>
            </div>
          ))}
          {addrs.length === 0 && <p className="text-sm text-slate-500">Chưa có địa chỉ nào.</p>}
        </div>
      </section>

      <Modal open={!!edit} title={edit?.id ? 'Sửa địa chỉ' : 'Thêm địa chỉ'} onClose={() => setEdit(null)}>
        {edit && (
          <form onSubmit={submitAddr} className="space-y-3">
            <Input label="Tên gợi nhớ (Nhà, Công ty…)" value={edit.label} onChange={(e) => setEdit({ ...edit, label: e.target.value })} required />
            <div className="grid grid-cols-2 gap-3">
              <Input label="Người nhận" value={edit.receiver} onChange={(e) => setEdit({ ...edit, receiver: e.target.value })} required />
              <Input label="Số điện thoại" value={edit.phone} onChange={(e) => setEdit({ ...edit, phone: e.target.value })} required />
            </div>
            <Input label="Số nhà, đường" value={edit.line} onChange={(e) => setEdit({ ...edit, line: e.target.value })} required />
            <div className="grid grid-cols-2 gap-3">
              <Input label="Quận / Huyện" value={edit.district} onChange={(e) => setEdit({ ...edit, district: e.target.value })} required />
              <Input label="Tỉnh / Thành phố" value={edit.city} onChange={(e) => setEdit({ ...edit, city: e.target.value })} required />
            </div>
            <label className="flex items-center gap-2 text-sm">
              <input type="checkbox" checked={edit.isDefault} onChange={(e) => setEdit({ ...edit, isDefault: e.target.checked })} /> Đặt làm địa chỉ mặc định
            </label>
            <div className="flex justify-end gap-2"><Button variant="secondary" type="button" onClick={() => setEdit(null)}>Hủy</Button><Button type="submit">Lưu</Button></div>
          </form>
        )}
      </Modal>

      {msg && <Toast text={msg} onDone={() => setMsg('')} />}
      {err && <Toast type="error" text={err} onDone={() => setErr('')} />}
    </div>
  )
}
