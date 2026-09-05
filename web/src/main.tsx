import { NexusUIProvider } from '@nexus-ds/react'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './styles.css'

ReactDOM.createRoot(document.getElementById('app')!).render(
  <React.StrictMode>
    <NexusUIProvider>
      <App />
    </NexusUIProvider>
  </React.StrictMode>,
)
