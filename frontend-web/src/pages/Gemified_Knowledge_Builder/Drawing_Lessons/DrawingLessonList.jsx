import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { deleteDrawingLesson, getAllDrawingLessons } from "../../../services/Gemified_Knowledge_Builder/drawingLessonService.js";

export default function DrawingLessonList() {
  const [loading, setLoading] = useState(true);
  const [lessons, setLessons] = useState([]);
  const [error, setError] = useState("");

  async function load() {
    try {
      setLoading(true);
      setError("");
      const res = await getAllDrawingLessons();
      setLessons(res.data || []);
    } catch (e) {
      setError(e?.response?.data?.message || e.message || "Failed to load lessons");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function onDelete(id) {
    const ok = confirm("Delete this lesson?");
    if (!ok) return;

    try {
      await deleteDrawingLesson(id);
      await load();
    } catch (e) {
      alert(e?.response?.data?.message || e.message || "Delete failed");
    }
  }

  if (loading) return <p>Loading...</p>;
  if (error) return <p style={{ color: "crimson" }}>{error}</p>;

  return (
    <div>
      <h3>All Drawing Lessons</h3>

      {lessons.length === 0 ? (
        <p>No lessons found.</p>
      ) : (
        <div style={{ display: "grid", gap: 12 }}>
          {lessons.map((l) => (
            <div
              key={l._id}
              style={{
                border: "1px solid #ddd",
                borderRadius: 10,
                padding: 12,
              }}
            >
              <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                <div style={{ marginRight: "auto" }}>
                  <div style={{ fontWeight: 700 }}>{l.title}</div>
                  <div style={{ opacity: 0.8, fontSize: 14 }}>
                    ID: {l._id} • Level: {l.difficulty_level}
                  </div>
                </div>

                <Link to={`/drawing_lessons/${l._id}`}>View</Link>
                <Link to={`/drawing_lessons/${l._id}/edit`}>Edit</Link>
                <button onClick={() => onDelete(l._id)}>Delete</button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
