import { useEffect, useMemo, useState } from 'react'
import { fetchNui, useNuiEvent } from '../nui'
import type { InputData, InputRow } from '../types'

export type InputValue = string | number | boolean | string[] | null

export interface InputState {
  data: InputData | null
  values: InputValue[]
  allowCancel: boolean
  /** every required row has a value */
  complete: boolean
  close: (submit: boolean) => void
  setValue: (index: number, value: InputValue) => void
}

export function defaultValue(row: InputRow): InputValue {
  if (row.default !== undefined && row.default !== null) {
    if (row.type === 'multi-select') return Array.isArray(row.default) ? (row.default as string[]) : [String(row.default)]
    if (row.type === 'checkbox') return row.default === true
    if (row.type === 'slider' || row.type === 'number') return Number(row.default)
    return String(row.default)
  }

  if (row.type === 'checkbox') return false
  if (row.type === 'slider') return row.min ?? 0
  if (row.type === 'multi-select') return []
  if (row.type === 'color') return '#000000'
  return null
}

export function isFilled(row: InputRow, value: InputValue): boolean {
  if (row.type === 'checkbox' || row.type === 'slider') return true
  if (value === null || value === undefined) return false
  if (Array.isArray(value)) return value.length > 0
  if (typeof value === 'string') return value.trim() !== ''
  return true
}

/** the value handed back to Lua, epoch ms for dates unless returnString is set */
export function outputValue(row: InputRow, value: InputValue): unknown {
  if (row.type === 'date' && typeof value === 'string' && value !== '') {
    return row.returnString === true ? value : new Date(`${value}T00:00:00`).getTime()
  }
  if (row.type === 'number' && typeof value === 'string') {
    return value === '' ? null : Number(value)
  }
  return value
}

export function useInput(): InputState {
  const [data, setData] = useState<InputData | null>(null)
  const [values, setValues] = useState<InputValue[]>([])

  useNuiEvent<InputData>('input', (next) => {
    if (next === null || typeof next !== 'object') return
    const rows = Array.isArray(next.rows) ? next.rows : []
    setData({ ...next, rows })
    setValues(rows.map(defaultValue))
  })

  useNuiEvent('closeInput', () => setData(null))

  const allowCancel = data !== null && !Array.isArray(data.options) && data.options.allowCancel === false ? false : true

  const complete = useMemo(() => {
    if (data === null) return false
    return data.rows.every((row, index) => row.required !== true || isFilled(row, values[index]))
  }, [data, values])

  const close = (submit: boolean) => {
    if (data === null) return
    const payload = submit ? data.rows.map((row, index) => outputValue(row, values[index])) : false
    setData(null)
    void fetchNui('inputClose', { values: payload })
  }

  useEffect(() => {
    if (data === null) return

    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && allowCancel) close(false)
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [data, allowCancel])

  const setValue = (index: number, value: InputValue) => {
    setValues((list) => list.map((item, i) => (i === index ? value : item)))
  }

  return { data, values, allowCancel, complete, close, setValue }
}
