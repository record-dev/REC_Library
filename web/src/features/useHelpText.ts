import type { CSSProperties } from 'react'
import { HELP_TEXT_POSITIONS, type HelpTextConfig, type HelpTextData, type HelpTextPosition } from '../types'
import { useHudConfig } from './useHudConfig'
import { useTextEntry, type TextEntry } from './useTextEntry'

function same(a: HelpTextData, b: HelpTextData): boolean {
  return a.text === b.text && a.icon === b.icon && a.color === b.color && a.position === b.position
}

export function useHelpText(): { entry: TextEntry<HelpTextData> | null; config: HelpTextConfig } {
  const config = useHudConfig().helpText

  const entry = useTextEntry<HelpTextData>({
    showAction: 'helpText',
    hideAction: 'hideHelpText',
    same,
    normalize: (raw) => ({
      ...raw,
      position: HELP_TEXT_POSITIONS.includes(raw.position) ? raw.position : config.position,
      duration: typeof raw.duration === 'number' && raw.duration > 0 ? raw.duration : 0,
    }),
  })

  return { entry, config }
}

/** where the wrapper sits, the wrapper centers so the animated child never carries a translate */
export function helpTextWrapperStyle(position: HelpTextPosition, config: HelpTextConfig): CSSProperties {
  const style: CSSProperties = { maxWidth: config.maxWidth }

  if (position.startsWith('top')) style.top = config.offsetY
  else if (position.startsWith('bottom')) style.bottom = config.offsetY
  else {
    style.top = '50%'
    style.transform = 'translateY(-50%)'
  }

  if (position.endsWith('left')) style.left = config.offsetX
  else if (position.endsWith('right')) style.right = config.offsetX
  else {
    style.left = '50%'
    style.transform = `${style.transform ?? ''} translateX(-50%)`.trim()
  }

  return style
}

/** offscreen state, sliding towards the nearest edge */
export function helpTextHiddenState(position: HelpTextPosition) {
  if (position.endsWith('left')) return { opacity: 0, x: -16 }
  if (position.endsWith('right')) return { opacity: 0, x: 16 }

  return { opacity: 0, y: position.startsWith('bottom') ? 12 : -12 }
}
