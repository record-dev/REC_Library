import { useEffect, useRef, useState } from 'react'
import { fetchNui, inFiveM, useNuiEvent } from '../nui'
import type { MenuData, MenuItem } from '../types'

export function isMenuItemSelectable(item: MenuItem): boolean {
  return item.disabled !== true && item.type !== 'label'
}

export function useMenu() {
  const [menu, setMenu] = useState<MenuData | null>(null)
  const [enabled, setEnabled] = useState(true)
  const menuRef = useRef(menu)
  menuRef.current = menu

  const update = (next: MenuData | null) => {
    menuRef.current = next
    setMenu(next)
  }

  useNuiEvent<MenuData>('showMenu', (next) => {
    if (next === null || typeof next !== 'object') return
    const items = Array.isArray(next.items) ? next.items : []
    const selected = items.find((item) => item.id === next.selected && isMenuItemSelectable(item))?.id
      ?? items.find(isMenuItemSelectable)?.id
    update({ ...next, items, selected })
  })
  useNuiEvent('hideMenu', () => update(null))
  useNuiEvent<boolean>('setMenuInputEnabled', setEnabled)

  const action = (kind: 'hover' | 'select' | 'change' | 'back' | 'close', id?: string, direction?: number) => {
    const current = menuRef.current
    if (current === null || enabled === false) return
    const item = current.items.find((entry) => entry.id === id)
    if (kind === 'close' && current.canClose === false) return
    if (kind === 'back' && current.canBack === false && current.canClose === false) return
    if (kind !== 'back' && kind !== 'close' && (item === undefined || isMenuItemSelectable(item) === false)) return
    if (kind === 'hover') update({ ...current, selected: id })
    void fetchNui('menuAction', { token: current.token, action: kind, item: id, direction })

    if (import.meta.env.DEV && inFiveM === false) {
      if (kind === 'back' || kind === 'close') update(null)
      if (item !== undefined && (kind === 'change' || (kind === 'select' && item.type === 'checkbox'))) {
        let value = item.value
        if (item.type === 'checkbox' || item.type === 'confirm') value = value === false
        if (item.type === 'range') value = Math.min(item.max ?? 100, Math.max(item.min ?? 0, Number(value) + (direction ?? 1) * (item.step ?? 1)))
        if (item.type === 'slider' && item.values !== undefined && item.values.length > 0) {
          const index = item.values.findIndex((choice) => choice.value === value)
          value = item.values[(index + (direction ?? 1) + item.values.length) % item.values.length].value
        }
        update({ ...current, items: current.items.map((entry) => entry.id === id ? { ...entry, value } : entry) })
      }
    }
  }

  const key = (pressed: string) => {
    const current = menuRef.current
    if (current === null || enabled === false) return false
    const items = current.items.filter(isMenuItemSelectable)
    const index = items.findIndex((item) => item.id === current.selected)
    if (pressed === 'ArrowUp' || pressed === 'ArrowDown') {
      if (items.length > 0) {
        const direction = pressed === 'ArrowUp' ? -1 : 1
        action('hover', items[(index + direction + items.length) % items.length].id)
      }
    } else if (pressed === 'ArrowLeft' || pressed === 'ArrowRight') {
      action('change', current.selected, pressed === 'ArrowLeft' ? -1 : 1)
    } else if (pressed === 'Enter') {
      action('select', current.selected)
    } else if (pressed === 'Escape' || pressed === 'Backspace') {
      action('back')
    } else {
      return false
    }
    return true
  }

  useNuiEvent<{ key: string }>('menuControl', (data) => key(data.key))
  useEffect(() => {
    if (menu === null || enabled === false) return
    const listener = (event: KeyboardEvent) => {
      if (event.repeat && ['Enter', 'Escape', 'Backspace'].includes(event.key)) {
        event.preventDefault()
        event.stopImmediatePropagation()
        return
      }
      if (key(event.key)) {
        event.preventDefault()
        event.stopImmediatePropagation()
      }
    }
    window.addEventListener('keydown', listener, true)
    return () => window.removeEventListener('keydown', listener, true)
  }, [menu, enabled])

  return { menu, enabled, action }
}
