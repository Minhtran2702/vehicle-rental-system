import { useEffect, useMemo, useState } from 'react'
import { listAudit } from '../../api/minh'
import DataTable from '../../components/DataTable'
import Modal from '../../components/Modal'
import Spinner from '../../components/Spinner'
import type { AuditLog } from '../../types/minh'

export default function AuditLogs() {
  const [logs, setLogs] = useState<AuditLog[] | null>(null)
  const [q, setQ] = useState('')
  const [entity, setEntity] = useState('ALL')
  const [sel, setSel] = useState<AuditLog | null>(null)

  useEffect(() => { listAudit().then(setLogs) }, [])
  const entities = useMemo(() => ['ALL', ...Array.from(new Set((logs ?? []).map((l) => l.entity)))], [logs])
  if (!logs) return <Spinner />

  const rows = logs.filter((l) => (entity === 'ALL' || l.entity === entity) && (`${l.actor} ${l.action}`.toLowerCase().includes(q.toLowerCase())))

  return (
    <div>
      <h1 className="mb-1 text-2xl font-bold">Nhật ký audit</h1>
      <p className="mb-4 text-sm text-slate-500">Ghi lại các thao tác nhạy cảm: đổi trạng thái, khóa tài khoản, thanh toán, sửa coupon…</p>
      <div className="mb-4 flex flex-wrap gap-3">
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Tìm theo người thực hiện hoặc hành động…" className="w-72 rounded-lg border px-3 py-2 text-sm" />
        <select value={entity} onChange={(e) => setEntity(e.target.value)} className="rounded-lg border px-3 py-2 text-sm">
          {entities.map((e) => <option key={e} value={e}>{e === 'ALL' ? 'Tất cả đối tượng' : e}</option>)}
        </select>
      </div>
      <DataTable
        rows={rows} rowKey={(l) => l.id}
        columns={[
          { header: 'Thời gian', render: (l) => l.time },
          { header: 'Người thực hiện', render: (l) => l.actor },
          { header: 'Hành động', render: (l) => <code className="rounded bg-slate-100 px-1.5 py-0.5 text-xs">{l.action}</code> },
          { header: 'Đối tượng', render: (l) => `${l.entity} #${l.entityId}` },
          { header: 'IP', render: (l) => l.ip },
          { header: '', render: (l) => <button className="text-sm text-brand-600" onClick={() => setSel(l)}>Chi tiết</button> },
        ]}
      />
      <Modal open={!!sel} title={`Chi tiết #${sel?.id ?? ''}`} onClose={() => setSel(null)}>
        {sel && (
          <div className="grid gap-3 text-sm sm:grid-cols-2">
            <div><p className="mb-1 font-semibold text-slate-600">Trước</p><pre className="overflow-auto rounded-lg bg-red-50 p-3 text-xs">{JSON.stringify(sel.before, null, 2) ?? 'null'}</pre></div>
            <div><p className="mb-1 font-semibold text-slate-600">Sau</p><pre className="overflow-auto rounded-lg bg-green-50 p-3 text-xs">{JSON.stringify(sel.after, null, 2) ?? 'null'}</pre></div>
          </div>
        )}
      </Modal>
    </div>
  )
}
