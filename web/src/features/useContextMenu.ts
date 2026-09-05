import { useEffect, useState } from 'react'
import { fetchNui, useNuiEvent } from '../nui'
import type { ContextMenu, ContextMetadata, ContextOption } from '../types'

export interface ContextMenuState {
  menu: ContextMenu | null
  canClose: boolean
  /** 1-based index of the hovered option, the metadata card follows it */
  hovered: number | null
  hoveredOption: ContextOption | undefined
  metadata: ContextMetadata[]
  setHovered: (index: number | null) => void
  close: () => void
  back: () => void
  select: (index: number) => void
}

export function useContextMenu(): ContextMenuState {
  const [menu, setMenu] = useState<ContextMenu | null>(null)
  const [hovered, setHovered] = useState<number | null>(null)

  useNuiEvent<ContextMenu>('showContext', (next) => {
    if (next === null || typeof next !== 'object') return
    setHovered(null)
    setMenu({ ...next, options: Array.isArray(next.options) ? next.options : [] })
  })

  useNuiEvent('hideContext', () => setMenu(null))

  const canClose = menu !== null && menu.canClose !== false

  const close = () => {
    if (menu === null || canClose === false) return
    setMenu(null)
    void fetchNui('contextClose', { id: menu.id })
  }

  const back = () => {
    if (menu === null) return
    void fetchNui('contextBack', { id: menu.id })
  }

  const select = (index: number) => {
    if (menu === null) return
    const option = menu.options[index - 1]
    if (option === undefined || option.disabled === true || option.readOnly === true) return
    void fetchNui('contextSelect', { id: menu.id, index })
  }

  useEffect(() => {
    if (menu === null) return

    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') close()
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [menu, canClose])

  const hoveredOption = menu !== null && hovered !== null ? menu.options[hovered - 1] : undefined
  const metadata = hoveredOption?.metadata !== undefined && Array.isArray(hoveredOption.metadata) ? hoveredOption.metadata : []

  return { menu, canClose, hovered, hoveredOption, metadata, setHovered, close, back, select }
}

/** an arrow is drawn for explicit arrow = true and for sub menus unless arrow = false */
export function showsArrow(option: ContextOption): boolean {
  return option.arrow === true || (option.hasMenu === true && option.arrow !== false)
}
