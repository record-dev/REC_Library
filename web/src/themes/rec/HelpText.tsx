import { AnimatePresence, motion } from 'framer-motion'
import { RichText } from '../../components/RichText'
import { helpTextHiddenState, helpTextWrapperStyle, useHelpText } from '../../features/useHelpText'
import { iconClass } from '../../nui'

const KEY_CLASS =
  'mx-0.5 inline-block min-w-[1.6em] rounded-small border bg-foreground/10 px-1.5 py-px text-center align-baseline font-mono text-[0.85em] font-bold leading-snug'

/** the control hint, one on screen at a time */
export default function HelpText() {
  const { entry, config } = useHelpText()
  const data = entry?.data ?? null
  const position = data?.position ?? config.position
  const icon = iconClass(data?.icon)
  const hidden = helpTextHiddenState(position)

  return (
    <div className="fixed z-10" style={helpTextWrapperStyle(position, config)}>
      <AnimatePresence mode="wait">
        {entry !== null && data !== null && (
          <motion.div
            key={entry.seq}
            initial={hidden}
            animate={{ opacity: 1, x: 0, y: 0 }}
            exit={hidden}
            transition={{ duration: config.animationDuration / 1000, ease: [0.22, 1, 0.36, 1] }}
            className="flex items-center gap-3 rounded-medium border border-divider bg-content1/95 px-3.5 py-2.5 text-foreground shadow-medium"
            style={{ fontSize: `${14 * config.fontScale}px` }}
          >
            {icon !== undefined && (
              <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-small bg-foreground/10" style={{ color: data.color }}>
                <i className={`${icon} text-medium`} />
              </div>
            )}

            <span className="break-words leading-relaxed">
              <RichText text={data.text} keyColor={data.color} keyClassName={KEY_CLASS} />
            </span>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
