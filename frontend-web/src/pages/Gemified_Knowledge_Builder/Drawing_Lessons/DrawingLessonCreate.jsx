import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { createDrawingLesson } from "../../../services/Gemified_Knowledge_Builder/drawingLessonService";
import LessonForm from "./DrawingLessonForm";

export default function DrawingLessonCreate() {
  const nav = useNavigate();
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function onSubmit(values) {
    try {
      setSaving(true);
      setError("");
      const res = await createDrawingLesson(values);
      nav(`/drawing_lessons/${res.data._id}`);
    } catch (e) {
      setError(e?.response?.data?.message || e.message || "Create failed");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div>
      {error && <p style={{ color: "crimson" }}>{error}</p>}

      <LessonForm
        mode="create"
        saving={saving}
        onSubmit={onSubmit}
      />
    </div>
  );
}
