// Which skin web/ renders. cl_nui.lua pushes { name, options } right after "ready",
// the browser can force one with ?theme=ox while developing.
import { oxPrimary } from './themes/ox/palette'

export type ThemeName = 'rec' | 'ox'

export interface OxThemeOptions {
  primaryColor?: string
  primaryShade?: number
}

export interface ThemeState {
  name: ThemeName
  options?: OxThemeOptions | null
}

export const THEME_NAMES: ThemeName[] = ['rec', 'ox']

export function isThemeName(value: unknown): value is ThemeName {
  return typeof value === 'string' && (THEME_NAMES as string[]).includes(value)
}

/** what the Lua side sends, anything unknown falls back to rec */
export function normalizeTheme(raw: unknown): ThemeState {
  if (raw === null || typeof raw !== 'object') return { name: 'rec' }
  const data = raw as { name?: unknown; options?: unknown }
  const name = isThemeName(data.name) ? data.name : 'rec'
  const options = data.options !== null && typeof data.options === 'object' && !Array.isArray(data.options) ? (data.options as OxThemeOptions) : null
  return { name, options }
}

export function initialTheme(): ThemeState {
  const forced = new URLSearchParams(location.search).get('theme')
  if (import.meta.env.DEV && isThemeName(forced)) return { name: forced }
  return { name: 'rec' }
}

/** data-theme on <html> plus the css variables the ox stylesheet reads */
export function applyTheme(theme: ThemeState) {
  const root = document.documentElement
  root.dataset.theme = theme.name

  const primary = oxPrimary(theme.options?.primaryColor, theme.options?.primaryShade)
  root.style.setProperty('--ox-primary', primary.color)
  root.style.setProperty('--ox-primary-light', primary.light)
  root.style.setProperty('--ox-primary-8-rgb', primary.rgb8)
}
