import { useEffect, useRef, useState, type CSSProperties } from 'react'
import { useHudConfig } from '../features/useHudConfig'
import { useMenu } from '../features/useMenu'
import { t } from '../i18n'
import { iconClass } from '../nui'
import type { MenuItem } from '../types'
import { RichText } from './RichText'
import './menu.css'

/** black or white, whichever reads on the accent colour (same rule as MenuV) */
function contrastColor(hex: string): string {
  const match = /^#([0-9a-f]{6})$/i.exec(hex)
  if (match === null) return '#fff'
  const value = parseInt(match[1], 16)
  const luminance = (0.299 * (value >> 16) + 0.587 * ((value >> 8) & 255) + 0.114 * (value & 255)) / 255
  return luminance > 0.5 ? '#000' : '#fff'
}

function Text({ text }: { text: string }) {
  return <RichText text={text} keyClassName="rec-menu-key" literalNumericBrackets />
}

function Arrow({ direction }: { direction: 'left' | 'right' | 'up' | 'down' }) {
  return <span className="rec-menu-arrow" data-direction={direction} aria-hidden />
}

function Icon({ icon }: { icon: string }) {
  return <span className="rec-menu-icon" aria-hidden>
    {/[^\u0000-\u007f]/.test(icon) ? icon : <i className={iconClass(icon)} />}
  </span>
}

function Value({ item }: { item: MenuItem }) {
  if (item.type === 'checkbox') return <span className="rec-menu-checkbox" data-checked={item.value === true} role="img" aria-label={t(item.value === true ? 'MENU_YES' : 'MENU_NO')} />
  if (item.type === 'confirm') return <span>{t(item.value === true ? 'MENU_YES' : 'MENU_NO')}</span>
  if (item.type === 'submenu') return <span className="rec-menu-submenu-arrow" aria-hidden />
  if (item.type === 'range') {
    const min = item.min ?? 0, max = item.max ?? 100
    const percent = max === min ? 0 : Math.min(100, Math.max(0, (Number(item.value) - min) / (max - min) * 100))
    return <span className="rec-menu-range"><span className="rec-menu-track"><span style={{ left: `${percent}%` }} /></span><span>{item.value}</span></span>
  }
  if (item.type === 'slider') return <Text text={item.values?.find((entry) => entry.value === item.value)?.label ?? ''} />
  return item.value === undefined ? null : <Text text={String(item.value)} />
}

export default function Menu() {
  const { menu, enabled, action } = useMenu()
  const layout = useHudConfig().menu
  const list = useRef<HTMLDivElement>(null)
  const root = useRef<HTMLElement>(null)
  const [overflow, setOverflow] = useState(false)

  useEffect(() => {
    const selected = list.current?.querySelector<HTMLElement>('[data-selected="true"]')
    selected?.scrollIntoView({ block: 'nearest' })
  }, [menu?.selected, menu?.token])

  useEffect(() => {
    if (menu !== null && enabled) root.current?.focus({ preventScroll: true })
  }, [menu?.token, enabled])

  useEffect(() => {
    const element = list.current
    if (element === null) return
    const measure = () => setOverflow(element.scrollHeight > element.clientHeight + 1)
    const observer = new ResizeObserver(measure)
    observer.observe(element)
    measure()
    return () => observer.disconnect()
  }, [menu])

  if (menu === null) return null
  const selected = menu.items.find((item) => item.id === menu.selected)
  const description = selected?.type === 'slider'
    ? selected.values?.find((choice) => choice.value === selected.value)?.description ?? selected.description
    : selected?.description
  const style = {
    '--menu-color': menu.color,
    '--menu-contrast': contrastColor(menu.color),
    '--menu-offset-x': layout.offsetX,
    '--menu-offset-y': layout.offsetY,
    '--menu-width': `${menu.width}px`,
    '--menu-visible': menu.visibleItems,
  } as CSSProperties

  return (
    <>
      <section ref={root} tabIndex={-1} className="rec-menu rec-interactive" data-position={menu.position} data-enabled={enabled} style={style} aria-label={menu.title}>
        <header className="rec-menu-banner" style={menu.banner ? { backgroundImage: `url(${JSON.stringify(menu.banner)})` } : undefined}>
          <h1><Text text={menu.title} /></h1>
        </header>
        <div className="rec-menu-subtitle">
          <span><Text text={menu.subtitle?.trim() || menu.title} /></span>
        </div>
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
                  {item.icon && <Icon icon={item.icon} />}
                  <span className="rec-menu-label-text"><Text text={item.label} /></span>
                  {adjustable === false && <span className="rec-menu-value"><Value item={item} /></span>}
                </button>
                {adjustable && <div className="rec-menu-adjust">
                  <button type="button" disabled={disabled} aria-label={t('MENU_PREVIOUS', { label: item.label })} onClick={() => action('change', item.id, -1)}><Arrow direction="left" /></button>
                  <span className="rec-menu-value"><Value item={item} /></span>
                  <button type="button" disabled={disabled} aria-label={t('MENU_NEXT', { label: item.label })} onClick={() => action('change', item.id, 1)}><Arrow direction="right" /></button>
                </div>}
              </div>
            )
          })}
        </div>
        {overflow && <div className="rec-menu-scroll" aria-hidden><Arrow direction="up" /><Arrow direction="down" /></div>}
        {description && <div className="rec-menu-description"><Text text={description} /></div>}
      </section>
      <footer className="rec-menu-footer rec-interactive" data-enabled={enabled}>
        <span>{t('MENU_NAVIGATE')}<kbd>{t('MENU_KEY_UP')}</kbd><kbd>{t('MENU_KEY_DOWN')}</kbd></span>
        <button type="button" disabled={enabled === false || selected === undefined} onClick={() => action('select', menu.selected)}>{t('MENU_CONFIRM')}<kbd>{t('MENU_KEY_CONFIRM')}</kbd></button>
        {(menu.canBack || menu.canClose) && <button type="button" disabled={enabled === false} onClick={() => action('back')}>{t(menu.canBack ? 'MENU_BACK' : 'MENU_CLOSE')}<kbd>{t('MENU_KEY_BACK')}</kbd></button>}
      </footer>
    </>
  )
}
