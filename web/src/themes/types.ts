import type { ComponentType } from 'react'

/** one skin = one component per overlay, the logic lives in features/ */
export interface ThemeComponents {
  Notifications: ComponentType
  TextUI: ComponentType
  ProgressBar: ComponentType
  ContextMenu: ComponentType
  AlertDialog: ComponentType
  InputDialog: ComponentType
}
