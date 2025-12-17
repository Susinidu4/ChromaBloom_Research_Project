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
      videoFile: null,
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
    setTips((prev) => [...prev, { tip_number: prev.length + 1, tip: "" }]);
  }

  function removeTip(index) {
    setTips((prev) =>
      prev
        .filter((_, i) => i !== index)
        .map((t, i) => ({ ...t, tip_number: i + 1 }))
    );
  }

  function updateTip(index, value) {
    setTips((prev) => prev.map((t, i) => (i === index ? { ...t, tip: value } : t)));
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
      videoFile: videoFile || undefined,
    };

    await onSubmit(payload);
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-white to-slate-100 p-4 sm:p-8">
      <div className="mx-auto max-w-4xl">
        {/* Header */}
        <div className="mb-6">
          <h1 className="text-2xl sm:text-3xl font-bold text-slate-900">
            {mode === "create" ? "Create Drawing Lesson" : "Update Drawing Lesson"}
          </h1>
          <p className="mt-1 text-slate-600">
            Fill in the lesson details, tips, and upload a video.
          </p>
        </div>

        {/* Card */}
        <div className="rounded-2xl border border-slate-200 bg-white shadow-sm">
          <form onSubmit={handleSubmit} className="p-5 sm:p-8 space-y-6">
            {/* Error */}
            {formError && (
              <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-red-700">
                <div className="font-semibold">Fix this:</div>
                <div className="text-sm mt-1">{formError}</div>
              </div>
            )}

            {/* Title */}
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Title</label>
              <input
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g., Draw an Apple"
                className="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-900 outline-none focus:ring-2 focus:ring-slate-200 focus:border-slate-400"
              />
            </div>

            {/* Description */}
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">Description</label>
              <textarea
                rows={5}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Describe what the learner will practice in this lesson..."
                className="w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-900 outline-none focus:ring-2 focus:ring-slate-200 focus:border-slate-400"
              />
              <div className="text-xs text-slate-500">
                Tip: Keep it simple and child-friendly.
              </div>
            </div>

            {/* Difficulty */}
            <div className="grid gap-2">
              <label className="text-sm font-semibold text-slate-700">
                Difficulty Level
              </label>

              <div className="flex flex-wrap gap-2">
                {LEVELS.map((l) => {
                  const active = difficulty === l;
                  return (
                    <button
                      key={l}
                      type="button"
                      onClick={() => setDifficulty(l)}
                      className={[
                        "px-4 py-2 rounded-full border text-sm font-semibold transition",
                        active
                          ? "bg-slate-900 text-white border-slate-900"
                          : "bg-white text-slate-700 border-slate-300 hover:bg-slate-50",
                      ].join(" ")}
                    >
                      {l}
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Tips */}
            <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4 sm:p-5">
              <div className="flex items-center gap-3">
                <div>
                  <div className="text-base font-bold text-slate-900">Tips</div>
                  <div className="text-sm text-slate-600">
                    Add small guidance lines for the lesson.
                  </div>
                </div>

                <div className="ml-auto">
                  <button
                    type="button"
                    onClick={addTip}
                    className="rounded-xl bg-slate-900 px-4 py-2 text-white text-sm font-semibold hover:bg-slate-800"
                  >
                    + Add Tip
                  </button>
                </div>
              </div>

              {tips.length === 0 ? (
                <div className="mt-4 text-sm text-slate-600">
                  No tips added yet.
                </div>
              ) : (
                <div className="mt-4 grid gap-3">
                  {tips.map((t, idx) => (
                    <div
                      key={idx}
                      className="rounded-2xl border border-slate-200 bg-white p-4"
                    >
                      <div className="flex items-center gap-2">
                        <span className="inline-flex items-center rounded-full bg-slate-100 px-3 py-1 text-sm font-bold text-slate-700">
                          Tip {t.tip_number}
                        </span>

                        <button
                          type="button"
                          onClick={() => removeTip(idx)}
                          className="ml-auto text-sm font-semibold text-red-600 hover:text-red-700"
                        >
                          Remove
                        </button>
                      </div>

                      <input
                        value={t.tip}
                        placeholder="Type tip text..."
                        onChange={(e) => updateTip(idx, e.target.value)}
                        className="mt-3 w-full rounded-xl border border-slate-300 px-4 py-3 text-slate-900 outline-none focus:ring-2 focus:ring-slate-200 focus:border-slate-400"
                      />
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Video Upload */}
            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700">
                {mode === "create" ? "Video (required)" : "Replace Video (optional)"}
              </label>

              <div className="rounded-2xl border border-dashed border-slate-300 bg-white p-4">
                <input
                  type="file"
                  accept="video/*"
                  onChange={(e) => setVideoFile(e.target.files?.[0] || null)}
                  className="block w-full text-sm text-slate-700 file:mr-4 file:rounded-xl file:border-0 file:bg-slate-900 file:px-4 file:py-2 file:text-white file:font-semibold hover:file:bg-slate-800"
                />

                <div className="mt-2 text-xs text-slate-500">
                  Max size depends on your backend limits. Use MP4 for best compatibility.
                </div>

                {mode === "edit" && initialValue?.video_url && (
                  <div className="mt-2 text-xs text-slate-600">
                    Current video exists. Uploading a file will replace it.
                  </div>
                )}

                {videoFile && (
                  <div className="mt-3 rounded-xl bg-slate-50 border border-slate-200 px-3 py-2 text-sm text-slate-700">
                    Selected: <span className="font-semibold">{videoFile.name}</span>
                  </div>
                )}
              </div>
            </div>

            {/* Submit */}
            <div className="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-end pt-2">
              <button
                type="submit"
                disabled={saving}
                className="rounded-xl bg-slate-900 px-6 py-3 text-white font-bold hover:bg-slate-800 disabled:opacity-60"
              >
                {saving ? "Saving..." : mode === "create" ? "Create Lesson" : "Update Lesson"}
              </button>
            </div>
          </form>
        </div>

        {/* Footer note */}
        <div className="mt-4 text-xs text-slate-500">
          Make sure your backend route accepts <b>multipart/form-data</b> when sending video files.
        </div>
      </div>
    </div>
  );
}
