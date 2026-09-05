import { useEffect, useState } from 'react'
import AlertDialog from './components/AlertDialog'
import ContextMenu from './components/ContextMenu'
import DevPanel from './components/DevPanel'
import InputDialog from './components/InputDialog'
import Notifications from './components/Notifications'
import ProgressBar from './components/ProgressBar'
import TextUI from './components/TextUI'
import { setStrings, type Strings } from './i18n'
import { copyText, fetchNui, inFiveM, useNuiEvent } from './nui'

const mockEnabled = import.meta.env.DEV && inFiveM === false && new URLSearchParams(location.search).get('mock') === '1'

export default function App() {
  // bumped when the strings change so every t() call re-renders
  const [localeVersion, setLocaleVersion] = useState(0)

  useEffect(() => {
    void fetchNui('ready')
  }, [])

  useNuiEvent<Strings>('setLocale', (strings) => {
    setStrings(strings)
    setLocaleVersion((v) => v + 1)
  })

  useNuiEvent<{ text: string }>('clipboard', (data) => {
    copyText(data.text)
  })

  return (
    <div key={localeVersion} className="dark text-foreground">
      <Notifications />
      <TextUI />
      <ProgressBar />
      <ContextMenu />
      <AlertDialog />
      <InputDialog />
      {mockEnabled && <DevPanel />}
    </div>
  )
}
