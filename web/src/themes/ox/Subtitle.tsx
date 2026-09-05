import { AnimatePresence, motion } from 'framer-motion'
import { RichText } from '../../components/RichText'
import { useSubtitle } from '../../features/useSubtitle'

/** the objective text at the bottom of the screen, Mantine dark box like the rest of the skin */
export default function Subtitle() {
  const { entry, config } = useSubtitle()
  const data = entry?.data ?? null

  return (
    <div className="ox-subtitle-wrap" style={{ bottom: config.offsetY }}>
      <AnimatePresence mode="wait">
        {entry !== null && data !== null && (
          <motion.div
            key={entry.seq}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 10 }}
            transition={{ duration: config.animationDuration / 1000 }}
            className={`ox-subtitle ${config.background === true ? '' : 'ox-subtitle--plain'}`}
            style={{ maxWidth: config.maxWidth, fontSize: `${17 * config.fontScale}px` }}
          >
            {data.name !== undefined && data.name !== '' && (
              <span className="ox-subtitle__name" style={{ color: data.color }}>
                {data.name}
              </span>
            )}
            <span className="ox-subtitle__text">
              <RichText text={data.text} keyColor={data.color} keyClassName="ox-key" />
            </span>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
