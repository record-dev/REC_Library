import { useEffect, useState } from 'react'
import DevPanel from './components/DevPanel'
import { setStrings, type Strings } from './i18n'
import { copyText, fetchNui, inFiveM, useNuiEvent } from './nui'
import { applyTheme, initialTheme, normalizeTheme, type ThemeState } from './theme'
import { THEMES } from './themes'

const mockEnabled = import.meta.env.DEV && inFiveM === false && new URLSearchParams(location.search).get('mock') === '1'

export default function App() {
  // bumped when the strings change so every t() call re-renders
  const [localeVersion, setLocaleVersion] = useState(0)
  const [theme, setTheme] = useState<ThemeState>(initialTheme)

  useEffect(() => {
    void fetchNui('ready')
  }, [])

  useEffect(() => {
    applyTheme(theme)
  }, [theme])

  useNuiEvent<Strings>('setLocale', (strings) => {
    setStrings(strings)
    setLocaleVersion((v) => v + 1)
  })

  useNuiEvent<unknown>('setTheme', (next) => {
    setTheme(normalizeTheme(next))
  })

  useNuiEvent<{ text: string }>('clipboard', (data) => {
    copyText(data.text)
  })

  const Skin = THEMES[theme.name]

  return (
    <div key={`${theme.name}-${localeVersion}`} className={`dark text-foreground ${theme.name === 'ox' ? 'ox-root' : ''}`}>
      <Skin.TextUI />
      <Skin.ProgressBar />
      <Skin.ContextMenu />
      <Skin.AlertDialog />
      <Skin.InputDialog />
      {mockEnabled && <DevPanel />}
    </div>
  )
}
