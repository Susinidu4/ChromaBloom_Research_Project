import { useEffect, useMemo, useState } from "react";
import { IoChevronDownSharp } from "react-icons/io5";

const LEVELS = [
  { label: "Beginner", value: "Beginner" },
  { label: "Intermediate", value: "Intermediate" },
  { label: "Hard", value: "Advanced" },
];

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
  const initial = useMemo(() => ({
    title: initialValue?.title || "",
    description: initialValue?.description || "",
    difficulty_level: initialValue?.difficulty_level || "Beginner",
    tips: safeJsonTips(initialValue?.tips),
    videoFile: null,
  }), [initialValue]);

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
    setTips((prev) => prev.filter((_, i) => i !== index).map((t, i) => ({ ...t, tip_number: i + 1 })));
  }

  function updateTip(index, value) {
    setTips((prev) => prev.map((t, i) => (i === index ? { ...t, tip: value } : t)));
  }

  function validate() {
    if (!title.trim()) return "Title is required";
    if (!description.trim()) return "Description is required";
    if (mode === "create" && !videoFile) return "Video file is required";
    return "";
  }

  async function handleSubmit(e) {
    e.preventDefault();
    const v = validate();
    if (v) { setFormError(v); return; }
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
    <div className="w-full max-w-5xl mx-auto rounded-[20px] border border-[#BD9A6B]/50 bg-[#F5ECE9] overflow-hidden shadow-sm">
      <form onSubmit={handleSubmit} className="p-8 md:p-12 space-y-8">

        {/* Header Section */}
        <div className="flex items-center justify-between border-b border-[#BD9A6B]/30 pb-4 mb-8">
          <h2 className="text-[#BD9A6B] text-xl font-bold">
            {mode === "create" ? "Create Drawing Lesson" : "Update Drawing Lesson"}
          </h2>
          <IoChevronDownSharp className="text-[#BD9A6B] text-xl" />
        </div>

        {formError && (
          <div className="p-3 bg-red-100 text-red-700 rounded-lg text-sm border border-red-200">
            {formError}
          </div>
        )}

        {/* Title */}
        <div className="space-y-3">
          <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider">
            TITLE
          </label>
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
          />
        </div>

        {/* Description */}
        <div className="space-y-3">
          <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider">
            DESCRIPTION
          </label>
          <textarea
            rows={6}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
          />
        </div>

        {/* Difficulty Level */}
        <div className="space-y-4">
          <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">
            Difficulty Level
          </label>
          <div className="flex flex-wrap gap-4">
            {LEVELS.map((l) => {
              const active = difficulty === l.value;
              return (
                <button
                  key={l.value}
                  type="button"
                  onClick={() => setDifficulty(l.value)}
                  className={[
                    "px-10 py-2.5 rounded-[10px] border font-semibold transition text-sm",
                    active
                      ? "bg-[#BD9A6B] text-white border-[#BD9A6B] shadow-md"
                      : "bg-transparent text-[#BD9A6B] border-[#BD9A6B]/40 hover:bg-[#BD9A6B]/5",
                  ].join(" ")}
                >
                  {l.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Tips Section */}
        <div className="space-y-4">
          <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider">
            TIPS
          </label>
          <div className="rounded-[15px] border border-[#BD9A6B]/40 p-6 space-y-4">
            <div className="flex justify-end">
              <button
                type="button"
                onClick={addTip}
                className="bg-[#BD9A6B]/80 hover:bg-[#BD9A6B] text-white px-5 py-2 rounded-lg text-sm font-bold transition shadow-sm"
              >
                + Add Tip
              </button>
            </div>

            {tips.map((t, idx) => (
              <div key={idx} className="bg-[#EADED7]/80 border border-[#BD9A6B]/20 rounded-[12px] p-5">
                <div className="flex items-center justify-between mb-3">
                  <span className="bg-white/80 border border-[#BD9A6B]/30 px-4 py-1 rounded-full text-[11px] font-bold text-[#A47C5B]">
                    TIP {t.tip_number}
                  </span>
                  <button
                    type="button"
                    onClick={() => removeTip(idx)}
                    className="text-[#711A0C] text-[12px] font-bold hover:underline uppercase"
                  >
                    Remove
                  </button>
                </div>
                <input
                  value={t.tip}
                  onChange={(e) => updateTip(idx, e.target.value)}
                  placeholder="..."
                  className="w-full bg-white/60 border border-[#BD9A6B]/30 rounded-[8px] px-4 py-2 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                />
              </div>
            ))}
            {tips.length === 0 && (
              <p className="text-center py-4 text-[#BD9A6B]/60 text-sm italic">No tips added yet. Click "+ Add Tip" to start.</p>
            )}
          </div>
        </div>

        {/* Video Upload */}
        <div className="space-y-4">
          <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">
            Video (Required)
          </label>
          <div className="rounded-[12px] border border-dashed border-[#BD9A6B]/50 p-8 flex flex-col items-center justify-center bg-transparent">
            <div className="flex items-center gap-6 mb-3 self-start">
              <label className="cursor-pointer bg-[#BD9A6B] text-white px-8 py-2 rounded-[8px] font-bold text-sm shadow-sm hover:brightness-95 transition">
                Choose file
                <input
                  type="file"
                  accept="video/*"
                  onChange={(e) => setVideoFile(e.target.files?.[0] || null)}
                  className="hidden"
                />
              </label>
              <span className="text-[#BD9A6B] text-sm font-medium">
                {videoFile ? videoFile.name : "No file choose"}
              </span>
            </div>
            <p className="w-full text-left text-[11px] text-[#BD9A6B]/80 italic">
              max side depend on your backend size
            </p>
          </div>
        </div>

        {/* Submit */}
        <div className="flex justify-end pt-6">
          <button
            type="submit"
            disabled={saving}
            className="bg-[#A47C5B] text-white px-10 py-3 rounded-[10px] font-bold shadow-lg hover:brightness-95 transition disabled:opacity-50"
          >
            {saving ? (mode === "create" ? "Creating..." : "Updating...") : (mode === "create" ? "Create lesson" : "Update lesson")}
          </button>
        </div>
      </form>
    </div>
  );
}
