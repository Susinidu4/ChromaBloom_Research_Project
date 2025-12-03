import { useState } from "react";
import "./App.css";
import { Routes, Route } from "react-router-dom";
import { Home } from "./pages/other/home";
import { AdminLogin } from "./pages/admin/Admin_login";
import { TherapistsLogin } from "./pages/therapists/therapists_login";
import { Admin_Dashboard } from "./pages/admin/Admin_Dashboard";
import { Therapists_register } from "./pages/therapists/Therapists_register";
import { Therapists_dashboard } from "./pages/therapists/Therapists_dashboard";

function App() {

  return (
    <>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/admin_login" element={<AdminLogin />} />
        <Route path="/therapists_login" element={<TherapistsLogin />} />
        <Route path="/admin_dashboard" element={<Admin_Dashboard />} />
        <Route path="/therapists_register" element={<Therapists_register />} />
        <Route path="/therapists_dashboard" element={<Therapists_dashboard />} />
      </Routes>
    </>
  );
}

export default App;
