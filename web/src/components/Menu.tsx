import { useEffect, useRef, type CSSProperties } from 'react'
import { useMenu } from '../features/useMenu'
import { t } from '../i18n'
import { iconClass } from '../nui'
import type { MenuItem } from '../types'
import { RichText } from './RichText'
import './menu.css'

function Text({ text }: { text: string }) {
  return <RichText text={text} keyClassName="rec-menu-key" />
}

function Value({ item }: { item: MenuItem }) {
  if (item.type === 'checkbox') return <i className={`fa-regular ${item.value === true ? 'fa-square-check' : 'fa-square'}`} aria-label={t(item.value === true ? 'MENU_YES' : 'MENU_NO')} />
  if (item.type === 'confirm') return <span className="rec-menu-confirm"><span data-active={item.value === true}>{t('MENU_YES')}</span><span data-active={item.value !== true}>{t('MENU_NO')}</span></span>
  if (item.type === 'submenu') return <span aria-hidden>›</span>
  if (item.type === 'range') {
    const min = item.min ?? 0, max = item.max ?? 100
    const percent = max === min ? 0 : (Number(item.value) - min) / (max - min) * 100
    return <span className="rec-menu-range"><span className="rec-menu-track"><span style={{ width: `${percent}%` }} /></span><span>{item.value}</span></span>
  }
  if (item.type === 'slider') return <Text text={item.values?.find((entry) => entry.value === item.value)?.label ?? ''} />
  return item.value === undefined ? null : <Text text={String(item.value)} />
}

export default function Menu() {
  const { menu, enabled, action } = useMenu()
  const list = useRef<HTMLDivElement>(null)
  const root = useRef<HTMLElement>(null)

  useEffect(() => {
    const selected = list.current?.querySelector<HTMLElement>('[data-selected="true"]')
    selected?.scrollIntoView({ block: 'nearest' })
  }, [menu?.selected, menu?.token])

  useEffect(() => {
    if (menu !== null && enabled) root.current?.focus({ preventScroll: true })
  }, [menu?.token, enabled])

  if (menu === null) return null
  const selected = menu.items.find((item) => item.id === menu.selected)
  const description = selected?.type === 'slider'
    ? selected.values?.find((choice) => choice.value === selected.value)?.description ?? selected.description
    : selected?.description
  const hex = menu.color.replace('#', '')
  const rgb = [0, 2, 4].map((offset) => parseInt(hex.slice(offset, offset + 2), 16))
  const contrast = rgb[0] * 0.299 + rgb[1] * 0.587 + rgb[2] * 0.114 > 150 ? '#111111' : '#ffffff'
  const style = {
    '--menu-color': menu.color,
    '--menu-contrast': contrast,
    '--menu-width': `${menu.width}px`,
    '--menu-visible': menu.visibleItems,
  } as CSSProperties

  return (
    <section ref={root} tabIndex={-1} className="rec-menu rec-interactive" data-position={menu.position} data-enabled={enabled} style={style} aria-label={menu.title}>
      <header className="rec-menu-banner" style={menu.banner ? { backgroundImage: `url(${JSON.stringify(menu.banner)})` } : undefined}>
        <h1><Text text={menu.title} /></h1>
      </header>
      <div className="rec-menu-subtitle"><span><Text text={menu.subtitle ?? ''} /></span><span>{selected === undefined ? 0 : menu.items.indexOf(selected) + 1} / {menu.items.length}</span></div>
      <div ref={list} className="rec-menu-items" role="menu" aria-label={menu.title}>
        {menu.items.length === 0 && <div className="rec-menu-empty">{t('MENU_EMPTY')}</div>}
        {menu.items.map((item) => {
          const adjustable = ['slider', 'range', 'confirm'].includes(item.type)
          const disabled = enabled === false || item.disabled === true || item.type === 'label'
          return (
            <div key={item.id} className="rec-menu-row" data-selected={menu.selected === item.id} data-disabled={disabled}
              onMouseEnter={() => action('hover', item.id)}>
              <button type="button" className="rec-menu-label" disabled={disabled} role={item.type === 'checkbox' ? 'menuitemcheckbox' : 'menuitem'}
                aria-checked={item.type === 'checkbox' ? item.value === true : undefined}
                onFocus={() => action('hover', item.id)} onClick={() => action('select', item.id)}>
                {item.icon && <i className={iconClass(item.icon)} aria-hidden />}
                <span><Text text={item.label} /></span>
                {adjustable === false && <span className="rec-menu-value"><Value item={item} /></span>}
              </button>
              {adjustable && <div className="rec-menu-adjust">
                <button type="button" disabled={disabled} aria-label={t('MENU_PREVIOUS', { label: item.label })} onClick={() => action('change', item.id, -1)}>‹</button>
                <span className="rec-menu-value"><Value item={item} /></span>
                <button type="button" disabled={disabled} aria-label={t('MENU_NEXT', { label: item.label })} onClick={() => action('change', item.id, 1)}>›</button>
              </div>}
            </div>
          )
        })}
      </div>
      {description && <div className="rec-menu-description"><Text text={description} /></div>}
      <footer className="rec-menu-footer">
        <span><kbd>↑↓</kbd> {t('MENU_NAVIGATE')} <kbd>Enter</kbd> {t('CONFIRM')}</span>
        {(menu.canBack || menu.canClose) && <button type="button" disabled={enabled === false} onClick={() => action('back')}><kbd>Esc</kbd> {t(menu.canBack ? 'BACK' : 'CLOSE')}</button>}
      </footer>
    </section>
  )
}
