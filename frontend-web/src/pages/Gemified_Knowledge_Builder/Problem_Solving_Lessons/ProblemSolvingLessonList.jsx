import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { problemSolvingLessonService } from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

export default function ProblemSolvingLessonList() {
  const [lessons, setLessons] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchAll = async () => {
    try {
      setLoading(true);
      const res = await problemSolvingLessonService.getAll();
      setLessons(res.data || []);
    } catch (e) {
      alert(e?.response?.data?.message || e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAll();
  }, []);

  const onDelete = async (id) => {
    if (!confirm(`Delete ${id}?`)) return;
    try {
      await problemSolvingLessonService.remove(id);
      fetchAll();
    } catch (e) {
      alert(e?.response?.data?.message || e.message);
    }
  };

  return (
    <div style={{ maxWidth: 1000, margin: "0 auto", padding: 16 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
        <h2 style={{ margin: 0 }}>Problem-Solving Lessons</h2>
        <Link to="/problem_solving_lessons_create">+ Create</Link>
      </div>

      {loading ? (
        <div style={{ marginTop: 12 }}>Loading...</div>
      ) : lessons.length === 0 ? (
        <div style={{ marginTop: 12, opacity: 0.8 }}>No lessons found</div>
      ) : (
        <div style={{ display: "grid", gap: 10, marginTop: 12 }}>
          {lessons.map((l) => (
            <div key={l._id} style={row}>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 800 }}>{l.title}</div>
                <div style={{ opacity: 0.8, fontSize: 13 }}>
                  {l._id} • {l.difficultyLevel} • tips: {l.tips?.length || 0} • images: {l.images?.length || 0}
                </div>
              </div>
              <div style={{ display: "flex", gap: 10 }}>
                <Link to={`/problem_solving_lessons/${l._id}`}>View</Link>
                <Link to={`/problem_solving_lessons/${l._id}/edit`}>Edit</Link>
                <button onClick={() => onDelete(l._id)} style={dangerBtn}>
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

const row = { padding: 12, border: "1px solid #333", borderRadius: 12, display: "flex", gap: 12, alignItems: "center" };
const dangerBtn = { border: "1px solid #444", borderRadius: 10, padding: "6px 10px", cursor: "pointer" };
