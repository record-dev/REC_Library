import { CircularProgress } from '@nexus-ds/react'
import { AnimatePresence, motion } from 'framer-motion'
import { useProgress } from '../../features/useProgress'

export default function ProgressBar() {
  const { data, value } = useProgress()

  // the wrappers own the centering, framer-motion overwrites transform on the animated element
  const middle = data?.position === 'middle'
  const wrapperClass = middle
    ? 'fixed inset-0 z-20 flex items-center justify-center'
    : 'fixed inset-x-0 bottom-12 z-20 flex justify-center'

  return (
    <AnimatePresence>
      {data !== null && data.circle === true && (
        <div key="circle-wrap" className={wrapperClass}>
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.9 }}
          className="flex flex-col items-center gap-2"
        >
          <CircularProgress
            aria-label={data.label ?? 'progress'}
            value={value}
            size="lg"
            color="primary"
            showValueLabel
            classNames={{ svg: 'w-20 h-20', value: 'text-small font-semibold' }}
          />
          {data.label !== undefined && <p className="text-small font-medium drop-shadow">{data.label}</p>}
        </motion.div>
        </div>
      )}

      {data !== null && data.circle !== true && (
        <div key="bar-wrap" className={wrapperClass}>
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 12 }}
          className="w-96 max-w-[80vw] overflow-hidden rounded-large border border-divider bg-content1/95 shadow-medium"
        >
          {data.label !== undefined && (
            <p className="px-4 pb-2 pt-3 text-center text-small font-medium">{data.label}</p>
          )}
          <div className="h-1.5 w-full bg-default-100">
            <div className="rec-progress-fill h-full bg-primary" style={{ animationDuration: `${data.duration}ms` }} />
          </div>
        </motion.div>
        </div>
      )}
    </AnimatePresence>
  )
}
