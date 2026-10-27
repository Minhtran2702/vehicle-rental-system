import { ReactNode } from 'react'

export interface Column<T> { header: string; render: (row: T) => ReactNode; className?: string }

export default function DataTable<T>({ columns, rows, rowKey, empty = 'Chưa có dữ liệu' }: {
  columns: Column<T>[]; rows: T[]; rowKey: (row: T) => string | number; empty?: string
}) {
  return (
    <div className="overflow-x-auto rounded-xl border bg-white">
      <table className="min-w-full text-left text-sm">
        <thead className="bg-slate-100 text-slate-600">
          <tr>{columns.map((c) => <th key={c.header} className={`px-4 py-3 font-semibold ${c.className ?? ''}`}>{c.header}</th>)}</tr>
        </thead>
        <tbody>
          {rows.length === 0 && <tr><td colSpan={columns.length} className="px-4 py-8 text-center text-slate-500">{empty}</td></tr>}
          {rows.map((r) => (
            <tr key={rowKey(r)} className="border-t hover:bg-slate-50">
              {columns.map((c) => <td key={c.header} className={`px-4 py-3 ${c.className ?? ''}`}>{c.render(r)}</td>)}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
