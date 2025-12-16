import { useState } from "react";
import "./App.css";
import { Routes, Route } from "react-router-dom";
import { Home } from "./pages/other/home";
import { TherapistsLogin } from "./pages/therapists/therapists_login";
import { Admin_Dashboard } from "./pages/admin/Admin_Dashboard";
import { Therapists_register } from "./pages/therapists/Therapists_register";
import { Therapists_dashboard } from "./pages/therapists/Therapists_dashboard";
import CreateAdmin from "./pages/admin/CreateAdmin";
import AdminLogin from "./pages/admin/admin_login";
import LessonCreate from "./pages/Gemified_Knowledge_Builder/LessonCreate";
import LessonView from "./pages/Gemified_Knowledge_Builder/LessonView";
import LessonEdit from "./pages/Gemified_Knowledge_Builder/LessonEdit";

function App() {

  return (
    <>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/admin_login" element={<AdminLogin />} />
        <Route path="/create_admin" element={<CreateAdmin />} />
        <Route path="/therapists_login" element={<TherapistsLogin />} />
        <Route path="/admin_dashboard" element={<Admin_Dashboard />} />
        <Route path="/therapists_register" element={<Therapists_register />} />
        <Route path="/therapists_dashboard" element={<Therapists_dashboard />} />
        <Route path="/drawing_lessons_create" element={<LessonCreate />} />
        <Route path="/lessons/:id" element={<LessonView />} />
        <Route path="/lessons/:id/edit" element={<LessonEdit />} />
      </Routes>
    </>
  );
}

export default App;
