import { AnimatePresence, motion } from 'framer-motion'
import { RichText } from '../../components/RichText'
import { useSubtitle } from '../../features/useSubtitle'

const KEY_CLASS =
  'mx-0.5 inline-block min-w-[1.6em] rounded-small border bg-white/10 px-1.5 py-px text-center align-baseline font-mono text-[0.85em] font-bold leading-snug'

/** the objective text at the bottom of the screen, one at a time */
export default function Subtitle() {
  const { entry, config } = useSubtitle()
  const data = entry?.data ?? null
  const box = config.background === true ? 'rounded-medium bg-black/55 px-5 py-2.5' : 'px-2 py-1'

  return (
    <div className="fixed inset-x-0 z-10 flex justify-center" style={{ bottom: config.offsetY }}>
      <AnimatePresence mode="wait">
        {entry !== null && data !== null && (
          <motion.div
            key={entry.seq}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 10 }}
            transition={{ duration: config.animationDuration / 1000, ease: [0.22, 1, 0.36, 1] }}
            className={`flex flex-col items-center gap-0.5 text-center text-white [text-shadow:0_1px_3px_rgba(0,0,0,0.9)] ${box}`}
            style={{ maxWidth: config.maxWidth, fontSize: `${17 * config.fontScale}px` }}
          >
            {data.name !== undefined && data.name !== '' && (
              <span className="text-[0.8em] font-bold uppercase tracking-wider" style={{ color: data.color }}>
                {data.name}
              </span>
            )}

            <span className="break-words font-medium leading-snug">
              <RichText text={data.text} keyColor={data.color} keyClassName={KEY_CLASS} />
            </span>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
