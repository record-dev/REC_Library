// The shapes cl_*.lua sends. Every field the Lua side leaves nil is simply absent here.

export interface AlertData {
  header: string
  content: string
  centered?: boolean
  cancel?: boolean
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl'
  labels?: { confirm?: string; cancel?: string }
}

export type InputRowType =
  | 'input'
  | 'number'
  | 'checkbox'
  | 'select'
  | 'multi-select'
  | 'slider'
  | 'color'
  | 'date'
  | 'time'
  | 'textarea'

export interface InputRow {
  type: InputRowType
  label: string
  description?: string
  placeholder?: string
  icon?: string
  required?: boolean
  disabled?: boolean
  default?: unknown
  password?: boolean
  min?: number
  max?: number
  step?: number
  options?: { value: string; label?: string }[]
  clearable?: boolean
  searchable?: boolean
  autosize?: boolean
  format?: string
  returnString?: boolean
}

export interface InputData {
  heading: string
  rows: InputRow[]
  options: { allowCancel?: boolean } | unknown[]
}

export interface ContextMetadata {
  label?: string
  value?: unknown
  progress?: number
}

export interface ContextOption {
  title?: string
  description?: string
  icon?: string
  iconColor?: string
  iconAnimation?: string
  image?: string
  progress?: number
  colorScheme?: string
  arrow?: boolean
  disabled?: boolean
  readOnly?: boolean
  metadata?: ContextMetadata[]
  hasMenu?: boolean
}

export interface ContextMenu {
  id: string
  title: string
  menu?: string
  canClose?: boolean
  options: ContextOption[]
}

export interface ProgressData {
  duration: number
  label?: string
  position?: 'bottom' | 'middle'
  circle: boolean
}

export interface TextUIData {
  text: string
  position?: 'right-center' | 'left-center' | 'top-center' | 'bottom-center'
  icon?: string
  iconColor?: string
  iconAnimation?: string
  alignIcon?: 'top' | 'center'
  style?: Record<string, string>
}

// ─── help text / subtitle ────────────────────────────

export type HelpTextPosition =
  | 'top-left'
  | 'top-center'
  | 'top-right'
  | 'left-center'
  | 'right-center'
  | 'bottom-left'
  | 'bottom-center'
  | 'bottom-right'

export const HELP_TEXT_POSITIONS: readonly HelpTextPosition[] = [
  'top-left',
  'top-center',
  'top-right',
  'left-center',
  'right-center',
  'bottom-left',
  'bottom-center',
  'bottom-right',
]

/** shaped by cl_helpText.lua, duration 0 stays until hidden */
export interface HelpTextData {
  id: string
  text: string
  icon?: string
  color: string
  position: HelpTextPosition
  duration: number
}

/** shaped by cl_subtitle.lua, duration 0 stays until hidden */
export interface SubtitleData {
  id: string
  text: string
  name?: string
  color: string
  duration: number
}

/** built by cl_nui.lua from config.ui.helpText */
export interface HelpTextConfig {
  position: HelpTextPosition
  offsetX: string
  offsetY: string
  maxWidth: string
  fontScale: number
  animationDuration: number
}

/** built by cl_nui.lua from config.ui.subtitle */
export interface SubtitleConfig {
  offsetY: string
  maxWidth: string
  background: boolean
  fontScale: number
  animationDuration: number
}

export interface HudConfig {
  helpText: HelpTextConfig
  subtitle: SubtitleConfig
}
