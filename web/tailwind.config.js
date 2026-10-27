/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#eef3f9', 100: '#d9e5f2', 500: '#3a6ea5', 600: '#2b5788', 700: '#1f4063', 900: '#142a42',
        },
      },
    },
  },
  plugins: [],
}
