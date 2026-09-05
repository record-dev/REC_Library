import { AnimatePresence, motion } from 'framer-motion'
import { useCallback, useRef, useState } from 'react'
import { iconClass, useNuiEvent } from '../nui'
import type { NotifyData, NotifyPosition, NotifyType } from '../types'

interface Toast extends NotifyData {
  key: string
  duration: number
  position: NotifyPosition
}

const TYPE_ICON: Record<NotifyType, string> = {
  inform: 'circle-info',
  success: 'circle-check',
  warning: 'circle-exclamation',
  error: 'circle-xmark',
}

const TYPE_COLOR: Record<NotifyType, string> = {
  inform: '#38bdf8',
  success: '#00ff88',
  warning: '#facc15',
  error: '#f87171',
}

// static columns, the toasts inside animate so no translate class sits on them
const POSITION_CLASS: Record<NotifyPosition, string> = {
  top: 'top-6 left-1/2 -translate-x-1/2 items-center',
  'top-right': 'top-6 right-6 items-end',
  'top-left': 'top-6 left-6 items-start',
  bottom: 'bottom-6 left-1/2 -translate-x-1/2 items-center',
  'bottom-right': 'bottom-6 right-6 items-end',
  'bottom-left': 'bottom-6 left-6 items-start',
  'center-right': 'top-1/2 right-6 -translate-y-1/2 items-end',
  'center-left': 'top-1/2 left-6 -translate-y-1/2 items-start',
}

const POSITIONS = Object.keys(POSITION_CLASS) as NotifyPosition[]

let counter = 0

export default function Notifications() {
  const [toasts, setToasts] = useState<Toast[]>([])
  const timers = useRef<Map<string, number>>(new Map())

  const remove = useCallback((key: string) => {
    timers.current.delete(key)
    setToasts((list) => list.filter((toast) => toast.key !== key))
  }, [])

  useNuiEvent<NotifyData>('notify', (data) => {
    if (data === null || typeof data !== 'object') return

    counter += 1
    const key = data.id ?? `toast-${counter}`
    const toast: Toast = {
      ...data,
      key,
      type: data.type ?? 'inform',
      duration: data.duration ?? 3000,
      position: data.position ?? 'top-right',
    }

    const previous = timers.current.get(key)
    if (previous !== undefined) window.clearTimeout(previous)
    timers.current.set(key, window.setTimeout(() => remove(key), toast.duration))

    // the same id replaces the toast that is still on screen
    setToasts((list) => [...list.filter((item) => item.key !== key), toast])
  })

  return (
    <>
      {POSITIONS.map((position) => {
        const list = toasts.filter((toast) => toast.position === position)
        const fromBottom = position.startsWith('bottom')
        const slideX = position.endsWith('right') ? 24 : position.endsWith('left') ? -24 : 0

        return (
          <div key={position} className={`fixed z-40 flex w-80 max-w-[90vw] flex-col gap-2 ${POSITION_CLASS[position]}`}>
            <AnimatePresence initial={false}>
              {(fromBottom ? [...list].reverse() : list).map((toast) => (
                <motion.div
                  key={toast.key}
                  layout
                  initial={{ opacity: 0, x: slideX, y: slideX === 0 ? (fromBottom ? 16 : -16) : 0 }}
                  animate={{ opacity: 1, x: 0, y: 0 }}
                  exit={{ opacity: 0, x: slideX, y: slideX === 0 ? (fromBottom ? 16 : -16) : 0 }}
                  transition={{ duration: 0.2 }}
                  className="w-full overflow-hidden rounded-large border border-divider bg-content1/95 shadow-medium"
                >
                  <ToastBody toast={toast} />
                </motion.div>
              ))}
            </AnimatePresence>
          </div>
        )
      })}
    </>
  )
}

function ToastBody({ toast }: { toast: Toast }) {
  const type = toast.type ?? 'inform'
  const color = toast.iconColor ?? TYPE_COLOR[type]
  const icon = iconClass(toast.icon, TYPE_ICON[type])

  return (
    <div className="relative">
      <div className="flex items-start gap-3 px-4 py-3">
        {icon !== undefined && (
          <i className={`${icon} mt-0.5 text-lg`} style={{ color }} />
        )}
        <div className="min-w-0 flex-1">
          {toast.title !== undefined && toast.title !== '' && (
            <p className="text-small font-semibold leading-tight">{toast.title}</p>
          )}
          {toast.description !== undefined && toast.description !== '' && (
            <p className={`whitespace-pre-line break-words text-small text-default-500 ${toast.title ? 'mt-1' : ''}`}>
              {toast.description}
            </p>
          )}
        </div>
      </div>
      {toast.showDuration === true && (
        <div className="h-0.5 w-full bg-default-100">
          <div
            className="rec-progress-fill h-full"
            style={{ backgroundColor: color, animationDuration: `${toast.duration}ms` }}
          />
        </div>
      )}
    </div>
  )
}
