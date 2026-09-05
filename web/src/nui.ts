import { useEffect, useRef } from 'react'

declare global {
  interface Window {
    GetParentResourceName?: () => string
  }
}

export const inFiveM = typeof window.GetParentResourceName === 'function'

function resourceName(): string {
  return window.GetParentResourceName !== undefined ? window.GetParentResourceName() : 'REC_Library'
}

/** POST to RegisterNUICallback(action). Outside FiveM the call is only logged. */
export async function fetchNui<T = unknown>(action: string, data?: unknown): Promise<T | null> {
  if (inFiveM === false) {
    console.log(`[nui] ${action}`, data)
    return null
  }

  const response = await fetch(`https://${resourceName()}/${action}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data ?? {}),
  })

  return (await response.json()) as T
}

interface NuiMessage<T> {
  action: string
  data: T
}

/** subscribe to SendNUIMessage({ action, data }) */
export function useNuiEvent<T>(action: string, handler: (data: T) => void) {
  const handlerRef = useRef(handler)
  handlerRef.current = handler

  useEffect(() => {
    const listener = (event: MessageEvent<NuiMessage<T>>) => {
      if (event.data === null || typeof event.data !== 'object') return
      if (event.data.action !== action) return
      handlerRef.current(event.data.data)
    }

    window.addEventListener('message', listener)
    return () => window.removeEventListener('message', listener)
  }, [action])
}

/** "gear" and "fa-solid fa-gear" both become a usable class list */
export function iconClass(icon: string | undefined, fallback?: string): string | undefined {
  const name = icon ?? fallback
  if (name === undefined || name === '') return undefined
  if (name.includes(' ') || name.startsWith('fa-')) return name
  return `fa-solid fa-${name}`
}

/** copy through the clipboard API, with the execCommand fallback CEF sometimes needs */
export function copyText(text: string) {
  const fallback = () => {
    const area = document.createElement('textarea')
    area.value = text
    area.style.position = 'fixed'
    area.style.opacity = '0'
    document.body.appendChild(area)
    area.focus()
    area.select()
    try {
      document.execCommand('copy')
    } catch (error) {
      console.error('^1failed to copy text^0', error)
    }
    document.body.removeChild(area)
  }

  if (navigator.clipboard === undefined) {
    fallback()
    return
  }

  navigator.clipboard.writeText(text).catch(fallback)
}
