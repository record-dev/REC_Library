import {
  Button,
  Checkbox,
  Input,
  Modal,
  ModalBody,
  ModalContent,
  ModalFooter,
  ModalHeader,
  Select,
  SelectItem,
  Textarea,
} from '@nexus-ds/react'
import { useEffect, useMemo, useState } from 'react'
import { t } from '../i18n'
import { fetchNui, iconClass, useNuiEvent } from '../nui'
import type { InputData, InputRow } from '../types'

type Value = string | number | boolean | string[] | null

function defaultValue(row: InputRow): Value {
  if (row.default !== undefined && row.default !== null) {
    if (row.type === 'multi-select') return Array.isArray(row.default) ? (row.default as string[]) : [String(row.default)]
    if (row.type === 'checkbox') return row.default === true
    if (row.type === 'slider' || row.type === 'number') return Number(row.default)
    return String(row.default)
  }

  if (row.type === 'checkbox') return false
  if (row.type === 'slider') return row.min ?? 0
  if (row.type === 'multi-select') return []
  if (row.type === 'color') return '#000000'
  return null
}

function isFilled(row: InputRow, value: Value): boolean {
  if (row.type === 'checkbox' || row.type === 'slider') return true
  if (value === null || value === undefined) return false
  if (Array.isArray(value)) return value.length > 0
  if (typeof value === 'string') return value.trim() !== ''
  return true
}

/** the value handed back to Lua, epoch ms for dates unless returnString is set */
function outputValue(row: InputRow, value: Value): unknown {
  if (row.type === 'date' && typeof value === 'string' && value !== '') {
    return row.returnString === true ? value : new Date(`${value}T00:00:00`).getTime()
  }
  if (row.type === 'number' && typeof value === 'string') {
    return value === '' ? null : Number(value)
  }
  return value
}

export default function InputDialog() {
  const [data, setData] = useState<InputData | null>(null)
  const [values, setValues] = useState<Value[]>([])

  useNuiEvent<InputData>('input', (next) => {
    if (next === null || typeof next !== 'object') return
    const rows = Array.isArray(next.rows) ? next.rows : []
    setData({ ...next, rows })
    setValues(rows.map(defaultValue))
  })

  useNuiEvent('closeInput', () => setData(null))

  const allowCancel = data !== null && !Array.isArray(data.options) && data.options.allowCancel === false ? false : true

  const complete = useMemo(() => {
    if (data === null) return false
    return data.rows.every((row, index) => row.required !== true || isFilled(row, values[index]))
  }, [data, values])

  const close = (submit: boolean) => {
    if (data === null) return
    const payload = submit ? data.rows.map((row, index) => outputValue(row, values[index])) : false
    setData(null)
    void fetchNui('inputClose', { values: payload })
  }

  useEffect(() => {
    if (data === null) return

    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && allowCancel) close(false)
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [data, allowCancel])

  const setValue = (index: number, value: Value) => {
    setValues((list) => list.map((item, i) => (i === index ? value : item)))
  }

  return (
    <Modal
      isOpen={data !== null}
      size="md"
      placement="center"
      backdrop="opaque"
      scrollBehavior="inside"
      hideCloseButton
      isDismissable={false}
      isKeyboardDismissDisabled
      classNames={{ backdrop: 'rec-modal-backdrop', wrapper: 'rec-interactive', base: 'border border-divider bg-content1' }}
    >
      <ModalContent>
        {data !== null && (
          <>
            <ModalHeader className="text-medium">{data.heading}</ModalHeader>
            <ModalBody className="gap-4">
              {data.rows.map((row, index) => (
                <Row key={index} row={row} value={values[index]} onChange={(value) => setValue(index, value)} />
              ))}
            </ModalBody>
            <ModalFooter>
              {allowCancel && (
                <Button variant="flat" color="default" onPress={() => close(false)}>
                  {t('CANCEL')}
                </Button>
              )}
              <Button color="primary" isDisabled={complete === false} onPress={() => close(true)}>
                {t('SUBMIT')}
              </Button>
            </ModalFooter>
          </>
        )}
      </ModalContent>
    </Modal>
  )
}

interface RowProps {
  row: InputRow
  value: Value
  onChange: (value: Value) => void
}

function Row({ row, value, onChange }: RowProps) {
  const icon = iconClass(row.icon)
  const startContent = icon !== undefined ? <i className={`${icon} text-default-400`} /> : undefined
  const common = {
    label: row.label,
    description: row.description,
    placeholder: row.placeholder,
    isRequired: row.required === true,
    isDisabled: row.disabled === true,
    labelPlacement: 'outside' as const,
    variant: 'bordered' as const,
  }

  switch (row.type) {
    case 'number':
      return (
        <Input
          {...common}
          type="number"
          min={row.min}
          max={row.max}
          step={row.step}
          startContent={startContent}
          value={value === null ? '' : String(value)}
          onValueChange={(next) => onChange(next)}
        />
      )

    case 'checkbox':
      return (
        <Checkbox isSelected={value === true} isDisabled={row.disabled === true} onValueChange={(next) => onChange(next)}>
          <span className="text-small">{row.label}</span>
          {row.description !== undefined && <span className="ml-2 text-tiny text-default-400">{row.description}</span>}
        </Checkbox>
      )

    case 'select':
    case 'multi-select': {
      const multiple = row.type === 'multi-select'
      const selected = multiple ? new Set(Array.isArray(value) ? value : []) : new Set(typeof value === 'string' ? [value] : [])
      const options = Array.isArray(row.options) ? row.options : []

      return (
        <Select
          {...common}
          placeholder={row.placeholder ?? t('SELECT_PLACEHOLDER')}
          selectionMode={multiple ? 'multiple' : 'single'}
          selectedKeys={selected}
          startContent={startContent}
          onSelectionChange={(keys) => {
            const list = Array.from(keys as Set<string>).map(String)
            onChange(multiple ? list : list[0] ?? null)
          }}
        >
          {options.map((option) => (
            <SelectItem key={option.value}>{option.label ?? option.value}</SelectItem>
          ))}
        </Select>
      )
    }

    case 'slider': {
      const min = row.min ?? 0
      const max = row.max ?? 100
      const current = typeof value === 'number' ? value : min

      return (
        <div className="flex flex-col gap-1">
          <div className="flex items-center justify-between text-small">
            <span>{row.label}</span>
            <span className="tabular-nums text-default-500">{current}</span>
          </div>
          <input
            type="range"
            className="rec-slider"
            min={min}
            max={max}
            step={row.step ?? 1}
            value={current}
            disabled={row.disabled === true}
            onChange={(event) => onChange(Number(event.target.value))}
          />
          {row.description !== undefined && <span className="text-tiny text-default-400">{row.description}</span>}
        </div>
      )
    }

    case 'color':
      return (
        <div className="flex flex-col gap-1">
          <span className="text-small">{row.label}</span>
          <input
            type="color"
            className="rec-color"
            value={typeof value === 'string' ? value : '#000000'}
            disabled={row.disabled === true}
            onChange={(event) => onChange(event.target.value)}
          />
          {row.description !== undefined && <span className="text-tiny text-default-400">{row.description}</span>}
        </div>
      )

    case 'date':
    case 'time':
      return (
        <Input
          {...common}
          type={row.type}
          startContent={startContent}
          value={typeof value === 'string' ? value : ''}
          onValueChange={(next) => onChange(next)}
        />
      )

    case 'textarea':
      return (
        <Textarea
          {...common}
          minRows={row.autosize === true ? 1 : 3}
          value={typeof value === 'string' ? value : ''}
          onValueChange={(next) => onChange(next)}
        />
      )

    default:
      return (
        <Input
          {...common}
          type={row.password === true ? 'password' : 'text'}
          minLength={row.min}
          maxLength={row.max}
          startContent={startContent}
          value={typeof value === 'string' ? value : ''}
          onValueChange={(next) => onChange(next)}
        />
      )
  }
}
