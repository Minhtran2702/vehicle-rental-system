interface Props { page: number; totalPages: number; onChange: (page: number) => void }

/** page bắt đầu từ 0 (giống backend). */
export default function Pagination({ page, totalPages, onChange }: Props) {
  if (totalPages <= 1) return null
  return (
    <div className="mt-6 flex items-center justify-center gap-3 text-sm">
      <button disabled={page === 0} onClick={() => onChange(page - 1)} className="rounded border px-3 py-1 disabled:opacity-40">Trước</button>
      <span>Trang {page + 1} / {totalPages}</span>
      <button disabled={page >= totalPages - 1} onClick={() => onChange(page + 1)} className="rounded border px-3 py-1 disabled:opacity-40">Sau</button>
    </div>
  )
}
