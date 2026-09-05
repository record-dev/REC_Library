import { useAlert } from '../../features/useAlert'
import { t } from '../../i18n'
import Modal from './Modal'

export default function AlertDialog() {
  const { data, answer } = useAlert()

  return (
    <Modal open={data !== null} size={data?.size} centered={data?.centered === true} title={data?.header}>
      {data !== null && (
        <>
          <p className="ox-modal__content">{data.content}</p>
          <div className="ox-modal__actions">
            {data.cancel === true && (
              <button type="button" className="ox-btn ox-btn--default" style={{ marginRight: 3 }} onClick={() => answer('cancel')}>
                {data.labels?.cancel ?? t('CANCEL')}
              </button>
            )}
            <button type="button" className={`ox-btn ${data.cancel === true ? 'ox-btn--light' : 'ox-btn--default'}`} onClick={() => answer('confirm')}>
              {data.labels?.confirm ?? t('CONFIRM')}
            </button>
          </div>
        </>
      )}
    </Modal>
  )
}
