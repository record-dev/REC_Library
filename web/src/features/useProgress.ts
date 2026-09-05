import { useEffect, useRef, useState } from 'react'
import { fetchNui, useNuiEvent } from '../nui'
import type { ProgressData } from '../types'

export interface ProgressState {
  data: ProgressData | null
  /** 0-100, only ticks for the circle */
  value: number
}

export function useProgress(): ProgressState {
  const [data, setData] = useState<ProgressData | null>(null)
  const [value, setValue] = useState(0)
  const timer = useRef<number | null>(null)
  const frame = useRef<number | null>(null)

  const stop = () => {
    if (timer.current !== null) window.clearTimeout(timer.current)
    if (frame.current !== null) window.cancelAnimationFrame(frame.current)
    timer.current = null
    frame.current = null
  }

  useNuiEvent<ProgressData>('progress', (next) => {
    if (next === null || typeof next !== 'object') return
    stop()
    setData(next)
    setValue(0)

    const started = performance.now()
    const tick = () => {
      const ratio = Math.min(1, (performance.now() - started) / next.duration)
      setValue(Math.round(ratio * 100))
      if (ratio < 1) frame.current = window.requestAnimationFrame(tick)
    }
    if (next.circle) frame.current = window.requestAnimationFrame(tick)

    timer.current = window.setTimeout(() => {
      stop()
      setData(null)
      void fetchNui('progressComplete')
    }, next.duration)
  })

  useNuiEvent('progressCancel', () => {
    stop()
    setData(null)
  })

  useEffect(() => stop, [])

  return { data, value }
}
