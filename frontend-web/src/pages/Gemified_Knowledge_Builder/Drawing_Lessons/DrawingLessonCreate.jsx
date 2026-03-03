import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { createDrawingLesson } from "../../../services/Gemified_Knowledge_Builder/drawingLessonService";
import LessonForm from "./DrawingLessonForm";
import AdminLayout from "../../admin/Admin_Management/AdminLayout";
import { IoArrowBack } from "react-icons/io5";

export default function DrawingLessonCreate() {
  const nav = useNavigate();
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function onSubmit(values) {
    try {
      setSaving(true);
      setError("");

      const res = await createDrawingLesson(values);
      nav(`/learning_module`);
    } catch (e) {
      setError(e?.response?.data?.message || e.message || "Create failed");
    } finally {
      setSaving(false);
    }
  }

  return (
    <AdminLayout>
      <div className="w-full min-h-full bg-[#F3E8E8] px-10 py-16 relative">
        {/* Back Button */}
        <button
          onClick={() => nav(-1)}
          className="mb-10 w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg text-[#BD9A6B] hover:bg-slate-50 transition z-10"
        >
          <IoArrowBack size={20} />
        </button>

        {error && (
          <div className="mb-4 p-4 bg-red-100 text-red-700 rounded-xl border border-red-200">
            {error}
          </div>
        )}

        <LessonForm mode="create" saving={saving} onSubmit={onSubmit} />
      </div>
    </AdminLayout>
  );
}
