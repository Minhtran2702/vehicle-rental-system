import { SelectHTMLAttributes, TextareaHTMLAttributes } from 'react'

const base = 'w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-brand-500'

export function Select({ label, children, ...rest }: SelectHTMLAttributes<HTMLSelectElement> & { label?: string }) {
  return (
    <label className="block text-sm">
      {label && <span className="mb-1 block font-medium text-slate-700">{label}</span>}
      <select {...rest} className={base}>{children}</select>
    </label>
  )
}

export function Textarea({ label, ...rest }: TextareaHTMLAttributes<HTMLTextAreaElement> & { label?: string }) {
  return (
    <label className="block text-sm">
      {label && <span className="mb-1 block font-medium text-slate-700">{label}</span>}
      <textarea rows={4} {...rest} className={base} />
    </label>
  )
}
