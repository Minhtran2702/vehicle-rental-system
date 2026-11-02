/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      fontFamily: { sans: ['"Be Vietnam Pro"', 'system-ui', 'sans-serif'] },
      colors: {
        // Vàng vạch kẻ đường: màu nhấn duy nhất, dùng cho chiếc xe và nút chính ở trang chủ
        road: { 400: '#f6c453', 500: '#f2b632', 600: '#d99a14' },
        brand: {
          50: '#eef3f9', 100: '#d9e5f2', 500: '#3a6ea5', 600: '#2b5788', 700: '#1f4063', 900: '#142a42',
        },
      },
    },
  },
  plugins: [],
}
