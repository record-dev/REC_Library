import { AnimatePresence, motion } from 'framer-motion'
import { NOTIFY_ICON, NOTIFY_POSITIONS, useNotifications, type Toast } from '../../features/useNotifications'
import { iconClass } from '../../nui'
import type { NotifyPosition, NotifyType } from '../../types'
import { resolveColor, tint } from './palette'

// the Mantine colour names ox_lib picks per type
const TYPE_COLOR: Record<NotifyType, string> = {
  inform: 'blue.6',
  success: 'teal.6',
  warning: 'yellow.6',
  error: 'red.6',
}

// react-hot-toast columns, 16px from the edge
const POSITION_STYLE: Record<NotifyPosition, React.CSSProperties> = {
  top: { top: 16, left: '50%', transform: 'translateX(-50%)', alignItems: 'center' },
  'top-right': { top: 16, right: 16, alignItems: 'flex-end' },
  'top-left': { top: 16, left: 16, alignItems: 'flex-start' },
  bottom: { bottom: 16, left: '50%', transform: 'translateX(-50%)', alignItems: 'center' },
  'bottom-right': { bottom: 16, right: 16, alignItems: 'flex-end' },
  'bottom-left': { bottom: 16, left: 16, alignItems: 'flex-start' },
  'center-right': { top: '50%', right: 16, transform: 'translateY(-50%)', alignItems: 'flex-end' },
  'center-left': { top: '50%', left: 16, transform: 'translateY(-50%)', alignItems: 'flex-start' },
}

function slideFrom(position: NotifyPosition): { x: number; y: number } {
  if (position === 'top' || position === 'bottom') return { x: 0, y: position === 'top' ? -30 : 30 }
  return { x: position.endsWith('right') ? 35 : -35, y: 0 }
}

export default function Notifications() {
  const toasts = useNotifications()

  return (
    <>
      {NOTIFY_POSITIONS.map((position) => {
        const list = toasts.filter((toast) => toast.position === position)
        const fromBottom = position.startsWith('bottom')
        const from = slideFrom(position)

        return (
          <div key={position} className="ox-toasts" style={POSITION_STYLE[position]}>
            <AnimatePresence initial={false}>
              {(fromBottom ? [...list].reverse() : list).map((toast) => (
                <motion.div
                  key={toast.key}
                  layout
                  initial={{ opacity: 0, ...from }}
                  animate={{ opacity: 1, x: 0, y: 0, transition: { duration: 0.2, ease: 'easeOut' } }}
                  exit={{ opacity: 0, ...from, transition: { duration: 0.4, ease: 'easeIn' } }}
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
  const colorName = toast.iconColor ?? TYPE_COLOR[toast.type]
  const color = resolveColor(colorName)
  const icon = iconClass(toast.icon, NOTIFY_ICON[toast.type])
  const hasTitle = toast.title !== undefined && toast.title !== ''

  const themeIcon = icon !== undefined && (
    <div className="ox-notify__icon" style={{ background: tint(colorName), color }}>
      <i className={`${icon} fa-fw`} />
    </div>
  )

  return (
    <div className="ox-notify">
      {icon !== undefined && toast.showDuration === true ? (
        <div className="ox-notify__ring">
          <svg viewBox="0 0 38 38" width="38" height="38">
            <circle className="ox-notify__ring-track" cx="19" cy="19" r="18" />
            <circle
              className="ox-notify__ring-bar"
              cx="19"
              cy="19"
              r="18"
              style={{ stroke: color, animationDuration: `${toast.duration}ms` }}
            />
          </svg>
          {themeIcon}
        </div>
      ) : (
        themeIcon
      )}
      <div className="ox-notify__body">
        {hasTitle && <p className="ox-notify__title">{toast.title}</p>}
        {toast.description !== undefined && toast.description !== '' && (
          <p className={`ox-notify__description ${hasTitle ? '' : 'ox-notify__description--only'}`}>{toast.description}</p>
        )}
      </div>
    </div>
  )
}
