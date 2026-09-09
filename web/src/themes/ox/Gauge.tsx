import { AnimatePresence, motion } from 'framer-motion'
import { RING_LENGTH, RING_RADIUS, groupGauges, useGauges, type GaugeEntry } from '../../features/useGauge'
import { helpTextHiddenState, helpTextWrapperStyle } from '../../features/useHelpText'
import { t } from '../../i18n'
import { iconClass } from '../../nui'
import type { GaugeConfig } from '../../types'

function Bar({ entry, config }: { entry: GaugeEntry; config: GaugeConfig }) {
  const data = entry.data
  const icon = iconClass(data.icon)
  const hasHeader = data.label !== undefined || icon !== undefined || data.showValue === true

  return (
    <div className="ox-gauge" style={{ width: config.width, fontSize: `${14 * config.fontScale}px` }}>
      {hasHeader && (
        <div className="ox-gauge__header">
          {icon !== undefined && <i className={`${icon} fa-fw ox-gauge__icon`} style={{ color: data.color }} />}
          <span className="ox-gauge__label">{data.label ?? ''}</span>
          {data.showValue === true && <span className="ox-gauge__value ox-mono">{t('PERCENT', { value: data.percent })}</span>}
        </div>
      )}
      <div className="ox-gauge__track">
        <div className="ox-gauge__bar" style={{ width: `${data.percent}%`, background: data.color }} />
      </div>
    </div>
  )
}

function Ring({ entry, config }: { entry: GaugeEntry; config: GaugeConfig }) {
  const data = entry.data
  const icon = iconClass(data.icon)
  const size = RING_RADIUS * 2 + 8

  return (
    <div className="ox-gauge ox-gauge--ring" style={{ fontSize: `${14 * config.fontScale}px` }}>
      <div className="ox-gauge__ring" style={{ width: size, height: size }}>
        <svg viewBox={`0 0 ${size} ${size}`} width={size} height={size}>
          <circle className="ox-gauge__ring-track" cx={size / 2} cy={size / 2} r={RING_RADIUS} />
          <circle
            className="ox-gauge__ring-bar"
            cx={size / 2}
            cy={size / 2}
            r={RING_RADIUS}
            stroke={data.color}
            strokeDasharray={RING_LENGTH}
            strokeDashoffset={RING_LENGTH * (1 - data.percent / 100)}
          />
        </svg>
        <div className="ox-gauge__ring-center" style={{ color: data.color }}>
          {icon !== undefined && <i className={`${icon} fa-fw`} />}
          {icon === undefined && data.showValue === true && <span className="ox-gauge__value ox-mono">{t('PERCENT', { value: data.percent })}</span>}
        </div>
      </div>
      {(data.label !== undefined || (icon !== undefined && data.showValue === true)) && (
        <div className="ox-gauge__text">
          {data.label !== undefined && <span className="ox-gauge__label">{data.label}</span>}
          {icon !== undefined && data.showValue === true && <span className="ox-gauge__value ox-mono">{t('PERCENT', { value: data.percent })}</span>}
        </div>
      )}
    </div>
  )
}

/** every gauge on screen, stacked per corner, in the ox_lib box */
export default function Gauge() {
  const { entries, config } = useGauges()
  const groups = groupGauges(entries)

  return (
    <>
      {[...groups.entries()].map(([position, list]) => (
        <div key={position} className="ox-gauge-wrap" style={helpTextWrapperStyle(position, config)}>
          <AnimatePresence>
            {list.map((entry) => {
              const hidden = helpTextHiddenState(position)

              return (
                <motion.div
                  key={entry.seq}
                  initial={hidden}
                  animate={{ opacity: 1, x: 0, y: 0 }}
                  exit={hidden}
                  transition={{ duration: config.animationDuration / 1000 }}
                >
                  {entry.data.shape === 'ring' ? <Ring entry={entry} config={config} /> : <Bar entry={entry} config={config} />}
                </motion.div>
              )
            })}
          </AnimatePresence>
        </div>
      ))}
    </>
  )
}
