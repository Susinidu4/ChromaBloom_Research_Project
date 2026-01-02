import React, { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { problemSolvingLessonService } from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

export default function ProblemSolvingLessonView() {
  const { id } = useParams();
  const [lesson, setLesson] = useState(null);
  const [loading, setLoading] = useState(false);

  const load = async () => {
    try {
      setLoading(true);
      const res = await problemSolvingLessonService.getById(id);
      setLesson(res.data);
    } catch (e) {
      alert(e?.response?.data?.message || e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [id]);

  if (loading) return <div style={{ padding: 16 }}>Loading...</div>;
  if (!lesson) return <div style={{ padding: 16 }}>No data</div>;

  return (
    <div style={{ maxWidth: 1000, margin: "0 auto", padding: 16 }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 12, alignItems: "center" }}>
        <h2 style={{ margin: 0 }}>{lesson.title}</h2>
        <Link to={`/problem_solving_lessons/${lesson._id}/edit`}>Edit</Link>
      </div>

      <p style={{ opacity: 0.8 }}>
        <b>ID:</b> {lesson._id} | <b>Difficulty:</b> {lesson.difficultyLevel}{" "}
        {lesson.catergory ? `| Category: ${lesson.catergory}` : ""}
      </p>

      <div style={card}>
        <h3 style={{ marginTop: 0 }}>Content</h3>
        <p style={{ whiteSpace: "pre-wrap" }}>{lesson.content || "-"}</p>

        <h3 style={{ marginTop: 12 }}>Category</h3>
        <p>{lesson.catergory || "-"}</p>

        <h3>Correct Answer</h3>
        <p>{lesson.correct_answer}</p>

        <h3>Tips</h3>
        {lesson.tips?.length ? (
          <ul>
            {lesson.tips.map((t) => (
              <li key={t.tip_number}>{t.tip_content}</li>
            ))}
          </ul>
        ) : (
          <p>-</p>
        )}

        <h3>Images</h3>
        {lesson.images?.length ? (
          <div style={imgGrid}>
            {lesson.images.map((img, i) => (
              <img key={i} src={img.image_url} alt={`img-${i}`} style={thumb} />
            ))}
          </div>
        ) : (
          <p>-</p>
        )}
      </div>

      <div style={{ marginTop: 12 }}>
        <Link to="/problem_solving_lessons">Back to list</Link>
      </div>
    </div>
  );
}

const card = { padding: 16, border: "1px solid #333", borderRadius: 12, marginTop: 12 };
const imgGrid = { display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 8 };
const thumb = { width: "100%", height: 90, objectFit: "cover", borderRadius: 10, border: "1px solid #444" };
