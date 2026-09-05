import type { ThemeName } from '../theme'
import ox from './ox'
import rec from './rec'
import type { ThemeComponents } from './types'

export const THEMES: Record<ThemeName, ThemeComponents> = { rec, ox }
