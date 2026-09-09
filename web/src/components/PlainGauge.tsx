import type { GaugeEntry } from '../features/useGauge'
import { RING_LENGTH, RING_RADIUS } from '../features/useGauge'
import { t } from '../i18n'
import type { GaugeConfig } from '../types'

// The native meter REC_HeistManager used to draw, in CSS: DrawRect 0.1 x 0.012 of the screen
// with a black 160/255 back and a 230/255 fill, the caption 0.035 above in font 4 at scale 0.34.

/** the same in every skin, so a plain gauge looks identical whatever theme is on */
export default function PlainGauge({ entry, config }: { entry: GaugeEntry; config: GaugeConfig }) {
  const data = entry.data
  const caption = data.showValue === true ? `${data.label ?? ''} ${t('PERCENT', { value: data.percent })}`.trim() : data.label
  const captionStyle = { color: data.color, opacity: 220 / 255, fontSize: `${2.2 * config.fontScale}vh` }

  if (data.shape === 'ring') {
    const size = RING_RADIUS * 2 + 8

    return (
      <div className="flex flex-col items-center gap-[0.6vh]">
        {caption !== undefined && caption !== '' && <span className="rec-gauge-plain-caption text-center" style={captionStyle}>{caption}</span>}
        <svg className="-rotate-90" viewBox={`0 0 ${size} ${size}`} width={size} height={size}>
          <circle cx={size / 2} cy={size / 2} r={RING_RADIUS} fill="none" strokeWidth="5" stroke="rgba(0, 0, 0, 0.63)" />
          <circle
            cx={size / 2}
            cy={size / 2}
            r={RING_RADIUS}
            fill="none"
            strokeWidth="5"
            stroke={data.color}
            strokeOpacity={230 / 255}
            strokeDasharray={RING_LENGTH}
            strokeDashoffset={RING_LENGTH * (1 - data.percent / 100)}
            className="rec-gauge-ring"
          />
        </svg>
      </div>
    )
  }

  return (
    <div className="flex flex-col items-center" style={{ width: data.width ?? config.width }}>
      {caption !== undefined && caption !== '' && (
        <span className="rec-gauge-plain-caption mb-[0.9vh] whitespace-nowrap text-center" style={captionStyle}>
          {caption}
        </span>
      )}
      <div className="w-full" style={{ height: '1.2vh', background: 'rgba(0, 0, 0, 0.63)' }}>
        <div className="rec-gauge-fill h-full" style={{ width: `${data.percent}%`, background: data.color, opacity: 230 / 255 }} />
      </div>
    </div>
  )
}
