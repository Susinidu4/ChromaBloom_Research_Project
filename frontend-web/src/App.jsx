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
import DrawingLessonCreate from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonCreate";
import DrawingLessonView from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonView";
import DrawingLessonEdit from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonEdit";
import DrawingLessonList from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonList";

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

        {/* Gemified Knowledge Builder */}
        <Route path="/drawing_lessons_create" element={<DrawingLessonCreate />} />
        <Route path="/drawing_lessons/:id" element={<DrawingLessonView />} />
        <Route path="/drawing_lessons/:id/edit" element={<DrawingLessonEdit />} />
        <Route path="/drawing_lessons" element={<DrawingLessonList />} />
      </Routes>
    </>
  );
}

export default App;
