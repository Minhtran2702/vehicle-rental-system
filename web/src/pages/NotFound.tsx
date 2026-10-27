import { Link } from 'react-router-dom'

export function NotFound() {
  return <div className="p-10 text-center"><h1 className="mb-2 text-2xl font-bold">404</h1><p className="mb-4">Không tìm thấy trang.</p><Link to="/" className="text-brand-600">Về trang chủ</Link></div>
}

export function Forbidden() {
  return <div className="p-10 text-center"><h1 className="mb-2 text-2xl font-bold">403</h1><p className="mb-4">Bạn không có quyền truy cập trang này.</p><Link to="/" className="text-brand-600">Về trang chủ</Link></div>
}
