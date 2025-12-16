import { useEffect, useState } from "react";
import { useNavigate, useParams, Link } from "react-router-dom";
import { getDrawingLessonById, updateDrawingLesson } from "../../services/Gemified_Knowledge_Builder/drawingLessonService.js";
import LessonForm from "./DrawingLessonForm.jsx";

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
    <div>
      <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
        <Link to={`/drawing_lessons/${id}`}>Back</Link>
      </div>

      <LessonForm
        mode="edit"
        saving={saving}
        initialValue={lesson}
        onSubmit={onSubmit}
      />
    </div>
  );
}
