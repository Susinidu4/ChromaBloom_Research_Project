import React from "react";
import { useNavigate } from "react-router-dom";

export const Admin_Dashboard = () => {
  const navigate = useNavigate();

  return (
    <div style={styles.container}>
      <h1 style={styles.title}>Admin Dashboard</h1>

      <div style={styles.grid}>
        {/* Create Drawing Lesson */}
        <div
          style={styles.card}
          onClick={() => navigate("/drawing_lessons_create")}
        >
          <h3>Create Drawing Lesson</h3>
          <p>Add new drawing lessons with video & tips</p>
        </div>

        {/* View Drawing Lessons */}
        <div
          style={styles.card}
          onClick={() => navigate("/drawing_lessons")}
        >
          <h3>Manage Drawing Lessons</h3>
          <p>View, edit, or delete existing lessons</p>
        </div>

        {/* create problem solving lesson */}
        <div
          style={styles.card}
          onClick={() => navigate("/problem_solving_lessons_create")}
        >
          <h3>Create Problem Solving Lesson</h3>
          <p>Add new problem solving lessons with video & tips</p>
        </div>

        {/* View Problem Solving Lessons */}
        <div
          style={styles.card}
          onClick={() => navigate("/problem_solving_lessons")}
        >
          <h3>Manage Problem Solving Lessons</h3>
          <p>View, edit, or delete existing lessons</p>
        </div>
      </div>
    </div>
  );
};

/* ================= STYLES ================= */

const styles = {
  container: {
    padding: "30px",
    maxWidth: "1100px",
    margin: "0 auto",
  },
  title: {
    marginBottom: "25px",
    fontSize: "28px",
  },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
    gap: "20px",
  },
  card: {
    border: "1px solid #ddd",
    borderRadius: "12px",
    padding: "20px",
    cursor: "pointer",
    transition: "0.2s",
    backgroundColor: "#fff",
  },
};
