import { AnimatePresence, motion } from 'framer-motion'
import { useState } from 'react'
import { iconClass, useNuiEvent } from '../nui'
import type { TextUIData } from '../types'

// the wrapper centers, the animated child must not carry a translate class (framer-motion owns transform)
const POSITION_CLASS: Record<NonNullable<TextUIData['position']>, string> = {
  'right-center': 'inset-y-0 right-6 flex items-center',
  'left-center': 'inset-y-0 left-6 flex items-center',
  'top-center': 'inset-x-0 top-6 flex justify-center',
  'bottom-center': 'inset-x-0 bottom-6 flex justify-center',
}

export default function TextUI() {
  const [data, setData] = useState<TextUIData | null>(null)

  useNuiEvent<TextUIData>('textUI', (next) => {
    if (next === null || typeof next !== 'object') return
    setData(next)
  })

  useNuiEvent('hideTextUI', () => setData(null))

  const icon = iconClass(data?.icon)
  const style = data?.style !== undefined && Array.isArray(data.style) === false ? data.style : undefined

  return (
    <div className={`fixed z-10 ${POSITION_CLASS[data?.position ?? 'right-center']}`}>
    <AnimatePresence>
      {data !== null && (
        <motion.div
          key="textui"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
          className={`flex max-w-sm gap-3 rounded-large border border-divider bg-content1/95 px-4 py-3 text-small shadow-medium ${
            data.alignIcon === 'top' ? 'items-start' : 'items-center'
          }`}
          style={style}
        >
          {icon !== undefined && <i className={`${icon} text-medium`} style={{ color: data.iconColor }} />}
          <p className="whitespace-pre-line break-words">{data.text}</p>
        </motion.div>
      )}
    </AnimatePresence>
    </div>
  )
}
