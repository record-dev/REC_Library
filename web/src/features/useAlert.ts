import { useEffect, useState } from 'react'
import { fetchNui, useNuiEvent } from '../nui'
import type { AlertData } from '../types'

export type AlertResult = 'confirm' | 'cancel'

export interface AlertState {
  data: AlertData | null
  answer: (result: AlertResult) => void
}

export function useAlert(): AlertState {
  const [data, setData] = useState<AlertData | null>(null)

  useNuiEvent<AlertData>('alert', (next) => {
    if (next === null || typeof next !== 'object') return
    setData(next)
  })

  useNuiEvent('closeAlert', () => setData(null))

  const answer = (result: AlertResult) => {
    setData(null)
    void fetchNui('alertClose', { result })
  }

  useEffect(() => {
    if (data === null) return

    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && data.cancel === true) answer('cancel')
      if (event.key === 'Enter') answer('confirm')
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [data])

  return { data, answer }
}
