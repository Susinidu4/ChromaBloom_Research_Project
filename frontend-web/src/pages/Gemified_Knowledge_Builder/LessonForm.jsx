import { useEffect, useMemo, useState } from "react";

const LEVELS = ["Beginner", "Intermediate", "Advanced"];

function safeJsonTips(tips) {
  if (!Array.isArray(tips)) return [];
  return tips
    .filter(Boolean)
    .map((t, i) => ({
      tip_number: Number(t.tip_number ?? i + 1),
      tip: String(t.tip ?? ""),
    }));
}

export default function LessonForm({ mode, initialValue, saving, onSubmit }) {
  const initial = useMemo(() => {
    return {
      title: initialValue?.title || "",
      description: initialValue?.description || "",
      difficulty_level: initialValue?.difficulty_level || "Beginner",
      tips: safeJsonTips(initialValue?.tips),
      videoFile: null, // File
    };
  }, [initialValue]);

  const [title, setTitle] = useState(initial.title);
  const [description, setDescription] = useState(initial.description);
  const [difficulty, setDifficulty] = useState(initial.difficulty_level);
  const [tips, setTips] = useState(initial.tips);
  const [videoFile, setVideoFile] = useState(null);
  const [formError, setFormError] = useState("");

  useEffect(() => {
    setTitle(initial.title);
    setDescription(initial.description);
    setDifficulty(initial.difficulty_level);
    setTips(initial.tips);
    setVideoFile(null);
  }, [initial]);

  function addTip() {
    setTips((prev) => [
      ...prev,
      { tip_number: prev.length + 1, tip: "" },
    ]);
  }

  function removeTip(index) {
    setTips((prev) =>
      prev
        .filter((_, i) => i !== index)
        .map((t, i) => ({ ...t, tip_number: i + 1 }))
    );
  }

  function updateTip(index, value) {
    setTips((prev) =>
      prev.map((t, i) => (i === index ? { ...t, tip: value } : t))
    );
  }

  function validate() {
    if (!title.trim()) return "Title is required";
    if (!description.trim()) return "Description is required";
    if (!LEVELS.includes(difficulty)) return "Invalid difficulty level";

    if (mode === "create" && !videoFile) return "Video file is required";
    return "";
  }

  async function handleSubmit(e) {
    e.preventDefault();
    const v = validate();
    if (v) {
      setFormError(v);
      return;
    }
    setFormError("");

    const payload = {
      title: title.trim(),
      description: description.trim(),
      difficulty_level: difficulty,
      tips: tips.filter((t) => (t.tip || "").trim().length > 0),
      videoFile: videoFile || undefined, // undefined => not sent in update
    };

    await onSubmit(payload);
  }

  return (
    <form onSubmit={handleSubmit} style={{ display: "grid", gap: 12, maxWidth: 800 }}>
      {formError && <p style={{ color: "crimson" }}>{formError}</p>}

      <label style={{ display: "grid", gap: 6 }}>
        <span>Title</span>
        <input value={title} onChange={(e) => setTitle(e.target.value)} />
      </label>

      <label style={{ display: "grid", gap: 6 }}>
        <span>Description</span>
        <textarea
          rows={4}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </label>

      <label style={{ display: "grid", gap: 6 }}>
        <span>Difficulty Level</span>
        <select value={difficulty} onChange={(e) => setDifficulty(e.target.value)}>
          {LEVELS.map((l) => (
            <option key={l} value={l}>
              {l}
            </option>
          ))}
        </select>
      </label>

      <div style={{ border: "1px solid #ddd", borderRadius: 10, padding: 12 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <b style={{ marginRight: "auto" }}>Tips</b>
          <button type="button" onClick={addTip}>
            + Add Tip
          </button>
        </div>

        {tips.length === 0 ? (
          <p style={{ opacity: 0.8 }}>No tips added.</p>
        ) : (
          <div style={{ display: "grid", gap: 10, marginTop: 10 }}>
            {tips.map((t, idx) => (
              <div key={idx} style={{ display: "grid", gap: 6 }}>
                <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                  <span style={{ fontWeight: 700 }}>Tip {t.tip_number}</span>
                  <button type="button" onClick={() => removeTip(idx)}>
                    Remove
                  </button>
                </div>
                <input
                  value={t.tip}
                  placeholder="Type tip text..."
                  onChange={(e) => updateTip(idx, e.target.value)}
                />
              </div>
            ))}
          </div>
        )}
      </div>

      <label style={{ display: "grid", gap: 6 }}>
        <span>{mode === "create" ? "Video (required)" : "Replace Video (optional)"}</span>
        <input
          type="file"
          accept="video/*"
          onChange={(e) => setVideoFile(e.target.files?.[0] || null)}
        />
        {mode === "edit" && initialValue?.video_url && (
          <small style={{ opacity: 0.8 }}>
            Current video exists. Uploading a file will replace it.
          </small>
        )}
      </label>

      <button type="submit" disabled={saving}>
        {saving ? "Saving..." : mode === "create" ? "Create Lesson" : "Update Lesson"}
      </button>
    </form>
  );
}
