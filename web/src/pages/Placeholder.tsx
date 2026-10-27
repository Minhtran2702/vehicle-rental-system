/** Trang tạm cho chức năng chưa làm. Thay bằng trang thật khi làm xong chức năng. */
export default function Placeholder({ title, owner }: { title: string; owner: string }) {
  return (
    <div className="rounded-xl border-2 border-dashed border-slate-300 bg-white p-10 text-center">
      <h1 className="mb-2 text-xl font-semibold">{title}</h1>
      <p className="text-sm text-slate-500">Chưa làm – phần của <b>{owner}</b></p>
    </div>
  )
}
