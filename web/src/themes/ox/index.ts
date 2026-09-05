import type { ThemeComponents } from '../types'
import AlertDialog from './AlertDialog'
import ContextMenu from './ContextMenu'
import InputDialog from './InputDialog'
import ProgressBar from './ProgressBar'
import TextUI from './TextUI'
import './ox.css'

/** the classic ox_lib look, for servers that switched to REC_Library and want nothing to change on screen */
const ox: ThemeComponents = { TextUI, ProgressBar, ContextMenu, AlertDialog, InputDialog }

export default ox
