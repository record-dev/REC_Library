import { AnimatePresence, motion } from 'framer-motion'
import { useState } from 'react'
import { showsArrow, useContextMenu } from '../../features/useContextMenu'
import { t } from '../../i18n'
import { iconClass } from '../../nui'
import type { ContextOption } from '../../types'
import { resolveColor } from './palette'

interface Anchor {
  top: number
  left: number
}

function isImage(icon: string): boolean {
  return icon.includes('://') || icon.includes('.png') || icon.includes('.webp')
}

export default function ContextMenu() {
  const { menu, canClose, hoveredOption, metadata, setHovered, close, back, select } = useContextMenu()
  // the metadata card is a fixed element next to the hovered row, the list clips its overflow
  const [anchor, setAnchor] = useState<Anchor | null>(null)

  const hasCard = hoveredOption !== undefined && (metadata.length > 0 || hoveredOption.image !== undefined)

  // the card sits outside the animated panel: a transform on an ancestor would turn position: fixed into position: absolute
  return (
    <>
      <AnimatePresence>
        {menu !== null && (
          <motion.div
            key={menu.id}
            initial={{ opacity: 0, x: '100%' }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: '100%' }}
            transition={{ duration: 0.25 }}
            className="rec-interactive ox-context"
          >
            <div className="ox-context__header">
              {menu.menu !== undefined && (
                <button type="button" className="ox-context__hbtn" aria-label={t('BACK')} onClick={back}>
                  <i className="fa-solid fa-chevron-left fa-fw" />
                </button>
              )}
              <div className="ox-context__title">
                <p>{menu.title}</p>
              </div>
              <button type="button" className="ox-context__hbtn" aria-label={t('CLOSE')} disabled={canClose === false} onClick={close}>
                <i className="fa-solid fa-xmark fa-fw" />
              </button>
            </div>

            <div className="ox-context__list">
              {menu.options.map((option, i) => (
                <OptionRow
                  key={i}
                  option={option}
                  onSelect={() => select(i + 1)}
                  onHover={(rect) => {
                    setHovered(rect !== null ? i + 1 : null)
                    setAnchor(rect !== null ? { top: rect.top, left: rect.right + 8 } : null)
                  }}
                />
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {menu !== null && hasCard && anchor !== null && (
        <div className="ox-context__dropdown" style={{ top: anchor.top, left: anchor.left }}>
          {hoveredOption.image !== undefined && <img src={hoveredOption.image} alt="" />}
          {metadata.map((entry, i) => (
            <div key={i} className="ox-context__meta">
              <p>{entry.value !== undefined && entry.value !== null ? `${entry.label}: ${String(entry.value)}` : entry.label}</p>
              {typeof entry.progress === 'number' && <Bar value={entry.progress} color={hoveredOption.colorScheme} />}
            </div>
          ))}
        </div>
      )}
    </>
  )
}

function Bar({ value, color }: { value: number; color?: string }) {
  return (
    <div className="ox-bar">
      <div
        className="ox-bar__fill"
        style={{ width: `${Math.min(100, Math.max(0, value))}%`, background: color !== undefined ? resolveColor(color) : undefined }}
      />
    </div>
  )
}

interface OptionRowProps {
  option: ContextOption
  onSelect: () => void
  onHover: (rect: DOMRect | null) => void
}

function OptionRow({ option, onSelect, onHover }: OptionRowProps) {
  const icon = option.icon !== undefined && !isImage(option.icon) ? iconClass(option.icon) : undefined

  return (
    <button
      type="button"
      disabled={option.disabled === true}
      onClick={onSelect}
      onMouseEnter={(event) => onHover(event.currentTarget.getBoundingClientRect())}
      onMouseLeave={() => onHover(null)}
      className={`ox-context__btn ${option.readOnly === true ? 'ox-context__btn--readonly' : ''}`}
    >
      <div className="ox-context__stack">
        <div className="ox-context__group">
          {option.icon !== undefined && (
            <div className="ox-context__icon">
              {isImage(option.icon) ? (
                <img src={option.icon} alt="" />
              ) : (
                <i className={`${icon} fa-fw`} style={{ color: option.iconColor }} />
              )}
            </div>
          )}
          {option.title !== undefined && <p className="ox-context__text">{option.title}</p>}
        </div>
        {option.description !== undefined && <p className="ox-context__desc">{option.description}</p>}
        {typeof option.progress === 'number' && <Bar value={option.progress} color={option.colorScheme} />}
      </div>
      {showsArrow(option) && (
        <div className="ox-context__arrow">
          <i className="fa-solid fa-chevron-right fa-fw" />
        </div>
      )}
    </button>
  )
}
