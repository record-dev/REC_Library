import { Button, Modal, ModalBody, ModalContent, ModalFooter, ModalHeader } from '@nexus-ds/react'
import { useAlert } from '../../features/useAlert'
import { t } from '../../i18n'

export default function AlertDialog() {
  const { data, answer } = useAlert()

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
