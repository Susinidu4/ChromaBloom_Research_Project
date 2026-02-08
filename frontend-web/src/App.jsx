import { useState } from "react";
import "./App.css";
import { Routes, Route } from "react-router-dom";
import { Home } from "./pages/other/home";
import AdminLayout from "./pages/admin/AdminLayout";

import { TherapistsLogin } from "./pages/therapists/therapists_login";
import Admin_Dashboard from "./pages/admin/Admin_Dashboard";
import { Therapists_register } from "./pages/therapists/Therapists_register";
import { Therapists_dashboard } from "./pages/therapists/Therapists_dashboard";
import CreateAdmin from "./pages/admin/CreateAdmin";
import AdminLogin from "./pages/admin/admin_login";
import DrawingLessonCreate from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonCreate";
import DrawingLessonView from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonView";
import DrawingLessonEdit from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonEdit";
import DrawingLessonList from "./pages/Gemified_Knowledge_Builder/Drawing_Lessons/DrawingLessonList";
import ProblemSolvingLessonCreate from "./pages/Gemified_Knowledge_Builder/Problem_Solving_Lessons/ProblemSolvingLessonCreate";
import ProblemSolvingLessonView from "./pages/Gemified_Knowledge_Builder/Problem_Solving_Lessons/ProblemSolvingLessonView";
import ProblemSolvingLessonEdit from "./pages/Gemified_Knowledge_Builder/Problem_Solving_Lessons/ProblemSolvingLessonEdit";
import ProblemSolvingLessonList from "./pages/Gemified_Knowledge_Builder/Problem_Solving_Lessons/ProblemSolvingLessonList";
import QuizeCreate from "./pages/Gemified_Knowledge_Builder/Quize/QuizeCreate";
import QuizeList from "./pages/Gemified_Knowledge_Builder/Quize/QuizeList";
import QuizeView from "./pages/Gemified_Knowledge_Builder/Quize/QuizeView";
import QuizeEdit from "./pages/Gemified_Knowledge_Builder/Quize/QuizeEdit";

import RoutineCreate from "./pages/admin/Interactive_Visual_Task_Scheduler/AddRoutine";
import RoutineList from "./pages/admin/Interactive_Visual_Task_Scheduler/RoutineList";
import RoutineDetail from "./pages/admin/Interactive_Visual_Task_Scheduler/SelectedRoutine";
import RoutineEdit from "./pages/admin/Interactive_Visual_Task_Scheduler/EditRoutine";

import StressRecommendationList from "./pages/admin/Parental_Stress_monitoring/StressRecommendationList";
import StressRecommendationDetail from "./pages/admin/Parental_Stress_monitoring/SelectedStressRecommendation";
import StressRecommendationAdd from "./pages/admin/Parental_Stress_monitoring/AddStressRecommendation";
import StressRecommendationEdit from "./pages/admin/Parental_Stress_monitoring/EditStressRecommendation";

import ChildParentDetailPage from "./pages/therapists/ChildParentDetailPage";

function App() {

  return (
    <>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/adminLayout" element={<AdminLayout />} />

        <Route path="/admin_login" element={<AdminLogin />} />
        <Route path="/create_admin" element={<CreateAdmin />} />
        <Route path="/therapists_login" element={<TherapistsLogin />} />
        <Route path="/admin_dashboard" element={<Admin_Dashboard />} />
        <Route path="/therapists_register" element={<Therapists_register />} />
        <Route path="/therapists_dashboard" element={<Therapists_dashboard />} />
        <Route path="/child_parent_detail/:id" element={<ChildParentDetailPage />} />

        {/* Interactive Visual Task Scheduler */}
        <Route path="/routine_create" element={<RoutineCreate />} />
        <Route path="/routine_list" element={<RoutineList />} />
        <Route path="/routine_detail/:id" element={<RoutineDetail />} />
        <Route path="/routine_edit/:id" element={<RoutineEdit />} />

        {/* Parental Stress Monitoring */}
        <Route path="/stress_recommendation_list" element={<StressRecommendationList />} />
        <Route path="/stress_recommendation_detail/:id" element={<StressRecommendationDetail />} />
        <Route path="/stress_recommendation_create" element={<StressRecommendationAdd/>}/> 
        <Route path="/stress_recommendation_edit/:id" element={<StressRecommendationEdit/>}/>

        {/* Gemified Knowledge Builder */}
        <Route path="/drawing_lessons_create" element={<DrawingLessonCreate />} />
        <Route path="/drawing_lessons/:id" element={<DrawingLessonView />} />
        <Route path="/drawing_lessons/:id/edit" element={<DrawingLessonEdit />} />
        <Route path="/drawing_lessons" element={<DrawingLessonList />} />

        <Route path="/problem_solving_lessons_create" element={<ProblemSolvingLessonCreate />} />
        <Route path="/problem_solving_lessons/:id" element={<ProblemSolvingLessonView />} />
        <Route path="/problem_solving_lessons/:id/edit" element={<ProblemSolvingLessonEdit />} />
        <Route path="/problem_solving_lessons" element={<ProblemSolvingLessonList />} />

        <Route path="/quizes/create" element={<QuizeCreate />} />
        <Route path="/quizes/list" element={<QuizeList />} />
        <Route path="/quizes/view/:id" element={<QuizeView />} />
        <Route path="/quizes/edit/:id" element={<QuizeEdit />} />
      </Routes>
    </>
  );
}

export default App;
