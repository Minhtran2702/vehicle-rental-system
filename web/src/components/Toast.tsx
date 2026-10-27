import { useEffect } from 'react'

/** Thông báo nhỏ góc phải, tự tắt sau 2,5 giây. Dùng: {msg && <Toast text={msg} onDone={() => setMsg('')} />} */
export default function Toast({ text, onDone, type = 'ok' }: { text: string; onDone: () => void; type?: 'ok' | 'error' }) {
  useEffect(() => { const t = setTimeout(onDone, 2500); return () => clearTimeout(t) }, [text, onDone])
  return (
    <div className={`fixed bottom-6 right-6 z-[60] rounded-lg px-4 py-3 text-sm text-white shadow-lg ${type === 'ok' ? 'bg-green-600' : 'bg-red-600'}`}>
      {text}
    </div>
  )
}
