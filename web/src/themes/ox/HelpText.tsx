import { AnimatePresence, motion } from 'framer-motion'
import { RichText } from '../../components/RichText'
import { helpTextHiddenState, helpTextWrapperStyle, useHelpText } from '../../features/useHelpText'
import { iconClass } from '../../nui'

/** the control hint in the ox_lib textUI box */
export default function HelpText() {
  const { entry, config } = useHelpText()
  const data = entry?.data ?? null
  const position = data?.position ?? config.position
  const icon = iconClass(data?.icon)
  const hidden = helpTextHiddenState(position)

  return (
    <div className="ox-helptext-wrap" style={helpTextWrapperStyle(position, config)}>
      <AnimatePresence mode="wait">
        {entry !== null && data !== null && (
          <motion.div
            key={entry.seq}
            initial={hidden}
            animate={{ opacity: 1, x: 0, y: 0 }}
            exit={hidden}
            transition={{ duration: config.animationDuration / 1000 }}
            className="ox-textui"
            style={{ fontSize: `${16 * config.fontScale}px` }}
          >
            {icon !== undefined && <i className={`${icon} fa-fw ox-textui__icon`} style={{ color: data.color }} />}
            <p className="ox-textui__text">
              <RichText text={data.text} keyColor={data.color} keyClassName="ox-key" />
            </p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
