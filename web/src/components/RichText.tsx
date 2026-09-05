import type { CSSProperties, ReactNode } from 'react'

// GTA text markup, so the strings written for the native help text and subtitle keep working:
// ~r~ ~g~ ~b~ ~y~ ~p~ ~o~ ~w~ ~c~ ~m~ colour, ~h~ bold, ~s~ reset, ~n~ newline. Lua turns the
// control tokens into [E] keycaps before the text arrives (cl_text.lua formatControls).

const COLORS: Record<string, string> = {
  r: '#f87171',
  g: '#4ade80',
  b: '#60a5fa',
  y: '#fbbf24',
  p: '#c084fc',
  o: '#fb923c',
  w: '#ffffff',
  c: '#94a3b8',
  m: '#64748b',
}

/** short ASCII (plus the arrows) inside brackets is a key, a bracketed Japanese phrase is not */
const TOKEN = /~([a-z])~|\[([A-Za-z0-9 +\-_/↑↓←→]{1,24})\]|\n/g

type Segment =
  | { kind: 'text'; text: string; color?: string; bold: boolean }
  | { kind: 'key'; key: string }
  | { kind: 'break' }

export function parseRichText(text: string): Segment[] {
  const segments: Segment[] = []
  let color: string | undefined
  let bold = false
  let last = 0

  const pushText = (value: string) => {
    if (value === '') return
    segments.push({ kind: 'text', text: value, color, bold })
  }

  for (const match of text.matchAll(TOKEN)) {
    pushText(text.slice(last, match.index))
    last = match.index + match[0].length

    const code = match[1]
    const key = match[2]

    if (key !== undefined) {
      segments.push({ kind: 'key', key })
      continue
    }

    if (code === undefined || code === 'n') {
      segments.push({ kind: 'break' })
      continue
    }

    if (code === 's') {
      color = undefined
      bold = false
      continue
    }

    if (code === 'h') {
      bold = true
      continue
    }

    // an unknown code is dropped rather than drawn
    if (COLORS[code] !== undefined) color = COLORS[code]
  }

  pushText(text.slice(last))

  return segments
}

interface Props {
  text: string
  /** keycap colour, a hex string from Lua so it cannot be a class */
  keyColor?: string
  /** keycap look, each skin brings its own */
  keyClassName: string
}

export function RichText({ text, keyColor, keyClassName }: Props) {
  const keyStyle: CSSProperties = {
    color: keyColor,
    borderColor: keyColor,
  }

  const nodes: ReactNode[] = parseRichText(text).map((segment, index) => {
    switch (segment.kind) {
      case 'break':
        return <br key={index} />

      case 'key':
        return (
          <kbd key={index} className={keyClassName} style={keyStyle}>
            {segment.key}
          </kbd>
        )

      default:
        return (
          <span key={index} style={{ color: segment.color, fontWeight: segment.bold ? 700 : undefined }}>
            {segment.text}
          </span>
        )
    }
  })

  return <>{nodes}</>
}
