import { Button, Modal, ModalBody, ModalContent, ModalFooter, ModalHeader } from '@nexus-ds/react'
import { useEffect, useState } from 'react'
import { t } from '../i18n'
import { fetchNui, useNuiEvent } from '../nui'
import type { AlertData } from '../types'

export default function AlertDialog() {
  const [data, setData] = useState<AlertData | null>(null)

  useNuiEvent<AlertData>('alert', (next) => {
    if (next === null || typeof next !== 'object') return
    setData(next)
  })

  useNuiEvent('closeAlert', () => setData(null))

  const answer = (result: 'confirm' | 'cancel') => {
    setData(null)
    void fetchNui('alertClose', { result })
  }

  useEffect(() => {
    if (data === null) return

    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && data.cancel === true) answer('cancel')
      if (event.key === 'Enter') answer('confirm')
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [data])

  return (
    <Modal
      isOpen={data !== null}
      size={data?.size ?? 'md'}
      placement="center"
      backdrop="opaque"
      hideCloseButton
      isDismissable={false}
      isKeyboardDismissDisabled
      classNames={{ backdrop: 'rec-modal-backdrop', wrapper: 'rec-interactive', base: 'border border-divider bg-content1' }}
    >
      <ModalContent>
        {data !== null && (
          <>
            <ModalHeader className={`text-medium ${data.centered === true ? 'justify-center text-center' : ''}`}>
              {data.header}
            </ModalHeader>
            <ModalBody>
              <p className={`whitespace-pre-line break-words text-small text-default-600 ${data.centered === true ? 'text-center' : ''}`}>
                {data.content}
              </p>
            </ModalBody>
            <ModalFooter className={data.centered === true ? 'justify-center' : ''}>
              {data.cancel === true && (
                <Button variant="flat" color="default" onPress={() => answer('cancel')}>
                  {data.labels?.cancel ?? t('CANCEL')}
                </Button>
              )}
              <Button color="primary" onPress={() => answer('confirm')}>
                {data.labels?.confirm ?? t('CONFIRM')}
              </Button>
            </ModalFooter>
          </>
        )}
      </ModalContent>
    </Modal>
  )
}
