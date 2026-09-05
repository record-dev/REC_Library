import { useState } from 'react'
import { useNuiEvent } from '../nui'
import { HELP_TEXT_POSITIONS, type HelpTextConfig, type HudConfig, type SubtitleConfig } from '../types'

// Defaults mirror config.ui in shared/sh_config.lua, so the overlays look right during the
// few frames before setUiConfig arrives (and in the browser playground).
export const DEFAULT_HELP_TEXT_CONFIG: HelpTextConfig = {
  position: 'top-left',
  offsetX: '1.6vw',
  offsetY: '3vh',
  maxWidth: '380px',
  fontScale: 1,
  animationDuration: 200,
}

export const DEFAULT_SUBTITLE_CONFIG: SubtitleConfig = {
  offsetY: '9vh',
  maxWidth: '60vw',
  background: true,
  fontScale: 1,
  animationDuration: 200,
}

export const DEFAULT_HUD_CONFIG: HudConfig = {
  helpText: DEFAULT_HELP_TEXT_CONFIG,
  subtitle: DEFAULT_SUBTITLE_CONFIG,
}

/** a number that survives a missing or unusable value from Lua */
function toNumber(value: unknown, fallback: number, min: number): number {
  const parsed = typeof value === 'number' ? value : Number(value)
  if (Number.isFinite(parsed) === false || parsed < min) return fallback

  return parsed
}

/** the Lua json.encode turns an empty table into [], so a table field can arrive as an array */
function toObject<T extends object>(value: unknown): Partial<T> {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) return {}

  return value as Partial<T>
}

export function toHudConfig(raw: unknown): HudConfig {
  const incoming = toObject<HudConfig>(raw)
  const helpText = { ...DEFAULT_HELP_TEXT_CONFIG, ...toObject<HelpTextConfig>(incoming.helpText) }
  const subtitle = { ...DEFAULT_SUBTITLE_CONFIG, ...toObject<SubtitleConfig>(incoming.subtitle) }

  return {
    helpText: {
      ...helpText,
      position: HELP_TEXT_POSITIONS.includes(helpText.position) ? helpText.position : DEFAULT_HELP_TEXT_CONFIG.position,
      fontScale: toNumber(helpText.fontScale, DEFAULT_HELP_TEXT_CONFIG.fontScale, 0.1),
      animationDuration: toNumber(helpText.animationDuration, DEFAULT_HELP_TEXT_CONFIG.animationDuration, 0),
    },
    subtitle: {
      ...subtitle,
      fontScale: toNumber(subtitle.fontScale, DEFAULT_SUBTITLE_CONFIG.fontScale, 0.1),
      animationDuration: toNumber(subtitle.animationDuration, DEFAULT_SUBTITLE_CONFIG.animationDuration, 0),
    },
  }
}

/** the layout knobs cl_nui.lua pushes right after "ready" */
export function useHudConfig(): HudConfig {
  const [config, setConfig] = useState<HudConfig>(DEFAULT_HUD_CONFIG)

  useNuiEvent<unknown>('setUiConfig', (raw) => {
    setConfig(toHudConfig(raw))
  })

  return config
}
