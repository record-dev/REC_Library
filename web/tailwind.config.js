import { nexusui } from '@nexus-ds/react'

// Mint green matched to the re-cord.dev primary, the same tokens the admin panels use.
export default {
  content: [
    './index.html',
    './src/**/*.{ts,tsx}',
    './node_modules/@nexus-ds/theme/dist/**/*.{js,ts,jsx,tsx}',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', '"Segoe UI"', '"Hiragino Sans"', '"Noto Sans JP"', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [
    nexusui({
      layout: {
        radius: { small: '6px', medium: '10px', large: '14px' },
      },
      themes: {
        dark: {
          colors: {
            background: '#0b0e13',
            foreground: '#e6e8ee',
            content1: '#12161d',
            content2: '#1a1f29',
            content3: '#232a37',
            content4: '#2d3546',
            divider: 'rgba(255, 255, 255, 0.08)',
            focus: '#00ff88',
            primary: {
              50: '#e5fff3',
              100: '#b8ffe0',
              200: '#8affcd',
              300: '#5cffba',
              400: '#2effa7',
              500: '#00ff88',
              600: '#00d26f',
              700: '#00a457',
              800: '#00773e',
              900: '#004a26',
              DEFAULT: '#00ff88',
              foreground: '#001a0e',
            },
          },
        },
      },
    }),
  ],
}
