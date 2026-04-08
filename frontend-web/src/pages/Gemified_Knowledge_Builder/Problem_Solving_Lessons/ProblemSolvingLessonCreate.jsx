import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";
import { IoArrowBack, IoChevronDownSharp } from "react-icons/io5";

const LEVELS = [
  { label: "Beginner", value: "Beginner" },
  { label: "Intermediate", value: "Intermediate" },
  { label: "Hard", value: "Advanced" },
];

export default function ProblemSolvingLessonCreate() {
  const navigate = useNavigate();
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
      await ProblemSolvingLessonService.create(payload);
      navigate("/learning_module");
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
    <AdminLayout>
      <div className="w-full min-h-full bg-[#F3E8E8] px-10 py-16 relative">
        {/* Back Button */}
        <button
          onClick={() => navigate(-1)}
          className="mb-10 w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg text-[#BD9A6B] hover:bg-slate-50 transition z-10"
        >
          <IoArrowBack size={20} />
        </button>

        <div className="w-full max-w-5xl mx-auto rounded-[20px] border border-[#BD9A6B]/50 bg-[#F5ECE9] overflow-hidden shadow-sm">
          <form onSubmit={onSubmit} className="p-8 md:p-12 space-y-8">

            {/* Header Section */}
            <div className="flex items-center justify-between border-b border-[#BD9A6B]/30 pb-4 mb-8">
              <h2 className="text-[#BD9A6B] text-xl font-bold">Create Problem Solving Lesson</h2>
              <IoChevronDownSharp className="text-[#BD9A6B] text-xl" />
            </div>

            {msg.text && (
              <div className={`p-4 rounded-xl border text-sm ${msg.type === "success" ? "bg-green-100 text-green-700 border-green-200" : "bg-red-100 text-red-700 border-red-200"}`}>
                {msg.text}
              </div>
            )}

            {/* Title */}
            <div className="space-y-3">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider">TITLE</label>
              <input
                value={form.title}
                onChange={(e) => setField("title", e.target.value)}
                className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                placeholder="e.g., Match the Shapes"
              />
            </div>

            {/* Description */}
            <div className="space-y-3">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider">DESCRIPTION</label>
              <textarea
                rows={6}
                value={form.description}
                onChange={(e) => setField("description", e.target.value)}
                className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                placeholder="Short lesson description..."
              />
            </div>

            {/* Difficulty Level */}
            <div className="space-y-4">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">Difficulty Level</label>
              <div className="flex flex-wrap gap-4">
                {LEVELS.map((l) => {
                  const active = form.difficulty_level === l.value;
                  return (
                    <button
                      key={l.value}
                      type="button"
                      onClick={() => setField("difficulty_level", l.value)}
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

            {/* Mini Tutorials Name */}
            <div className="space-y-3">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">Mini Tutorials Name (optional)</label>
              <input
                value={form.miniTutorialsName}
                onChange={(e) => setField("miniTutorialsName", e.target.value)}
                className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                placeholder="e.g., Parent Guidance Tips"
              />
            </div>

            {/* Tips Section */}
            <div className="space-y-4">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider">TIPS</label>
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

                {form.miniTutorials.map((tip, idx) => (
                  <div key={idx} className="bg-[#EADED7]/80 border border-[#BD9A6B]/20 rounded-[12px] p-5">
                    <div className="flex items-center justify-between mb-3">
                      <span className="bg-white/80 border border-[#BD9A6B]/30 px-4 py-1 rounded-full text-[11px] font-bold text-[#A47C5B]">
                        TIP {idx + 1}
                      </span>
                      <button
                        type="button"
                        onClick={() => removeTip(idx)}
                        disabled={form.miniTutorials.length === 1}
                        className="text-[#711A0C] text-[12px] font-bold hover:underline uppercase disabled:opacity-50"
                      >
                        Remove
                      </button>
                    </div>
                    <input
                      value={tip.tip_content}
                      onChange={(e) => updateTip(idx, "tip_content", e.target.value)}
                      placeholder="Tip content..."
                      className="w-full bg-white/60 border border-[#BD9A6B]/30 rounded-[8px] px-4 py-2 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                    />
                  </div>
                ))}
              </div>
            </div>

            {/* Submit */}
            <div className="flex justify-end pt-6">
              <button
                type="submit"
                disabled={submitting}
                className="bg-[#A47C5B] text-white px-10 py-3 rounded-[10px] font-bold shadow-lg hover:brightness-95 transition disabled:opacity-50"
              >
                {submitting ? "Creating..." : "Create Lesson"}
              </button>
            </div>
          </form>
        </div>
      </div>
    </AdminLayout>
  );
}
