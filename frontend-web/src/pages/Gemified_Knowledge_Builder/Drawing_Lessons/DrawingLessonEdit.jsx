import { useEffect, useState } from "react";
import { useNavigate, useParams, Link } from "react-router-dom";
import { getDrawingLessonById, updateDrawingLesson } from "../../../services/Gemified_Knowledge_Builder/drawingLessonService.js";
import LessonForm from "./DrawingLessonForm.jsx";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";
import { IoArrowBack } from "react-icons/io5";

export default function DrawingLessonEdit() {
  const { id } = useParams();
  const nav = useNavigate();

  const [loading, setLoading] = useState(true);
  const [lesson, setLesson] = useState(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setError("");
        const res = await getDrawingLessonById(id);
        setLesson(res.data);
      } catch (e) {
        setError(e?.response?.data?.message || e.message || "Failed to load lesson");
      } finally {
        setLoading(false);
      }
    })();
  }, [id]);

  async function onSubmit(values) {
    try {
      setSaving(true);
      setError("");
      await updateDrawingLesson(id, values);
      nav(`/drawing_lessons/${id}`);
    } catch (e) {
      setError(e?.response?.data?.message || e.message || "Update failed");
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <p>Loading...</p>;
  if (error) return <p style={{ color: "crimson" }}>{error}</p>;
  if (!lesson) return <p>Not found</p>;

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
        <LessonForm
          mode="edit"
          saving={saving}
          initialValue={lesson}
          onSubmit={onSubmit}
        />
      </div>
    </AdminLayout>
  );
}
