import { Button, Progress, ScrollShadow } from '@nexus-ds/react'
import { AnimatePresence, motion } from 'framer-motion'
import { showsArrow, useContextMenu } from '../../features/useContextMenu'
import { t } from '../../i18n'
import { iconClass } from '../../nui'
import type { ContextOption } from '../../types'

export default function ContextMenu() {
  const { menu, canClose, hoveredOption, metadata, setHovered, close, back, select } = useContextMenu()

  // the wrapper owns the centering: framer-motion writes transform on the animated
  // element, so a translate class there would be overwritten and the panel would slide down
  return (
    <div className="fixed inset-y-0 right-[calc(28vw-3rem)] z-30 flex items-center">
    <AnimatePresence>
      {menu !== null && (
        <motion.div
          key={menu.id}
          initial={{ opacity: 0, x: 24 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: 24 }}
          transition={{ duration: 0.15 }}
          className="rec-interactive flex max-h-[calc(100vh-3rem)] w-[24rem] max-w-[90vw] flex-col gap-2"
        >
          <div className="flex items-center gap-2 rounded-large border border-divider bg-content1/95 px-2 py-2 shadow-medium">
            {menu.menu !== undefined ? (
              <Button isIconOnly size="sm" variant="light" aria-label={t('BACK')} onPress={back}>
                <i className="fa-solid fa-chevron-left" />
              </Button>
            ) : (
              <div className="w-8" />
            )}
            <p className="flex-1 truncate text-center text-small font-semibold">{menu.title}</p>
            <Button isIconOnly size="sm" variant="light" aria-label={t('CLOSE')} isDisabled={canClose === false} onPress={close}>
              <i className="fa-solid fa-xmark" />
            </Button>
          </div>

          <div className="relative min-h-0 flex-1">
            <ScrollShadow className="flex max-h-[calc(100vh-8rem)] flex-col gap-1.5 pr-1">
              {menu.options.map((option, i) => (
                <OptionRow
                  key={i}
                  option={option}
                  onSelect={() => select(i + 1)}
                  onHover={(inside) => setHovered(inside ? i + 1 : null)}
                />
              ))}
            </ScrollShadow>

            {(metadata.length > 0 || hoveredOption?.image !== undefined) && (
              <div className="absolute right-full top-0 mr-2 w-56 rounded-large border border-divider bg-content1/95 p-3 text-small shadow-medium">
                {hoveredOption?.image !== undefined && (
                  <img src={hoveredOption.image} alt="" className="mb-2 w-full rounded-medium" />
                )}
                {metadata.map((entry, i) => (
                  <div key={i} className="py-0.5">
                    {entry.value !== undefined && entry.value !== null ? (
                      <div className="flex justify-between gap-2">
                        <span className="text-default-500">{entry.label}</span>
                        <span className="text-right">{String(entry.value)}</span>
                      </div>
                    ) : (
                      <span>{entry.label}</span>
                    )}
                    {typeof entry.progress === 'number' && (
                      <Progress size="sm" aria-label={entry.label ?? ''} value={entry.progress} className="mt-1" />
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        </motion.div>
      )}
    </AnimatePresence>
    </div>
  )
}

interface OptionRowProps {
  option: ContextOption
  onSelect: () => void
  onHover: (inside: boolean) => void
}

function OptionRow({ option, onSelect, onHover }: OptionRowProps) {
  const icon = iconClass(option.icon)
  const clickable = option.disabled !== true && option.readOnly !== true

  return (
    <button
      type="button"
      disabled={option.disabled === true}
      onClick={onSelect}
      onMouseEnter={() => onHover(true)}
      onMouseLeave={() => onHover(false)}
      className={`flex w-full items-center gap-3 rounded-large border border-divider bg-content1/95 px-3 py-2.5 text-left shadow-small transition-colors ${
        option.disabled === true
          ? 'cursor-not-allowed opacity-50'
          : clickable
            ? 'hover:border-primary/60 hover:bg-content2'
            : 'cursor-default'
      }`}
    >
      {icon !== undefined && (
        <i className={`${icon} w-5 text-center text-medium`} style={{ color: option.iconColor }} />
      )}
      <div className="min-w-0 flex-1">
        {option.title !== undefined && <p className="truncate text-small font-medium">{option.title}</p>}
        {option.description !== undefined && (
          <p className="whitespace-pre-line break-words text-tiny text-default-500">{option.description}</p>
        )}
        {typeof option.progress === 'number' && (
          <Progress size="sm" aria-label={option.title ?? ''} value={option.progress} className="mt-1" />
        )}
      </div>
      {showsArrow(option) && <i className="fa-solid fa-chevron-right text-tiny text-default-400" />}
    </button>
  )
}
