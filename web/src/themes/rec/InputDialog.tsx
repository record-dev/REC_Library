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
import ColorPicker from '../../components/ColorPicker'
import { useInput, type InputValue } from '../../features/useInput'
import { t } from '../../i18n'
import { iconClass } from '../../nui'
import type { InputRow } from '../../types'

export default function InputDialog() {
  const { data, values, allowCancel, complete, close, setValue } = useInput()

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
  value: InputValue
  onChange: (value: InputValue) => void
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
          <span className="text-small">
            {row.label}
            {row.required === true && <span className="ml-0.5 text-danger">*</span>}
          </span>
          <ColorPicker
            value={typeof value === 'string' ? value : '#000000'}
            placeholder={row.placeholder}
            disabled={row.disabled === true}
            onChange={(hex) => onChange(hex)}
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
