import { useState } from 'react'
import { useNuiEvent } from '../nui'
import type { TextUIData } from '../types'

export function useTextUI(): TextUIData | null {
  const [data, setData] = useState<TextUIData | null>(null)

  useNuiEvent<TextUIData>('textUI', (next) => {
    if (next === null || typeof next !== 'object') return
    setData(next)
  })

  useNuiEvent('hideTextUI', () => setData(null))

  return data
}
