import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { getDrawingLessonById } from "../../../services/Gemified_Knowledge_Builder/drawingLessonService.js";

export default function DrawingLessonView() {
  const { id } = useParams();
  const [loading, setLoading] = useState(true);
  const [lesson, setLesson] = useState(null);
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

  if (loading) return <p>Loading...</p>;
  if (error) return <p style={{ color: "crimson" }}>{error}</p>;
  if (!lesson) return <p>Not found</p>;

  return (
    <div>
      <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
        <h3 style={{ marginRight: "auto" }}>{lesson.title}</h3>
        <Link to={`/drawing_lessons/${lesson._id}/edit`}>Edit</Link>
        <Link to="/drawing_lessons">Back</Link>
      </div>

      <p><b>ID:</b> {lesson._id}</p>
      <p><b>Difficulty:</b> {lesson.difficulty_level}</p>
      <p><b>Description:</b> {lesson.description}</p>

      <div style={{ marginTop: 12 }}>
        <b>Video</b>
        <div style={{ marginTop: 6 }}>
          <video
            src={lesson.video_url}
            controls
            style={{ width: "100%", maxWidth: 800, borderRadius: 10 }}
          />
        </div>
      </div>

      <div style={{ marginTop: 16 }}>
        <b>Tips</b>
        {lesson.tips?.length ? (
          <ul>
            {lesson.tips.map((t, idx) => (
              <li key={idx}>
                <b>{t.tip_number}.</b> {t.tip}
              </li>
            ))}
          </ul>
        ) : (
          <p>No tips.</p>
        )}
      </div>
    </div>
  );
}
