import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// NUI only: ui_page 'web/build/index.html' loaded over the nui:// scheme.
// Fixed file names keep the fxmanifest glob valid across rebuilds.
export default defineConfig({
  base: './',
  plugins: [react()],
  build: {
    outDir: 'build',
    emptyOutDir: true,
    sourcemap: false,
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name].[ext]',
      },
    },
  },
  server: {
    port: 5173,
    // i18n.ts reads locales/web/en.json, which lives outside web/
    fs: { allow: ['..'] },
  },
})
