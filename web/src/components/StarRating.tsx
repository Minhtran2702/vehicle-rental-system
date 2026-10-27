import { useState } from 'react'

interface Props { value: number; onChange?: (v: number) => void; size?: string }

/** Hiển thị sao. Truyền onChange để cho phép bấm chọn. */
export default function StarRating({ value, onChange, size = 'text-xl' }: Props) {
  const [hover, setHover] = useState(0)
  const shown = hover || value
  return (
    <span className={`inline-flex ${size} leading-none`}>
      {[1, 2, 3, 4, 5].map((n) => (
        <span
          key={n}
          onClick={() => onChange?.(n)}
          onMouseEnter={() => onChange && setHover(n)}
          onMouseLeave={() => onChange && setHover(0)}
          className={`${n <= shown ? 'text-amber-400' : 'text-slate-300'} ${onChange ? 'cursor-pointer' : ''}`}
        >★</span>
      ))}
    </span>
  )
}
