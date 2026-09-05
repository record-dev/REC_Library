import { useCallback, useEffect, useRef, useState } from 'react'
import { useNuiEvent } from '../nui'

/** what is on screen. seq is the React key, so a changed text remounts the card and a re-show does not */
export interface TextEntry<T> {
  data: T
  seq: number
}

interface Options<T extends { id: string; duration: number }> {
  showAction: string
  hideAction: string
  /** the same content shown again keeps its card, so a caller showing every frame does not flicker */
  same: (a: T, b: T) => boolean
  normalize: (raw: T) => T
}

/** one entry at a time, duration 0 stays until hidden, every show restarts the clock */
export function useTextEntry<T extends { id: string; duration: number }>(options: Options<T>): TextEntry<T> | null {
  const [entry, setEntry] = useState<TextEntry<T> | null>(null)
  const seq = useRef(0)
  const timer = useRef(0)

  const hide = useCallback((id?: string) => {
    setEntry((prev) => {
      if (prev === null) return prev
      if (id !== undefined && id !== prev.data.id) return prev
      return null
    })
  }, [])

  useNuiEvent<T>(options.showAction, (raw) => {
    if (raw === null || typeof raw !== 'object' || typeof raw.id !== 'string') return

    const data = options.normalize(raw)

    setEntry((prev) => {
      if (prev !== null && options.same(prev.data, data)) return { data, seq: prev.seq }

      seq.current += 1
      return { data, seq: seq.current }
    })

    window.clearTimeout(timer.current)
    timer.current = 0

    if (data.duration > 0) {
      timer.current = window.setTimeout(() => hide(data.id), data.duration)
    }
  })

  useNuiEvent<{ id?: string } | undefined>(options.hideAction, (data) => {
    hide(data !== null && typeof data === 'object' ? data.id : undefined)
  })

  useEffect(() => () => window.clearTimeout(timer.current), [])

  return entry
}
