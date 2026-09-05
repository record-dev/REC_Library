import type { SubtitleConfig, SubtitleData } from '../types'
import { useHudConfig } from './useHudConfig'
import { useTextEntry, type TextEntry } from './useTextEntry'

function same(a: SubtitleData, b: SubtitleData): boolean {
  return a.text === b.text && a.name === b.name && a.color === b.color
}

export function useSubtitle(): { entry: TextEntry<SubtitleData> | null; config: SubtitleConfig } {
  const config = useHudConfig().subtitle

  const entry = useTextEntry<SubtitleData>({
    showAction: 'subtitle',
    hideAction: 'hideSubtitle',
    same,
    normalize: (raw) => ({
      ...raw,
      duration: typeof raw.duration === 'number' && raw.duration > 0 ? raw.duration : 0,
    }),
  })

  return { entry, config }
}
