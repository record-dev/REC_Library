import { useCallback, useRef, useState } from 'react'
import { useNuiEvent } from '../nui'
import type { NotifyData, NotifyPosition, NotifyType } from '../types'

export interface Toast extends NotifyData {
  key: string
  type: NotifyType
  duration: number
  position: NotifyPosition
}

export const NOTIFY_POSITIONS: NotifyPosition[] = [
  'top',
  'top-right',
  'top-left',
  'bottom',
  'bottom-right',
  'bottom-left',
  'center-right',
  'center-left',
]

export const NOTIFY_ICON: Record<NotifyType, string> = {
  inform: 'circle-info',
  success: 'circle-check',
  warning: 'circle-exclamation',
  error: 'circle-xmark',
}

let counter = 0

/** the toast queue every skin renders, the same id replaces the toast still on screen */
export function useNotifications(): Toast[] {
  const [toasts, setToasts] = useState<Toast[]>([])
  const timers = useRef<Map<string, number>>(new Map())

  const remove = useCallback((key: string) => {
    timers.current.delete(key)
    setToasts((list) => list.filter((toast) => toast.key !== key))
  }, [])

  useNuiEvent<NotifyData>('notify', (data) => {
    if (data === null || typeof data !== 'object') return

    counter += 1
    const key = data.id ?? `toast-${counter}`
    const toast: Toast = {
      ...data,
      key,
      type: data.type ?? 'inform',
      duration: data.duration ?? 3000,
      position: data.position ?? 'top-right',
    }

    const previous = timers.current.get(key)
    if (previous !== undefined) window.clearTimeout(previous)
    timers.current.set(key, window.setTimeout(() => remove(key), toast.duration))

    setToasts((list) => [...list.filter((item) => item.key !== key), toast])
  })

  return toasts
}
