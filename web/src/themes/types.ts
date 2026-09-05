import type { ComponentType } from 'react'

/** one skin = one component per overlay, the logic lives in features/ */
export interface ThemeComponents {
  TextUI: ComponentType
  HelpText: ComponentType
  Subtitle: ComponentType
  ProgressBar: ComponentType
  ContextMenu: ComponentType
  AlertDialog: ComponentType
  InputDialog: ComponentType
}
