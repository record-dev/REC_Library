// Defaults bundled at build time. They are overridden at runtime once locales/web/<language>.json
// arrives from cl_nui.lua, so editing that file changes the strings without rebuilding web.
import fallback from '../../locales/web/en.json'

export type Strings = Record<string, string>

let strings: Strings = fallback as Strings

export function setStrings(next: Strings | null | undefined) {
  // the Lua json.encode turns an empty table into [], so ignore arrays
  if (next === null || next === undefined || Array.isArray(next) || typeof next !== 'object') return
  strings = { ...strings, ...next }
}

/** replace `{name}` placeholders and return the string */
export function t(key: string, params?: Record<string, string | number>): string {
  const template = strings[key] ?? key
  if (params === undefined) return template
  return template.replace(/\{(\w+)\}/g, (whole, name: string) =>
    Object.prototype.hasOwnProperty.call(params, name) ? String(params[name]) : whole,
  )
}
