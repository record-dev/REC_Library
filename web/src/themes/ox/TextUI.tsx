import { AnimatePresence, motion } from 'framer-motion'
import { useTextUI } from '../../features/useTextUI'
import { iconClass } from '../../nui'
import type { TextUIData } from '../../types'

type Position = NonNullable<TextUIData['position']>

const WRAPPER_STYLE: Record<Position, React.CSSProperties> = {
  'right-center': { alignItems: 'center', justifyContent: 'flex-end' },
  'left-center': { alignItems: 'center', justifyContent: 'flex-start' },
  'top-center': { alignItems: 'flex-start', justifyContent: 'center' },
  'bottom-center': { alignItems: 'flex-end', justifyContent: 'center' },
}

// Mantine slide-left / slide-right / slide-down / slide-up
const SLIDE: Record<Position, { x?: string; y?: string }> = {
  'right-center': { x: '100%' },
  'left-center': { x: '-100%' },
  'top-center': { y: '-100%' },
  'bottom-center': { y: '100%' },
}

export default function TextUI() {
  const data = useTextUI()
  const position = data?.position ?? 'right-center'
  const icon = iconClass(data?.icon)
  const style = data?.style !== undefined && Array.isArray(data.style) === false ? data.style : undefined

  return (
    <div className="ox-textui-wrap" style={WRAPPER_STYLE[position]}>
      <AnimatePresence>
        {data !== null && (
          <motion.div
            key="textui"
            initial={{ opacity: 0, ...SLIDE[position] }}
            animate={{ opacity: 1, x: 0, y: 0 }}
            exit={{ opacity: 0, ...SLIDE[position] }}
            transition={{ duration: 0.25 }}
            className={`ox-textui ${data.alignIcon === 'top' ? 'ox-textui--icon-top' : ''}`}
            style={style}
          >
            {icon !== undefined && <i className={`${icon} fa-fw ox-textui__icon`} style={{ color: data.iconColor }} />}
            <p className="ox-textui__text">{data.text}</p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
