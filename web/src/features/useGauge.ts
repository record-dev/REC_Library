import { useState } from 'react'
import { useNuiEvent } from '../nui'
import { HELP_TEXT_POSITIONS, type GaugeConfig, type GaugeData, type HelpTextPosition } from '../types'
import { useHudConfig } from './useHudConfig'

/** a gauge the Lua side asked for, in the order it was first shown */
export interface GaugeEntry {
  seq: number
  data: GaugeData
}

let nextSeq = 1

function normalize(raw: GaugeData, fallbackPosition: HelpTextPosition): GaugeData {
  const percent = typeof raw.percent === 'number' && Number.isFinite(raw.percent) ? raw.percent : 0

  return {
    ...raw,
    percent: Math.min(100, Math.max(0, Math.round(percent))),
    position: HELP_TEXT_POSITIONS.includes(raw.position) ? raw.position : fallbackPosition,
    shape: raw.shape === 'ring' ? 'ring' : 'bar',
    variant: raw.variant === 'plain' ? 'plain' : 'card',
    width: typeof raw.width === 'string' && raw.width !== '' ? raw.width : undefined,
    showValue: raw.showValue === true,
    hideWhenEmpty: raw.hideWhenEmpty === true,
  }
}

export function useGauges(): { entries: GaugeEntry[]; config: GaugeConfig } {
  const config = useHudConfig().gauge
  const [entries, setEntries] = useState<GaugeEntry[]>([])

  useNuiEvent<GaugeData>('gauge', (raw) => {
    if (raw === null || typeof raw !== 'object' || typeof raw.id !== 'string') return

    const data = normalize(raw, config.position)

    setEntries((current) => {
      const index = current.findIndex((entry) => entry.data.id === data.id)
      if (index === -1) return [...current, { seq: nextSeq++, data }]

      const next = current.slice()
      next[index] = { seq: current[index].seq, data }
      return next
    })
  })

  useNuiEvent<{ id?: string } | null>('hideGauge', (raw) => {
    const id = raw !== null && typeof raw === 'object' && typeof raw.id === 'string' ? raw.id : undefined

    setEntries((current) => (id === undefined ? [] : current.filter((entry) => entry.data.id !== id)))
  })

  return { entries, config }
}

/** the gauges that should be drawn, grouped by the corner they sit in */
export function groupGauges(entries: GaugeEntry[]): Map<HelpTextPosition, GaugeEntry[]> {
  const groups = new Map<HelpTextPosition, GaugeEntry[]>()

  for (const entry of entries) {
    if (entry.data.hideWhenEmpty === true && entry.data.percent <= 0) continue

    const list = groups.get(entry.data.position) ?? []
    list.push(entry)
    groups.set(entry.data.position, list)
  }

  return groups
}

/** the ring's circumference for a stroke-dashoffset fill */
export const RING_RADIUS = 26
export const RING_LENGTH = 2 * Math.PI * RING_RADIUS
