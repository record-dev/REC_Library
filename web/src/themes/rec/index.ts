import type { ThemeComponents } from '../types'
import AlertDialog from './AlertDialog'
import ContextMenu from './ContextMenu'
import InputDialog from './InputDialog'
import Notifications from './Notifications'
import ProgressBar from './ProgressBar'
import TextUI from './TextUI'

/** the RE:CORD look, nexus-ds tokens and the re-cord.dev mint primary */
const rec: ThemeComponents = { Notifications, TextUI, ProgressBar, ContextMenu, AlertDialog, InputDialog }

export default rec
