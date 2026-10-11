import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// NUI only: ui_page 'web/build/index.html' loaded over the nui:// scheme.
// Hashed file names keep FiveM CEF from serving a stale cached chunk after a rebuild.
export default defineConfig({
  base: './',
  plugins: [react()],
  build: {
    outDir: 'build',
    emptyOutDir: true,
    sourcemap: false,
  },
  server: {
    port: 5173,
    // i18n.ts reads locales/web/en.json, which lives outside web/
    fs: { allow: ['..'] },
  },
})
