import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // Chuyển /api sang Back-end (8080) để trình duyệt chỉ gọi cùng địa chỉ với web, khỏi vướng CORS
  server: { port: 5173, proxy: { '/api': 'http://localhost:8080' } },
})
