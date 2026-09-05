import { AnimatePresence, motion } from 'framer-motion'
import { useProgress } from '../../features/useProgress'

export default function ProgressBar() {
  const { data, value } = useProgress()
  const middle = data?.position === 'middle'

  return (
    <AnimatePresence>
      {data !== null && data.circle === true && (
        <div key="circle-wrap" className={`ox-circle-wrap ${middle ? '' : 'ox-circle-wrap--bottom'}`}>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className={`ox-circle ${middle ? 'ox-circle--middle' : ''}`}
          >
            <div className="ox-circle__ring">
              <svg viewBox="0 0 90 90" width="90" height="90">
                <circle className="ox-circle__track" cx="45" cy="45" r="41.5" />
                <circle className="ox-circle__bar" cx="45" cy="45" r="41.5" style={{ animationDuration: `${data.duration}ms` }} />
              </svg>
              <p className="ox-circle__value ox-mono">{value}%</p>
            </div>
            {data.label !== undefined && <p className="ox-circle__label">{data.label}</p>}
          </motion.div>
        </div>
      )}

      {data !== null && data.circle !== true && (
        <div key="bar-wrap" className="ox-progress-wrap">
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="ox-progress">
            <div className="ox-progress__bar" style={{ animationDuration: `${data.duration}ms` }} />
            {data.label !== undefined && (
              <div className="ox-progress__label-wrap">
                <p className="ox-progress__label">{data.label}</p>
              </div>
            )}
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  )
}
