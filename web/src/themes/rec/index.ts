import type { ThemeComponents } from '../types'
import AlertDialog from './AlertDialog'
import ContextMenu from './ContextMenu'
import Gauge from './Gauge'
import HelpText from './HelpText'
import InputDialog from './InputDialog'
import ProgressBar from './ProgressBar'
import Subtitle from './Subtitle'
import TextUI from './TextUI'

/** the RE:CORD look, nexus-ds tokens and the re-cord.dev mint primary */
const rec: ThemeComponents = { TextUI, HelpText, Subtitle, Gauge, ProgressBar, ContextMenu, AlertDialog, InputDialog }

export default rec
