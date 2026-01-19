import React, { useEffect, useMemo, useState } from "react";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

export default function QuizeCreate() {
  const [form, setForm] = useState({
    question: "",
    lesson_id: "",
    name_tag: "",
    difficulty_level: "Beginner",
    correct_answer: 1,
    answers: [
      { image_no: 1, img_url: "" },
      { image_no: 2, img_url: "" },
      { image_no: 3, img_url: "" },
      { image_no: 4, img_url: "" },
    ],
  });

  const [files, setFiles] = useState([null, null, null, null]);

  const [submitting, setSubmitting] = useState(false);
  const [msg, setMsg] = useState({ type: "", text: "" });

  // ✅ lessons for dropdown
  const [lessons, setLessons] = useState([]);
  const [lessonsLoading, setLessonsLoading] = useState(true);
  const [lessonsError, setLessonsError] = useState("");

  const setField = (key, value) => setForm((p) => ({ ...p, [key]: value }));

  const answerCount = useMemo(() => form.answers?.length || 0, [form.answers]);

  // ✅ Fetch lessons on mount
  useEffect(() => {
    const loadLessons = async () => {
      setLessonsLoading(true);
      setLessonsError("");
      try {
        const res = await ProblemSolvingLessonService.getAll();

        // your service returns: { success, data: [] } or { data: [] }
        const list = Array.isArray(res?.data) ? res.data : Array.isArray(res?.data?.data) ? res.data.data : res?.data;

        // safer normalize:
        const lessonsArr = Array.isArray(res?.data) ? res.data : res?.data?.data || res?.data || res?.data?.data || [];
        // but depending on your backend, we will do:
        const finalList = Array.isArray(res?.data?.data)
          ? res.data.data
          : Array.isArray(res?.data)
          ? res.data
          : Array.isArray(res?.data?.data)
          ? res.data.data
          : res?.data?.data || res?.data?.data || res?.data?.data || [];

        // ✅ best: try common shapes
        const normalized =
          Array.isArray(res?.data?.data) ? res.data.data :
          Array.isArray(res?.data) ? res.data :
          Array.isArray(res?.data?.data) ? res.data.data :
          Array.isArray(res?.data?.data?.data) ? res.data.data.data :
          Array.isArray(res?.data?.data) ? res.data.data :
          Array.isArray(res?.data?.data) ? res.data.data :
          Array.isArray(res?.data?.data) ? res.data.data :
          [];

        // Use whichever works (fallback)
        const usable = normalized.length ? normalized : (Array.isArray(res?.data?.data) ? res.data.data : (res?.data?.data || res?.data || []));

        // sort by id (LP-0001 ...)
        const sorted = [...usable].sort((a, b) => String(a._id).localeCompare(String(b._id)));

        setLessons(sorted);

        // auto-select first lesson if empty
        setForm((p) => {
          if (p.lesson_id) return p;
          const firstId = sorted?.[0]?._id || "";
          return { ...p, lesson_id: firstId };
        });
      } catch (e) {
        setLessonsError(
          e?.response?.data?.message || e?.message || "Failed to load lessons"
        );
      } finally {
        setLessonsLoading(false);
      }
    };

    loadLessons();
  }, []);

  const ensureCorrectAnswerInRange = (n) => {
    setForm((p) => {
      const current = Number(p.correct_answer || 1);
      const fixed = Math.min(Math.max(current, 1), n);
      return { ...p, correct_answer: fixed };
    });
  };

  const addAnswerSlot = () => {
    setForm((p) => {
      const nextNo = (p.answers?.length || 0) + 1;
      const nextAnswers = [...(p.answers || []), { image_no: nextNo, img_url: "" }];
      return { ...p, answers: nextAnswers };
    });
    setFiles((prev) => [...prev, null]);
    ensureCorrectAnswerInRange(answerCount + 1);
  };

  const removeAnswerSlot = (index) => {
    if ((form.answers?.length || 0) <= 2) {
      setMsg({ type: "error", text: "Keep at least 2 answers." });
      return;
    }

    setForm((p) => {
      const next = [...(p.answers || [])];
      next.splice(index, 1);
      const renumbered = next.map((a, i) => ({ ...a, image_no: i + 1 }));
      return { ...p, answers: renumbered };
    });

    setFiles((p) => {
      const next = [...p];
      next.splice(index, 1);
      return next;
    });

    setTimeout(() => ensureCorrectAnswerInRange(answerCount - 1), 0);
  };

  const onPickFile = (index, file) => {
    setFiles((p) => {
      const next = [...p];
      next[index] = file || null;
      return next;
    });
  };

  const validate = () => {
    if (!form.question.trim()) return "Question is required";

    // ✅ dropdown value required
    if (!form.lesson_id?.trim()) return "Lesson ID is required (select a lesson)";

    if (!form.difficulty_level) return "Difficulty level is required";

    const n = form.answers?.length || 0;
    if (n < 2) return "At least 2 answers are required";

    const ca = Number(form.correct_answer);
    if (!Number.isFinite(ca) || ca < 1 || ca > n) {
      return `Correct answer must be between 1 and ${n}`;
    }

    const missing = files.findIndex((f) => !f);
    if (missing !== -1) return `Please upload an image for Answer #${missing + 1}`;

    return null;
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setMsg({ type: "", text: "" });

    const err = validate();
    if (err) return setMsg({ type: "error", text: err });

    const answersPayload = (form.answers || []).map((a, i) => ({
      image_no: i + 1,
      img_url: a.img_url || "",
    }));

    const payload = {
      question: form.question.trim(),
      lesson_id: form.lesson_id.trim(), // ✅ selected from dropdown
      name_tag: form.name_tag.trim(),
      difficulty_level: form.difficulty_level,
      correct_answer: Number(form.correct_answer),
      answers: answersPayload,
      images: files.filter(Boolean),
    };

    try {
      setSubmitting(true);
      const res = await QuizeService.create(payload, { useMultipart: true });

      setMsg({
        type: "success",
        text: `Quiz created: ${res?.data?._id || "QZ-xxxx"}`,
      });

      setForm((p) => ({
        ...p,
        question: "",
        name_tag: "",
        difficulty_level: "Beginner",
        correct_answer: 1,
        answers: [
          { image_no: 1, img_url: "" },
          { image_no: 2, img_url: "" },
          { image_no: 3, img_url: "" },
          { image_no: 4, img_url: "" },
        ],
        // keep selected lesson_id
      }));
      setFiles([null, null, null, null]);
    } catch (error) {
      const apiMsg =
        error?.response?.data?.message || error?.message || "Failed to create quiz";
      setMsg({ type: "error", text: apiMsg });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <h2 style={styles.h2}>Create Quiz</h2>

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
          <div style={styles.field}>
            <label style={styles.label}>Question *</label>
            <input
              style={styles.input}
              value={form.question}
              onChange={(e) => setField("question", e.target.value)}
              placeholder="e.g., Which image shows a triangle?"
            />
          </div>

          <div style={styles.grid2}>
            {/* ✅ Lesson dropdown */}
            <div style={styles.field}>
              <label style={styles.label}>Lesson *</label>

              {lessonsLoading ? (
                <div style={styles.loadingInline}>Loading lessons...</div>
              ) : lessonsError ? (
                <div style={styles.errorInline}>{lessonsError}</div>
              ) : (
                <select
                  style={styles.input}
                  value={form.lesson_id}
                  onChange={(e) => setField("lesson_id", e.target.value)}
                >
                  <option value="" disabled>
                    -- Select a lesson --
                  </option>

                  {lessons.map((l) => (
                    <option key={l._id} value={l._id}>
                      {l._id} — {l.title || "(No title)"}
                    </option>
                  ))}
                </select>
              )}
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

          <div style={styles.grid2}>
            <div style={styles.field}>
              <label style={styles.label}>Name Tag (optional)</label>
              <input
                style={styles.input}
                value={form.name_tag}
                onChange={(e) => setField("name_tag", e.target.value)}
                placeholder="e.g., Shapes"
              />
            </div>

            <div style={styles.field}>
              <label style={styles.label}>Correct Answer *</label>
              <select
                style={styles.input}
                value={String(form.correct_answer)}
                onChange={(e) => setField("correct_answer", Number(e.target.value))}
              >
                {(form.answers || []).map((_, i) => (
                  <option key={i} value={i + 1}>
                    Answer #{i + 1}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div style={styles.section}>
            <div style={styles.sectionHeader}>
              <h3 style={styles.h3}>Answers (Images)</h3>
              <button type="button" style={styles.btn} onClick={addAnswerSlot}>
                + Add Answer
              </button>
            </div>

            {(form.answers || []).map((a, idx) => (
              <div key={idx} style={styles.answerRow}>
                <div style={styles.answerNo}>#{idx + 1}</div>

                <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => onPickFile(idx, e.target.files?.[0] || null)}
                    style={styles.file}
                  />

                  {files[idx] ? (
                    <div style={styles.fileHint}>
                      Selected: <b>{files[idx].name}</b>
                    </div>
                  ) : (
                    <div style={styles.fileHint}>No image selected</div>
                  )}
                </div>

                <button
                  type="button"
                  style={{ ...styles.btn, ...styles.btnDanger }}
                  onClick={() => removeAnswerSlot(idx)}
                  disabled={(form.answers?.length || 0) <= 2}
                >
                  Remove
                </button>
              </div>
            ))}

            <p style={styles.helper}>
              Images are uploaded using field name <b>images</b> and mapped in order to answers.
            </p>
          </div>

          <div style={styles.actions}>
            <button type="submit" style={styles.btnPrimary} disabled={submitting}>
              {submitting ? "Creating..." : "Create Quiz"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

/** styles: keep your existing styles and add these 2 helpers */
const styles = {
  // (keep all your existing styles here)
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

  // ✅ inline status styles
  loadingInline: {
    padding: "10px 12px",
    borderRadius: 12,
    border: "1px dashed rgba(0,0,0,0.18)",
    fontSize: 13,
    opacity: 0.75,
  },
  errorInline: {
    padding: "10px 12px",
    borderRadius: 12,
    border: "1px solid rgba(255,0,0,0.2)",
    background: "rgba(255,0,0,0.06)",
    fontSize: 13,
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
  answerRow: {
    display: "grid",
    gridTemplateColumns: "60px 1fr 120px",
    gap: 10,
    alignItems: "center",
    marginBottom: 10,
  },
  answerNo: {
    height: 40,
    borderRadius: 12,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "#F8F2E8",
    border: "1px solid rgba(0,0,0,0.12)",
    fontWeight: 700,
  },
  file: {
    padding: 10,
    borderRadius: 12,
    border: "1px solid rgba(0,0,0,0.15)",
    background: "#fff",
  },
  fileHint: { fontSize: 12, opacity: 0.8 },
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
