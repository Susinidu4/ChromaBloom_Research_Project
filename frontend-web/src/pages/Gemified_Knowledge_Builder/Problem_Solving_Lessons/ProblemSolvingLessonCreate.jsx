import React, { useState } from "react";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

export default function ProblemSolvingLessonCreate() {
  const [form, setForm] = useState({
    title: "",
    description: "",
    difficulty_level: "Beginner",
    miniTutorialsName: "",
    miniTutorials: [{ tip_number: 1, tip_content: "" }],
  });

  const [submitting, setSubmitting] = useState(false);
  const [msg, setMsg] = useState({ type: "", text: "" });

  const setField = (key, value) => setForm((p) => ({ ...p, [key]: value }));

  const updateTip = (index, key, value) => {
    setForm((p) => {
      const next = [...p.miniTutorials];
      next[index] = { ...next[index], [key]: value };
      return { ...p, miniTutorials: next };
    });
  };

  const addTip = () => {
    setForm((p) => {
      const nextNumber = (p.miniTutorials?.length || 0) + 1;
      return {
        ...p,
        miniTutorials: [
          ...(p.miniTutorials || []),
          { tip_number: nextNumber, tip_content: "" },
        ],
      };
    });
  };

  const removeTip = (index) => {
    setForm((p) => {
      const next = [...p.miniTutorials];
      next.splice(index, 1);
      // re-number sequentially (1..n)
      const renumbered = next.map((t, i) => ({
        ...t,
        tip_number: i + 1,
      }));
      return { ...p, miniTutorials: renumbered };
    });
  };

  const validate = () => {
    if (!form.title.trim()) return "Title is required";
    if (!form.description.trim()) return "Description is required";
    if (!form.difficulty_level) return "Difficulty level is required";

    // miniTutorials optional, but if provided validate tip_content
    if (Array.isArray(form.miniTutorials) && form.miniTutorials.length > 0) {
      const bad = form.miniTutorials.find((t) => !t.tip_content?.trim());
      if (bad) return "Please fill all mini tutorial tip contents (or remove empty ones).";
    }
    return null;
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setMsg({ type: "", text: "" });

    const err = validate();
    if (err) {
      setMsg({ type: "error", text: err });
      return;
    }

    const payload = {
      title: form.title.trim(),
      description: form.description.trim(),
      difficulty_level: form.difficulty_level,
      miniTutorialsName: form.miniTutorialsName?.trim() || "",
      miniTutorials: (form.miniTutorials || []).map((t, i) => ({
        tip_number: i + 1,
        tip_content: t.tip_content.trim(),
      })),
    };

    try {
      setSubmitting(true);
      const res = await ProblemSolvingLessonService.create(payload);
      setMsg({ type: "success", text: `Created successfully: ${res?.data?._id || "LP-xxxx"}` });

      // reset form
      setForm({
        title: "",
        description: "",
        difficulty_level: "Beginner",
        miniTutorialsName: "",
        miniTutorials: [{ tip_number: 1, tip_content: "" }],
      });
    } catch (error) {
      const apiMsg =
        error?.response?.data?.message ||
        error?.message ||
        "Failed to create lesson";
      setMsg({ type: "error", text: apiMsg });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <h2 style={styles.h2}>Create Problem Solving Lesson</h2>

        {msg.text ? (
          <div
            style={{
              ...styles.alert,
              ...(msg.type === "success" ? styles.alertSuccess : styles.alertError),
            }}
          >
            {msg.text}
          </div>
        ) : null}

        <form onSubmit={onSubmit} style={styles.form}>
          <div style={styles.grid2}>
            <div style={styles.field}>
              <label style={styles.label}>Title *</label>
              <input
                style={styles.input}
                value={form.title}
                onChange={(e) => setField("title", e.target.value)}
                placeholder="e.g., Match the Shapes"
              />
            </div>

            <div style={styles.field}>
              <label style={styles.label}>Difficulty Level *</label>
              <select
                style={styles.input}
                value={form.difficulty_level}
                onChange={(e) => setField("difficulty_level", e.target.value)}
              >
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
              </select>
            </div>
          </div>

          <div style={styles.field}>
            <label style={styles.label}>Description *</label>
            <textarea
              style={styles.textarea}
              value={form.description}
              onChange={(e) => setField("description", e.target.value)}
              placeholder="Short lesson description..."
              rows={4}
            />
          </div>

          <div style={styles.field}>
            <label style={styles.label}>Mini Tutorials Name (optional)</label>
            <input
              style={styles.input}
              value={form.miniTutorialsName}
              onChange={(e) => setField("miniTutorialsName", e.target.value)}
              placeholder="e.g., Parent Guidance Tips"
            />
          </div>

          <div style={styles.section}>
            <div style={styles.sectionHeader}>
              <h3 style={styles.h3}>Mini Tutorial Tips</h3>
              <button type="button" style={styles.btn} onClick={addTip}>
                + Add Tip
              </button>
            </div>

            {(form.miniTutorials || []).map((tip, idx) => (
              <div key={idx} style={styles.tipRow}>
                <div style={styles.tipNumber}>#{idx + 1}</div>

                <input
                  style={styles.input}
                  value={tip.tip_content}
                  onChange={(e) => updateTip(idx, "tip_content", e.target.value)}
                  placeholder="Tip content..."
                />

                <button
                  type="button"
                  style={{ ...styles.btn, ...styles.btnDanger }}
                  onClick={() => removeTip(idx)}
                  disabled={(form.miniTutorials?.length || 0) === 1}
                  title={
                    (form.miniTutorials?.length || 0) === 1
                      ? "At least one tip row is kept. Clear it if not needed."
                      : "Remove tip"
                  }
                >
                  Remove
                </button>
              </div>
            ))}

            <p style={styles.helper}>
              If you don’t want mini tutorials, you can keep one row and leave it blank,
              but then remove validation above — currently it requires all tip contents filled.
            </p>
          </div>

          <div style={styles.actions}>
            <button type="submit" style={styles.btnPrimary} disabled={submitting}>
              {submitting ? "Creating..." : "Create Lesson"}
            </button>
            <button
              type="button"
              style={styles.btnOutline}
              onClick={() =>
                setForm({
                  title: "",
                  description: "",
                  difficulty_level: "Beginner",
                  miniTutorialsName: "",
                  miniTutorials: [{ tip_number: 1, tip_content: "" }],
                })
              }
              disabled={submitting}
            >
              Reset
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};



// --- simple inline styles (no extra libs) ---
const styles = {
  page: {
    minHeight: "100vh",
    padding: 24,
    background: "#F5ECEC",
    display: "flex",
    justifyContent: "center",
    alignItems: "flex-start",
  },
  card: {
    width: "100%",
    maxWidth: 860,
    background: "#fff",
    borderRadius: 18,
    padding: 20,
    boxShadow: "0 10px 30px rgba(0,0,0,0.08)",
    border: "1px solid rgba(0,0,0,0.06)",
  },
  h2: { margin: 0, marginBottom: 14, fontSize: 22 },
  h3: { margin: 0, fontSize: 16 },
  form: { display: "flex", flexDirection: "column", gap: 14 },
  grid2: { display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 },
  field: { display: "flex", flexDirection: "column", gap: 6 },
  label: { fontSize: 13, fontWeight: 600, opacity: 0.85 },
  input: {
    padding: "10px 12px",
    borderRadius: 12,
    border: "1px solid rgba(0,0,0,0.15)",
    outline: "none",
    fontSize: 14,
  },
  textarea: {
    padding: "10px 12px",
    borderRadius: 12,
    border: "1px solid rgba(0,0,0,0.15)",
    outline: "none",
    fontSize: 14,
    resize: "vertical",
  },
  section: {
    padding: 14,
    borderRadius: 14,
    background: "rgba(233,221,204,0.45)",
    border: "1px solid rgba(0,0,0,0.06)",
  },
  sectionHeader: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 10,
  },
  tipRow: {
    display: "grid",
    gridTemplateColumns: "60px 1fr 120px",
    gap: 10,
    alignItems: "center",
    marginBottom: 10,
  },
  tipNumber: {
    height: 40,
    borderRadius: 12,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "#F8F2E8",
    border: "1px solid rgba(0,0,0,0.12)",
    fontWeight: 700,
  },
  helper: { margin: 0, fontSize: 12, opacity: 0.75 },
  actions: { display: "flex", gap: 10, marginTop: 8 },
  btn: {
    padding: "10px 12px",
    borderRadius: 12,
    border: "1px solid rgba(0,0,0,0.18)",
    background: "#fff",
    cursor: "pointer",
    fontWeight: 700,
    fontSize: 13,
  },
  btnDanger: { background: "#fff5f5", borderColor: "rgba(255,0,0,0.25)" },
  btnPrimary: {
    padding: "10px 14px",
    borderRadius: 12,
    border: "none",
    background: "#3D6B86",
    color: "#fff",
    cursor: "pointer",
    fontWeight: 800,
  },
  btnOutline: {
    padding: "10px 14px",
    borderRadius: 12,
    border: "1px solid rgba(0,0,0,0.18)",
    background: "transparent",
    cursor: "pointer",
    fontWeight: 800,
  },
  alert: {
    padding: 12,
    borderRadius: 12,
    marginBottom: 12,
    fontSize: 14,
  },
  alertSuccess: {
    background: "rgba(0, 128, 0, 0.08)",
    border: "1px solid rgba(0, 128, 0, 0.18)",
  },
  alertError: {
    background: "rgba(255, 0, 0, 0.08)",
    border: "1px solid rgba(255, 0, 0, 0.18)",
  },
};
