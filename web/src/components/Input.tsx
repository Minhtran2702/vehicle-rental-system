import { InputHTMLAttributes, forwardRef } from 'react'

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
}

const Input = forwardRef<HTMLInputElement, Props>(({ label, error, className = '', ...rest }, ref) => (
  <label className="block text-sm">
    {label && <span className="mb-1 block font-medium text-slate-700">{label}</span>}
    <input
      ref={ref}
      {...rest}
      className={`w-full rounded-lg border px-3 py-2 outline-none focus:ring-2 focus:ring-brand-500 ${error ? 'border-red-500' : 'border-slate-300'} ${className}`}
    />
    {error && <span className="mt-1 block text-xs text-red-600">{error}</span>}
  </label>
))
Input.displayName = 'Input'
export default Input
