import { createBrowserRouter } from 'react-router-dom'
import RequireAuth from '../auth/RequireAuth'
import AdminLayout from '../layouts/AdminLayout'
import MainLayout from '../layouts/MainLayout'
import Home from '../pages/Home'
import Login from '../pages/Login'
import { Forbidden, NotFound } from '../pages/NotFound'
import AuditLogs from '../pages/minh/AuditLogs'
import MyVehicles from '../pages/minh/MyVehicles'
import Profile from '../pages/minh/Profile'
import Register from '../pages/minh/Register'
import Reviews from '../pages/minh/Reviews'
import VehicleForm from '../pages/minh/VehicleForm'
import VehicleManage from '../pages/minh/VehicleManage'

/**
 * Khách (public) → Người dùng (cần đăng nhập, bọc RequireAuth) → Admin (cần vai trò ADMIN).
 * Thêm trang mới: import trang rồi thêm 1 dòng vào đúng nhóm bên dưới.
 */
export const router = createBrowserRouter([
  {
    path: '/',
    element: <MainLayout />,
    children: [
      { index: true, element: <Home /> },
      { path: 'login', element: <Login /> },
      { path: 'register', element: <Register /> },
      // --- Trang của Khách: thêm ở đây ---

      { element: <RequireAuth />, children: [
        { path: 'profile', element: <Profile /> },
        { path: 'my-vehicles', element: <MyVehicles /> },
        { path: 'my-vehicles/new', element: <VehicleForm /> },
        { path: 'my-vehicles/:id', element: <VehicleManage /> },
        { path: 'reviews', element: <Reviews /> },
        // --- Trang của Người dùng (cần đăng nhập): thêm ở đây ---
      ] },
      { path: 'forbidden', element: <Forbidden /> },
      { path: '*', element: <NotFound /> },
    ],
  },
  {
    path: '/admin',
    element: <RequireAuth roles={['ADMIN']} />,
    children: [{ element: <AdminLayout />, children: [
      { path: 'audit', element: <AuditLogs /> },
      // --- Trang của Admin: thêm ở đây (đường dẫn con, ví dụ { path: 'users', element: <Users /> }) ---
    ] }],
  },
])
