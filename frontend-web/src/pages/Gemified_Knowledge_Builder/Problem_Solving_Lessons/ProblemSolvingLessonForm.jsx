import React, { useEffect, useMemo, useState } from "react";

const DIFFICULTY = ["Easy", "Medium", "Hard"];
const CATEGORIES = [
  "match the similar objects",
  "spot the difference",
  "sorting by category",
  "what happen next",
  "find the missing piece",
];

const emptyTip = (n) => ({ tip_number: n, tip_content: "" });

export default function ProblemSolvingLessonForm({
  mode = "create", // "create" | "edit"
  values,
  setValues,
  onSubmit,
  submitting,
  existingImages = [],
}) {
  // ✅ FIX: prevent crash when values is temporarily undefined (HMR / route render)
  if (!values) return <div style={{ padding: 16 }}>Loading form...</div>;

  const isEdit = useMemo(() => mode === "edit", [mode]);
  const MAX_IMAGES = 4;

  // =========================
  // Tips handlers
  // =========================
  const addTip = () => {
    setValues((p) => ({
      ...p,
      tips: [...(p.tips || [emptyTip(1)]), emptyTip((p.tips?.length || 1) + 1)],
    }));
  };

  const removeTip = (index) => {
    setValues((p) => {
      const copy = [...(p.tips || [])];
      copy.splice(index, 1);
      const renum = copy.map((t, i) => ({ ...t, tip_number: i + 1 }));
      return { ...p, tips: renum.length ? renum : [emptyTip(1)] };
    });
  };

  const updateTip = (index, value) => {
    setValues((p) => {
      const copy = [...(p.tips || [])];
      copy[index] = { ...copy[index], tip_content: value };
      return { ...p, tips: copy };
    });
  };

  // =========================
  // Images handlers + previews
  // =========================
  const onPickImages = (e) => {
    const picked = Array.from(e.target.files || []);
    if (!picked.length) return;

    setValues((prev) => {
      const current = prev.images || [];
      const merged = [...current, ...picked];

      if (merged.length > MAX_IMAGES) {
        alert(`Maximum ${MAX_IMAGES} images allowed.`);
        return prev;
      }
      return { ...prev, images: merged };
    });

    // allow re-select same file later
    e.target.value = "";
  };

  const removeSelectedImage = (index) => {
    setValues((prev) => {
      const copy = [...(prev.images || [])];
      copy.splice(index, 1);
      return { ...prev, images: copy };
    });
  };

  // ✅ Create object URLs safely and revoke on cleanup
  const [previewUrls, setPreviewUrls] = useState([]);
  useEffect(() => {
    const files = values.images || [];
    const urls = files.map((f) => URL.createObjectURL(f));
    setPreviewUrls(urls);

    return () => {
      urls.forEach((u) => URL.revokeObjectURL(u));
    };
  }, [values.images]);

  return (
    <form onSubmit={onSubmit} style={styles.card}>
      <div style={styles.headerRow}>
        <h2 style={{ margin: 0 }}>
          {isEdit ? "Edit Problem-Solving Lesson" : "Create Problem-Solving Lesson"}
        </h2>

        <button type="submit" disabled={submitting} style={styles.primary}>
          {submitting ? "Saving..." : isEdit ? "Update" : "Create"}
        </button>
      </div>

      {/* =======================
          Main inputs
      ======================= */}
      <div style={styles.grid2}>
        <div>
          <label style={styles.label}>Title *</label>
          <input
            style={styles.input}
            value={values.title || ""}
            onChange={(e) => setValues((p) => ({ ...p, title: e.target.value }))}
            required
          />
        </div>

        <div>
          <label style={styles.label}>Difficulty *</label>
          <select
            style={styles.input}
            value={values.difficultyLevel || "Easy"}
            onChange={(e) =>
              setValues((p) => ({ ...p, difficultyLevel: e.target.value }))
            }
            required
          >
            {DIFFICULTY.map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label style={styles.label}>Category (optional)</label>
          <select
            style={styles.input}
            value={values.catergory || ""}
            onChange={(e) => setValues((p) => ({ ...p, catergory: e.target.value }))}
          >
            <option value="">-- Select --</option>
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
          <small style={{ opacity: 0.7 }}>
            Backend field name: <b>catergory</b>
          </small>
        </div>

        <div>
          <label style={styles.label}>Correct Answer *</label>
          <input
            style={styles.input}
            value={values.correct_answer || ""}
            onChange={(e) =>
              setValues((p) => ({ ...p, correct_answer: e.target.value }))
            }
            required
          />
        </div>
      </div>

      <div style={{ marginTop: 12 }}>
        <label style={styles.label}>Content</label>
        <textarea
          rows={4}
          style={styles.textarea}
          value={values.content || ""}
          onChange={(e) => setValues((p) => ({ ...p, content: e.target.value }))}
        />
      </div>

      {/* =======================
          Tips section
      ======================= */}
      <div style={{ marginTop: 14 }}>
        <div style={styles.rowBetween}>
          <label style={styles.label}>Tips</label>
          <button type="button" onClick={addTip} style={styles.small}>
            + Add Tip
          </button>
        </div>

        <div style={{ display: "grid", gap: 10 }}>
          {(values.tips || [emptyTip(1)]).map((t, idx) => (
            <div key={idx} style={styles.tipRow}>
              <div style={{ width: 70, opacity: 0.8 }}>Tip {idx + 1}</div>

              <input
                style={{ ...styles.input, flex: 1 }}
                value={t?.tip_content || ""}
                onChange={(e) => updateTip(idx, e.target.value)}
                placeholder="Tip content..."
              />

              <button
                type="button"
                onClick={() => removeTip(idx)}
                style={styles.danger}
                disabled={(values.tips || []).length <= 1}
              >
                Remove
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* =======================
          Images section
      ======================= */}
      <div style={{ marginTop: 14 }}>
        <label style={styles.label}>Images (optional, max {MAX_IMAGES})</label>

        <div style={{ display: "flex", gap: 12, alignItems: "center", flexWrap: "wrap" }}>
          <input
            type="file"
            accept="image/*"
            multiple
            onChange={onPickImages}
            disabled={(values.images?.length || 0) >= MAX_IMAGES}
          />

          <div style={{ opacity: 0.8 }}>
            Selected: <b>{values.images?.length || 0}</b> / {MAX_IMAGES}
          </div>
        </div>

        {/* Selected previews */}
        {(values.images?.length || 0) > 0 && (
          <div style={{ marginTop: 10 }}>
            <div style={{ opacity: 0.8, marginBottom: 6 }}>
              Selected Images Preview:
            </div>

            <div style={styles.imageGrid}>
              {(values.images || []).map((file, idx) => (
                <div key={idx} style={styles.previewWrap}>
                  <img
                    src={previewUrls[idx]}
                    alt={`selected-${idx}`}
                    style={styles.thumb}
                  />

                  <button
                    type="button"
                    onClick={() => removeSelectedImage(idx)}
                    style={styles.removeBtn}
                  >
                    Remove
                  </button>

                  <div style={styles.fileName} title={file?.name}>
                    {file?.name}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Existing images (edit mode) only if no new selected */}
        {isEdit &&
          existingImages.length > 0 &&
          (!values.images || values.images.length === 0) && (
            <div style={{ marginTop: 10 }}>
              <div style={{ opacity: 0.8, marginBottom: 6 }}>Existing Images:</div>

              <div style={styles.imageGrid}>
                {existingImages.slice(0, MAX_IMAGES).map((url, i) => (
                  <div key={i} style={styles.previewWrap}>
                    <img src={url} alt={`existing-${i}`} style={styles.thumb} />
                  </div>
                ))}
              </div>
            </div>
          )}
      </div>
    </form>
  );
}

const styles = {
  card: { padding: 16, border: "1px solid #333", borderRadius: 12, marginTop: 12 },
  headerRow: { display: "flex", justifyContent: "space-between", gap: 12, alignItems: "center" },
  grid2: { display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginTop: 12 },
  label: { display: "block", fontWeight: 700, marginBottom: 6 },
  input: { width: "100%", padding: 10, borderRadius: 10, border: "1px solid #444" },
  textarea: { width: "100%", padding: 10, borderRadius: 10, border: "1px solid #444" },
  rowBetween: { display: "flex", justifyContent: "space-between", alignItems: "center", gap: 10 },
  tipRow: { display: "flex", gap: 10, alignItems: "center" },
  primary: { padding: "10px 14px", borderRadius: 10, border: "1px solid #444", cursor: "pointer" },
  small: { padding: "8px 12px", borderRadius: 10, border: "1px solid #444", cursor: "pointer" },
  danger: { padding: "8px 12px", borderRadius: 10, border: "1px solid #444", cursor: "pointer" },

  imageGrid: { display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 10 },
  previewWrap: { border: "1px solid #444", borderRadius: 12, padding: 8 },
  thumb: { width: "100%", height: 120, objectFit: "cover", borderRadius: 10, border: "1px solid #555" },
  removeBtn: { width: "100%", marginTop: 8, padding: "8px 10px", borderRadius: 10, border: "1px solid #444", cursor: "pointer" },
  fileName: { marginTop: 6, fontSize: 12, opacity: 0.8, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" },
};
