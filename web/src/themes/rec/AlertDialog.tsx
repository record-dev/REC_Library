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
      scrollBehavior="inside"
      shadow="lg"
      hideCloseButton
      isDismissable={false}
      isKeyboardDismissDisabled
      classNames={{
        backdrop: 'rec-modal-backdrop',
        wrapper: 'rec-interactive',
        base: 'overflow-hidden rounded-large border border-divider bg-content1',
      }}
    >
      <ModalContent>
        {data !== null && (
          <>
            <ModalHeader className={`flex-col gap-4 px-7 pb-3 pt-7 ${data.centered === true ? 'items-center text-center' : 'items-start'}`}>
              <span aria-hidden="true" className="flex h-11 w-11 shrink-0 items-center justify-center rounded-medium border border-primary/20 bg-primary/10 text-xl text-primary">
                <i className="fa-regular fa-circle-question" />
              </span>
              <span className="w-full whitespace-pre-line break-words text-xl font-semibold leading-snug tracking-tight">
                {data.header}
              </span>
            </ModalHeader>
            <ModalBody className="px-7 pb-7 pt-0">
              <p className={`whitespace-pre-line break-words text-small leading-relaxed text-default-500 ${data.centered === true ? 'text-center' : ''}`}>
                {data.content}
              </p>
            </ModalBody>
            <ModalFooter className={`grid gap-3 border-t border-divider bg-content2/30 px-7 py-5 ${data.cancel === true ? 'grid-cols-2' : 'grid-cols-1'}`}>
              {data.cancel === true && (
                <Button
                  variant="bordered"
                  color="default"
                  radius="sm"
                  className="h-auto min-h-11 min-w-0 flex-1 whitespace-normal break-words border border-divider px-4 py-2.5 font-medium text-default-600"
                  onPress={() => answer('cancel')}
                >
                  {data.labels?.cancel ?? t('CANCEL')}
                </Button>
              )}
              <Button
                color="primary"
                radius="sm"
                className="h-auto min-h-11 min-w-0 flex-1 whitespace-normal break-words px-4 py-2.5 font-semibold"
                onPress={() => answer('confirm')}
              >
                {data.labels?.confirm ?? t('CONFIRM')}
              </Button>
            </ModalFooter>
          </>
        )}
      </ModalContent>
    </Modal>
  )
}
