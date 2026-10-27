const colors: Record<string, string> = {
  PENDING: 'bg-amber-100 text-amber-800',
  CONFIRMED: 'bg-blue-100 text-blue-800',
  IN_PROGRESS: 'bg-indigo-100 text-indigo-800',
  COMPLETED: 'bg-green-100 text-green-800',
  CANCELLED: 'bg-slate-200 text-slate-700',
  REJECTED: 'bg-red-100 text-red-800',
  ACTIVE: 'bg-green-100 text-green-800',
  INACTIVE: 'bg-slate-200 text-slate-700',
  MAINTENANCE: 'bg-orange-100 text-orange-800',
  PAID: 'bg-green-100 text-green-800',
  REFUNDED: 'bg-purple-100 text-purple-800',
}

/** Nhãn trạng thái (đơn đặt xe, xe, thanh toán…). Truyền status viết hoa như trong DB. */
export default function Badge({ status, label }: { status: string; label?: string }) {
  return (
    <span className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-semibold ${colors[status] ?? 'bg-slate-100 text-slate-700'}`}>
      {label ?? status}
    </span>
  )
}
