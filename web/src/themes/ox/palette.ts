// Mantine v6 default colours, the palette ox_lib was built on. Index = shade 0-9.
export const MANTINE_COLORS: Record<string, string[]> = {
  dark: ['#C1C2C5', '#A6A7AB', '#909296', '#5c5f66', '#373A40', '#2C2E33', '#25262b', '#1A1B1E', '#141517', '#101113'],
  gray: ['#f8f9fa', '#f1f3f5', '#e9ecef', '#dee2e6', '#ced4da', '#adb5bd', '#868e96', '#495057', '#343a40', '#212529'],
  red: ['#fff5f5', '#ffe3e3', '#ffc9c9', '#ffa8a8', '#ff8787', '#ff6b6b', '#fa5252', '#f03e3e', '#e03131', '#c92a2a'],
  pink: ['#fff0f6', '#ffdeeb', '#fcc2d7', '#faa2c1', '#f783ac', '#f06595', '#e64980', '#d6336c', '#c2255c', '#a61e4d'],
  grape: ['#f8f0fc', '#f3d9fa', '#eebefa', '#e599f7', '#da77f2', '#cc5de8', '#be4bdb', '#ae3ec9', '#9c36b5', '#862e9c'],
  violet: ['#f3f0ff', '#e5dbff', '#d0bfff', '#b197fc', '#9775fa', '#845ef7', '#7950f2', '#7048e8', '#6741d9', '#5f3dc4'],
  indigo: ['#edf2ff', '#dbe4ff', '#bac8ff', '#91a7ff', '#748ffc', '#5c7cfa', '#4c6ef5', '#4263eb', '#3b5bdb', '#364fc7'],
  blue: ['#e7f5ff', '#d0ebff', '#a5d8ff', '#74c0fc', '#4dabf7', '#339af0', '#228be6', '#1c7ed6', '#1971c2', '#1864ab'],
  cyan: ['#e3fafc', '#c5f6fa', '#99e9f2', '#66d9e8', '#3bc9db', '#22b8cf', '#15aabf', '#1098ad', '#0c8599', '#0b7285'],
  teal: ['#e6fcf5', '#c3fae8', '#96f2d7', '#63e6be', '#38d9a9', '#20c997', '#12b886', '#0ca678', '#099268', '#087f5b'],
  green: ['#ebfbee', '#d3f9d8', '#b2f2bb', '#8ce99a', '#69db7c', '#51cf66', '#40c057', '#37b24d', '#2f9e44', '#2b8a3e'],
  lime: ['#f4fce3', '#e9fac8', '#d8f5a2', '#c0eb75', '#a9e34b', '#94d82d', '#82c91e', '#74b816', '#66a80f', '#5c940d'],
  yellow: ['#fff9db', '#fff3bf', '#ffec99', '#ffe066', '#ffd43b', '#fcc419', '#fab005', '#f59f00', '#f08c00', '#e67700'],
  orange: ['#fff4e6', '#ffe8cc', '#ffd8a8', '#ffc078', '#ffa94d', '#ff922b', '#fd7e14', '#f76707', '#e8590c', '#d9480f'],
}

export interface OxPrimary {
  /** colors[primaryColor][primaryShade], buttons and bars */
  color: string
  /** shade 2, the text of a "light" button */
  light: string
  /** shade 8 as "r, g, b", the tinted background of a "light" button */
  rgb8: string
}

function hexToRgb(hex: string): string {
  const value = hex.replace('#', '')
  const n = parseInt(value.length === 3 ? value.replace(/(.)/g, '$1$1') : value, 16)
  return `${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}`
}

/** "teal.6", "blue" and "#ff8800" all resolve, unknown names fall back to blue */
export function resolveColor(name: string | undefined, shade = 6): string {
  if (name === undefined || name === '') return MANTINE_COLORS.blue[shade]
  if (name.startsWith('#') || name.startsWith('rgb') || name.startsWith('hsl')) return name

  const [base, rawShade] = name.split('.')
  const palette = MANTINE_COLORS[base]
  if (palette === undefined) return name

  const index = rawShade !== undefined ? Number(rawShade) : shade
  return palette[Number.isFinite(index) ? Math.min(9, Math.max(0, index)) : shade]
}

export function oxPrimary(primaryColor: string | undefined, primaryShade: number | undefined): OxPrimary {
  const palette = MANTINE_COLORS[primaryColor ?? ''] ?? MANTINE_COLORS.blue
  const shade = Math.min(9, Math.max(0, Math.round(primaryShade ?? 8)))
  return { color: palette[shade], light: palette[2], rgb8: hexToRgb(palette[8]) }
}

/** the same tint ox_lib gives its light ThemeIcon: shade 8 at 20 % behind a shade 6 icon */
export function tint(color: string): string {
  const [base] = color.split('.')
  const palette = MANTINE_COLORS[base]
  if (palette === undefined) return `color-mix(in srgb, ${color} 20%, transparent)`
  return `rgba(${hexToRgb(palette[8])}, 0.2)`
}
