import { useState } from "react";
import "./App.css";
import { Routes, Route } from "react-router-dom";
import { Home } from "./pages/other/home";
import { AdminLogin } from "./pages/admin/Admin_login";
import { TherapistsLogin } from "./pages/therapists/Therapists_login";
import { Admin_Dashboard } from "./pages/admin/Admin_Dashboard";

function App() {

  return (
    <>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/admin_login" element={<AdminLogin />} />
        <Route path="/therapists_login" element={<TherapistsLogin />} />
        <Route path="/admin_dashboard" element={<Admin_Dashboard />} />
      </Routes>
    </>
  );
}

export default App;
