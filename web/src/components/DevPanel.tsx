import { Button } from '@nexus-ds/react'

// Browser only (?mock=1): fires the same messages cl_*.lua sends, so every overlay
// can be checked without the game.
function send(action: string, data?: unknown) {
  window.postMessage({ action, data }, '*')
}

const SAMPLES: { label: string; run: () => void }[] = [
  {
    label: 'alert',
    run: () =>
      send('alert', {
        header: 'Danger Action!!',
        content: '本当に実行しますか？\n\n承認後、クリップボードにコピーされます',
        centered: true,
        cancel: true,
        labels: { confirm: '実行', cancel: 'キャンセル' },
      }),
  },
  {
    label: 'input',
    run: () =>
      send('input', {
        heading: 'ネームタグ',
        rows: [
          { type: 'input', label: 'First name', placeholder: 'John', required: true, max: 12, icon: 'user' },
          { type: 'number', label: 'Age', min: 0, max: 120, default: 20 },
          { type: 'select', label: 'Job', options: [{ value: 'police', label: 'Police' }, { value: 'ems', label: 'EMS' }] },
          { type: 'multi-select', label: 'Tags', options: [{ value: 'a', label: 'A' }, { value: 'b', label: 'B' }] },
          { type: 'slider', label: 'Volume', min: 0, max: 100, default: 40 },
          { type: 'checkbox', label: 'Visible', default: true },
          { type: 'color', label: 'Colour', default: '#00ff88' },
          { type: 'date', label: 'Date' },
          { type: 'textarea', label: 'Note', autosize: true },
        ],
        options: { allowCancel: true },
      }),
  },
  {
    label: 'context',
    run: () =>
      send('showContext', {
        id: 'sample',
        title: 'パーティクルマネージャー',
        menu: 'parent',
        options: [
          { title: 'Place particle', description: 'fire / smoke / sparks', icon: 'fire', iconColor: '#f97316', hasMenu: true },
          { title: 'Read only row', readOnly: true, icon: 'lock', metadata: [{ label: 'Owner', value: 'Nazu' }, { label: 'Fuel', value: 40, progress: 40 }] },
          { title: 'Disabled', disabled: true, icon: 'ban' },
          { title: 'Progress', progress: 65, icon: 'gauge' },
          { title: 'Copy coords', description: 'vector3(0.0, 0.0, 0.0)', icon: 'fa-solid fa-map-location-dot', iconColor: '#38D9A9' },
        ],
      }),
  },
  { label: 'progress bar', run: () => send('progress', { duration: 3000, label: '梱包中...', circle: false }) },
  { label: 'progress circle', run: () => send('progress', { duration: 3000, label: 'Searching', circle: true, position: 'middle' }) },
  { label: 'textUI', run: () => send('textUI', { text: '[E] - 調べる', position: 'left-center', icon: 'fa-solid fa-question', iconColor: 'white' }) },
  { label: 'hide textUI', run: () => send('hideTextUI') },
  {
    label: 'help text',
    run: () =>
      send('helpText', {
        id: 'sample-help',
        text: '[E] 調べる\n[ESC] ~r~キャンセル~s~',
        icon: 'circle-info',
        color: '#e2e8f0',
        position: 'top-left',
        duration: 0,
      }),
  },
  { label: 'hide help text', run: () => send('hideHelpText', {}) },
  {
    label: 'subtitle',
    run: () =>
      send('subtitle', {
        id: 'sample-subtitle',
        text: '時間切れになる前に~y~指定の場所~s~へ向かえ。',
        name: 'REC_Library',
        color: '#fbbf24',
        duration: 5000,
      }),
  },
  { label: 'hide subtitle', run: () => send('hideSubtitle', {}) },
  { label: 'locale ja', run: () => send('setLocale', { CONFIRM: '決定', CANCEL: 'キャンセル', SUBMIT: '送信' }) },
  { label: 'theme rec', run: () => send('setTheme', { name: 'rec' }) },
  { label: 'theme ox', run: () => send('setTheme', { name: 'ox', options: { primaryColor: 'blue', primaryShade: 8 } }) },
  { label: 'theme ox teal', run: () => send('setTheme', { name: 'ox', options: { primaryColor: 'teal', primaryShade: 6 } }) },
]

export default function DevPanel() {
  return (
    <div className="rec-interactive fixed bottom-4 left-4 z-50 flex max-w-xs flex-wrap gap-2 rounded-large border border-divider bg-content1 p-3">
      {SAMPLES.map((sample) => (
        <Button key={sample.label} size="sm" variant="flat" onPress={sample.run}>
          {sample.label}
        </Button>
      ))}
    </div>
  )
}
