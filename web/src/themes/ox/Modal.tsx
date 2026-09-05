import { AnimatePresence, motion } from 'framer-motion'
import type { ReactNode } from 'react'

interface ModalProps {
  open: boolean
  title?: string
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl'
  centered?: boolean
  children?: ReactNode
}

/** Mantine v6 modal: dark[7] panel, 4px radius, 20px padding, 50 % overlay, 150ms fade */
export default function Modal({ open, title, size, centered, children }: ModalProps) {
  return (
    <AnimatePresence>
      {open && (
        <motion.div
          key="overlay"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
          className={`rec-interactive ox-overlay ${centered === true ? 'ox-overlay--centered' : ''}`}
        >
          <div className={`ox-modal ox-modal--${size ?? 'md'}`}>
            {title !== undefined && title !== '' && (
              <div className="ox-modal__header">
                <p className="ox-modal__title">{title}</p>
              </div>
            )}
            <div className="ox-modal__body">{children}</div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
