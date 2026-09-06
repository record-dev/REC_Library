import { useEffect, useRef, useState, type PointerEvent as ReactPointerEvent } from 'react'

// CEF has no OS colour dialog, so <input type="color"> never opens in FiveM. This is a
// self-contained picker: hex field, swatch, and a panel with a saturation/value square
// plus a hue slider. The skins only restyle the cp__* classes.

interface Hsv {
  h: number
  s: number
  v: number
}

const HEX = /^#?([0-9a-f]{6})$/i

export function normalizeHex(value: string): string | null {
  const match = HEX.exec(value.trim())
  return match === null ? null : `#${match[1].toLowerCase()}`
}

function hexToHsv(hex: string): Hsv {
  const n = parseInt(hex.slice(1), 16)
  const r = ((n >> 16) & 255) / 255
  const g = ((n >> 8) & 255) / 255
  const b = (n & 255) / 255
  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  const d = max - min
  let h = 0
  if (d !== 0) {
    if (max === r) h = ((g - b) / d) % 6
    else if (max === g) h = (b - r) / d + 2
    else h = (r - g) / d + 4
    h *= 60
    if (h < 0) h += 360
  }
  return { h, s: max === 0 ? 0 : d / max, v: max }
}

function hsvToHex({ h, s, v }: Hsv): string {
  const c = v * s
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1))
  const m = v - c
  let r = 0
  let g = 0
  let b = 0
  if (h < 60) [r, g, b] = [c, x, 0]
  else if (h < 120) [r, g, b] = [x, c, 0]
  else if (h < 180) [r, g, b] = [0, c, x]
  else if (h < 240) [r, g, b] = [0, x, c]
  else if (h < 300) [r, g, b] = [x, 0, c]
  else [r, g, b] = [c, 0, x]
  const to = (n: number) => Math.round((n + m) * 255).toString(16).padStart(2, '0')
  return `#${to(r)}${to(g)}${to(b)}`
}

const clamp = (n: number) => Math.min(1, Math.max(0, n))

interface Props {
  value: string
  disabled?: boolean
  placeholder?: string
  onChange: (hex: string) => void
  classNames?: { hex?: string; swatch?: string; panel?: string }
}

export default function ColorPicker({ value, disabled, placeholder, onChange, classNames }: Props) {
  const [open, setOpen] = useState(false)
  const [text, setText] = useState(value)
  const [hsv, setHsv] = useState<Hsv>(() => hexToHsv(normalizeHex(value) ?? '#000000'))
  const wrapper = useRef<HTMLDivElement>(null)
  const square = useRef<HTMLDivElement>(null)
  const emitted = useRef(value)

  // external value (defaults, resets) wins over what was typed
  useEffect(() => {
    if (value === emitted.current) return
    emitted.current = value
    setText(value)
    const hex = normalizeHex(value)
    if (hex !== null) setHsv(hexToHsv(hex))
  }, [value])

  useEffect(() => {
    if (open === false) return

    const onDown = (event: MouseEvent) => {
      if (wrapper.current !== null && wrapper.current.contains(event.target as Node) === false) setOpen(false)
    }

    window.addEventListener('mousedown', onDown)
    return () => window.removeEventListener('mousedown', onDown)
  }, [open])

  const emit = (next: Hsv) => {
    const hex = hsvToHex(next)
    setHsv(next)
    setText(hex)
    emitted.current = hex
    onChange(hex)
  }

  const onText = (raw: string) => {
    setText(raw)
    const hex = normalizeHex(raw)
    if (hex === null) return
    setHsv(hexToHsv(hex))
    emitted.current = hex
    onChange(hex)
  }

  const pick = (event: ReactPointerEvent<HTMLDivElement>) => {
    if (square.current === null) return
    const rect = square.current.getBoundingClientRect()
    emit({
      h: hsv.h,
      s: clamp((event.clientX - rect.left) / rect.width),
      v: clamp(1 - (event.clientY - rect.top) / rect.height),
    })
  }

  const swatch = normalizeHex(text) ?? hsvToHex(hsv)

  return (
    <div
      ref={wrapper}
      className="cp"
      onKeyDown={(event) => {
        if (event.key === 'Escape' && open) {
          event.stopPropagation()
          setOpen(false)
        }
      }}
    >
      <div className="cp__row">
        <button
          type="button"
          className={`cp__swatch ${classNames?.swatch ?? ''}`}
          style={{ background: swatch }}
          disabled={disabled === true}
          aria-label={swatch}
          onClick={() => setOpen((state) => !state)}
        />
        <input
          type="text"
          className={`cp__hex ${classNames?.hex ?? ''}`}
          value={text}
          placeholder={placeholder ?? '#000000'}
          maxLength={7}
          spellCheck={false}
          disabled={disabled === true}
          onFocus={() => setOpen(true)}
          onChange={(event) => onText(event.target.value)}
        />
      </div>

      {open && disabled !== true && (
        <div className={`cp__panel ${classNames?.panel ?? ''}`}>
          <div
            ref={square}
            className="cp__sv"
            style={{ backgroundColor: `hsl(${hsv.h} 100% 50%)` }}
            onPointerDown={(event) => {
              event.preventDefault()
              event.currentTarget.setPointerCapture(event.pointerId)
              pick(event)
            }}
            onPointerMove={(event) => {
              if (event.currentTarget.hasPointerCapture(event.pointerId)) pick(event)
            }}
          >
            <div className="cp__cursor" style={{ left: `${hsv.s * 100}%`, top: `${(1 - hsv.v) * 100}%`, background: swatch }} />
          </div>
          <input
            type="range"
            className="cp__hue"
            min={0}
            max={360}
            step={1}
            value={Math.round(hsv.h)}
            onChange={(event) => emit({ ...hsv, h: Number(event.target.value) })}
          />
        </div>
      )}
    </div>
  )
}
