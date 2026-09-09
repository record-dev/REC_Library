import { AnimatePresence, motion } from 'framer-motion'
import { RING_LENGTH, RING_RADIUS, groupGauges, useGauges, type GaugeEntry } from '../../features/useGauge'
import { helpTextHiddenState, helpTextWrapperStyle } from '../../features/useHelpText'
import { t } from '../../i18n'
import { iconClass } from '../../nui'
import type { GaugeConfig } from '../../types'

const CARD_CLASS = 'rounded-medium border border-divider bg-content1/95 text-foreground shadow-medium'

function Bar({ entry, config }: { entry: GaugeEntry; config: GaugeConfig }) {
  const data = entry.data
  const icon = iconClass(data.icon)
  const hasHeader = data.label !== undefined || icon !== undefined || data.showValue === true

  return (
    <div className={`${CARD_CLASS} px-3.5 py-2.5`} style={{ width: config.width, fontSize: `${13 * config.fontScale}px` }}>
      {hasHeader && (
        <div className="mb-2 flex items-center gap-2 leading-none">
          {icon !== undefined && <i className={`${icon} fa-fw text-small`} style={{ color: data.color }} />}
          <span className="min-w-0 flex-1 truncate font-medium">{data.label ?? ''}</span>
          {data.showValue === true && (
            <span className="shrink-0 font-mono text-[0.85em] text-foreground/70">{t('PERCENT', { value: data.percent })}</span>
          )}
        </div>
      )}
      <div className="h-1.5 w-full overflow-hidden rounded-full bg-default-100">
        <div className="rec-gauge-fill h-full rounded-full" style={{ width: `${data.percent}%`, background: data.color }} />
      </div>
    </div>
  )
}

function Ring({ entry, config }: { entry: GaugeEntry; config: GaugeConfig }) {
  const data = entry.data
  const icon = iconClass(data.icon)
  const size = RING_RADIUS * 2 + 8

  return (
    <div className={`${CARD_CLASS} flex items-center gap-3 px-3 py-2.5`} style={{ fontSize: `${13 * config.fontScale}px` }}>
      <div className="relative shrink-0" style={{ width: size, height: size }}>
        <svg className="absolute inset-0 -rotate-90" viewBox={`0 0 ${size} ${size}`} width={size} height={size}>
          <circle cx={size / 2} cy={size / 2} r={RING_RADIUS} fill="none" strokeWidth="5" className="stroke-default-100" />
          <circle
            cx={size / 2}
            cy={size / 2}
            r={RING_RADIUS}
            fill="none"
            strokeWidth="5"
            strokeLinecap="round"
            stroke={data.color}
            strokeDasharray={RING_LENGTH}
            strokeDashoffset={RING_LENGTH * (1 - data.percent / 100)}
            className="rec-gauge-ring"
          />
        </svg>
        <div className="absolute inset-0 flex items-center justify-center" style={{ color: data.color }}>
          {icon !== undefined && <i className={`${icon} text-medium`} />}
          {icon === undefined && data.showValue === true && (
            <span className="font-mono text-[0.85em] text-foreground/80">{t('PERCENT', { value: data.percent })}</span>
          )}
        </div>
      </div>
      {(data.label !== undefined || (icon !== undefined && data.showValue === true)) && (
        <div className="flex min-w-0 flex-col leading-tight">
          {data.label !== undefined && <span className="truncate font-medium">{data.label}</span>}
          {icon !== undefined && data.showValue === true && (
            <span className="font-mono text-[0.85em] text-foreground/70">{t('PERCENT', { value: data.percent })}</span>
          )}
        </div>
      )}
    </div>
  )
}

/** every gauge on screen, stacked per corner */
export default function Gauge() {
  const { entries, config } = useGauges()
  const groups = groupGauges(entries)

  return (
    <>
      {[...groups.entries()].map(([position, list]) => (
        <div key={position} className="fixed z-10 flex flex-col gap-2" style={helpTextWrapperStyle(position, config)}>
          <AnimatePresence>
            {list.map((entry) => {
              const hidden = helpTextHiddenState(position)

              return (
                <motion.div
                  key={entry.seq}
                  initial={hidden}
                  animate={{ opacity: 1, x: 0, y: 0 }}
                  exit={hidden}
                  transition={{ duration: config.animationDuration / 1000, ease: [0.22, 1, 0.36, 1] }}
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
