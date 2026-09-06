import { useEffect, useRef, useState, type ReactNode } from 'react'
import ColorPicker from '../../components/ColorPicker'
import { useInput, type InputValue } from '../../features/useInput'
import { t } from '../../i18n'
import { iconClass } from '../../nui'
import type { InputRow } from '../../types'
import Modal from './Modal'

export default function InputDialog() {
  const { data, values, allowCancel, complete, close, setValue } = useInput()

  return (
    <Modal open={data !== null} size="xs" centered title={data?.heading}>
      {data !== null && (
        <form
          className="ox-modal__body"
          onSubmit={(event) => {
            event.preventDefault()
            if (complete) close(true)
          }}
        >
          {data.rows.map((row, index) => (
            <Row key={index} row={row} value={values[index]} onChange={(value) => setValue(index, value)} />
          ))}
          <div className="ox-modal__actions">
            <button type="button" className="ox-btn ox-btn--default" style={{ marginRight: 3 }} disabled={allowCancel === false} onClick={() => close(false)}>
              {t('CANCEL')}
            </button>
            <button type="submit" className="ox-btn ox-btn--light" disabled={complete === false}>
              {t('CONFIRM')}
            </button>
          </div>
        </form>
      )}
    </Modal>
  )
}

interface FieldProps {
  row: InputRow
  children: ReactNode
  /** something on the right of the label, the slider value */
  aside?: ReactNode
}

function Field({ row, children, aside }: FieldProps) {
  const icon = iconClass(row.icon)

  return (
    <div className="ox-field">
      <label className={`ox-field__label ${aside !== undefined ? 'ox-field__label--row' : ''}`}>
        {row.label}
        {row.required === true && <span className="ox-field__required">*</span>}
        {aside}
      </label>
      {row.description !== undefined && <p className="ox-field__description">{row.description}</p>}
      <div className="ox-field__control">
        {icon !== undefined && (
          <div className="ox-field__icon">
            <i className={`${icon} fa-fw`} />
          </div>
        )}
        {children}
      </div>
    </div>
  )
}

interface RowProps {
  row: InputRow
  value: InputValue
  onChange: (value: InputValue) => void
}

function Row({ row, value, onChange }: RowProps) {
  const hasIcon = iconClass(row.icon) !== undefined
  const inputClass = `ox-input ${hasIcon ? 'ox-input--icon' : ''}`

  switch (row.type) {
    case 'number':
      return (
        <Field row={row}>
          <input
            type="number"
            className={inputClass}
            placeholder={row.placeholder}
            min={row.min}
            max={row.max}
            step={row.step}
            disabled={row.disabled === true}
            value={value === null ? '' : String(value)}
            onChange={(event) => onChange(event.target.value)}
          />
        </Field>
      )

    case 'checkbox':
      return (
        <label className={`ox-checkbox ${row.disabled === true ? 'ox-checkbox--disabled' : ''}`}>
          <input type="checkbox" checked={value === true} disabled={row.disabled === true} onChange={(event) => onChange(event.target.checked)} />
          <span className="ox-checkbox__box">
            <i className="fa-solid fa-check" />
          </span>
          <span>
            <span className="ox-checkbox__label">
              {row.label}
              {row.required === true && <span className="ox-field__required">*</span>}
            </span>
            {row.description !== undefined && <p className="ox-checkbox__description">{row.description}</p>}
          </span>
        </label>
      )

    case 'select':
    case 'multi-select':
      return (
        <Field row={row}>
          <SelectControl row={row} value={value} onChange={onChange} hasIcon={hasIcon} />
        </Field>
      )

    case 'slider': {
      const min = row.min ?? 0
      const max = row.max ?? 100
      const current = typeof value === 'number' ? value : min
      const fill = max > min ? ((current - min) / (max - min)) * 100 : 0

      return (
        <Field row={row} aside={<span className="ox-slider-value ox-mono">{current}</span>}>
          <input
            type="range"
            className="ox-slider"
            style={{ '--ox-slider-fill': `${fill}%` } as React.CSSProperties}
            min={min}
            max={max}
            step={row.step ?? 1}
            value={current}
            disabled={row.disabled === true}
            onChange={(event) => onChange(Number(event.target.value))}
          />
        </Field>
      )
    }

    case 'color':
      return (
        <Field row={{ ...row, icon: undefined }}>
          <ColorPicker
            value={typeof value === 'string' ? value : '#000000'}
            placeholder={row.placeholder}
            disabled={row.disabled === true}
            onChange={(hex) => onChange(hex)}
            classNames={{ hex: 'ox-input' }}
          />
        </Field>
      )

    case 'date':
    case 'time':
      return (
        <Field row={row}>
          <input
            type={row.type}
            className={inputClass}
            disabled={row.disabled === true}
            value={typeof value === 'string' ? value : ''}
            onChange={(event) => onChange(event.target.value)}
          />
        </Field>
      )

    case 'textarea':
      return (
        <Field row={row}>
          <AutoTextarea row={row} value={typeof value === 'string' ? value : ''} onChange={onChange} className={inputClass} />
        </Field>
      )

    default:
      return (
        <Field row={row}>
          <input
            type={row.password === true ? 'password' : 'text'}
            className={inputClass}
            placeholder={row.placeholder}
            minLength={row.min}
            maxLength={row.max}
            disabled={row.disabled === true}
            value={typeof value === 'string' ? value : ''}
            onChange={(event) => onChange(event.target.value)}
          />
        </Field>
      )
  }
}

interface AutoTextareaProps {
  row: InputRow
  value: string
  className: string
  onChange: (value: InputValue) => void
}

function AutoTextarea({ row, value, className, onChange }: AutoTextareaProps) {
  const ref = useRef<HTMLTextAreaElement>(null)

  useEffect(() => {
    if (row.autosize !== true || ref.current === null) return
    ref.current.style.height = 'auto'
    ref.current.style.height = `${ref.current.scrollHeight + 2}px`
  }, [value, row.autosize])

  return (
    <textarea
      ref={ref}
      className={className}
      rows={row.autosize === true ? 1 : 3}
      placeholder={row.placeholder}
      minLength={row.min}
      maxLength={row.max}
      disabled={row.disabled === true}
      value={value}
      onChange={(event) => onChange(event.target.value)}
    />
  )
}

interface SelectControlProps {
  row: InputRow
  value: InputValue
  hasIcon: boolean
  onChange: (value: InputValue) => void
}

function SelectControl({ row, value, hasIcon, onChange }: SelectControlProps) {
  const [open, setOpen] = useState(false)
  const [query, setQuery] = useState('')
  const wrapper = useRef<HTMLDivElement>(null)
  const multiple = row.type === 'multi-select'
  const options = Array.isArray(row.options) ? row.options : []
  const selected = multiple ? (Array.isArray(value) ? value : []) : typeof value === 'string' ? [value] : []
  const labelOf = (key: string) => options.find((option) => option.value === key)?.label ?? key
  const shown = row.searchable === true && query !== '' ? options.filter((option) => (option.label ?? option.value).toLowerCase().includes(query.toLowerCase())) : options

  useEffect(() => {
    if (open === false) return

    const onDown = (event: MouseEvent) => {
      if (wrapper.current !== null && wrapper.current.contains(event.target as Node) === false) setOpen(false)
    }

    window.addEventListener('mousedown', onDown)
    return () => window.removeEventListener('mousedown', onDown)
  }, [open])

  const toggle = (key: string) => {
    if (multiple) {
      onChange(selected.includes(key) ? selected.filter((item) => item !== key) : [...selected, key])
      return
    }
    onChange(row.clearable === true && selected[0] === key ? null : key)
    setOpen(false)
  }

  return (
    <div ref={wrapper}>
      <button
        type="button"
        className={`ox-input ox-input--select ${multiple ? 'ox-input--multi' : ''} ${hasIcon ? 'ox-input--icon' : ''} ${open ? 'ox-input--open' : ''}`}
        disabled={row.disabled === true}
        onClick={() => setOpen((state) => !state)}
      >
        {selected.length === 0 ? (
          <span className="ox-input__placeholder">{row.placeholder ?? t('SELECT_PLACEHOLDER')}</span>
        ) : multiple ? (
          <span className="ox-input__chips">
            {selected.map((key) => (
              <span key={key} className="ox-chip">
                <span>{labelOf(key)}</span>
                <button
                  type="button"
                  aria-label={t('CLOSE')}
                  onClick={(event) => {
                    event.stopPropagation()
                    toggle(key)
                  }}
                >
                  <i className="fa-solid fa-xmark" />
                </button>
              </span>
            ))}
          </span>
        ) : (
          <span className="ox-input__value">{labelOf(selected[0])}</span>
        )}
        <i className="fa-solid fa-chevron-down ox-input__chevron" />
      </button>

      {open && (
        <div className="ox-dropdown">
          {row.searchable === true && (
            <input
              type="text"
              className="ox-input"
              style={{ marginBottom: 4 }}
              autoFocus
              placeholder={t('SELECT_PLACEHOLDER')}
              value={query}
              onChange={(event) => setQuery(event.target.value)}
            />
          )}
          {shown.length === 0 && <p className="ox-dropdown__empty">-</p>}
          {shown.map((option) => {
            const active = selected.includes(option.value)
            return (
              <button
                key={option.value}
                type="button"
                className={`ox-dropdown__item ${active ? 'ox-dropdown__item--selected' : ''}`}
                onClick={() => toggle(option.value)}
              >
                <span>{option.label ?? option.value}</span>
                {multiple && active && <i className="fa-solid fa-check" />}
              </button>
            )
          })}
        </div>
      )}
    </div>
  )
}
