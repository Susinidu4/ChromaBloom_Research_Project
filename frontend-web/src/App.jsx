import { useState } from 'react'
import './App.css'
import { Routes, Route } from 'react-router-dom'
import { Home } from './pages/other/home'
import { admin_login } from './pages/admin/admin_login'
import { therapists_login } from './pages/therapists/therapists_login'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <Routes>
        <Route path="/" element={<Home/>} />
        <Route path="/admin_login" element={<admin_login />} />
        <Route path="/therapists_login" element={<therapists_login />} />
      </Routes>
    </>
  )
}

export default App
