import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";
import { IoArrowBack, IoChevronDownSharp } from "react-icons/io5";


const LEVELS = [
  { label: "Beginner", value: "Beginner" },
  { label: "Intermediate", value: "Intermediate" },
  { label: "Hard", value: "Advanced" },
];

export default function ProblemSolvingLessonEdit() {

  const { id } = useParams();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);

  const [form, setForm] = useState({
    title: "",
    description: "",
    difficulty_level: "Beginner",
    miniTutorialsName: "",
    miniTutorials: [{ tip_number: 1, tip_content: "" }],
  });

  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState({ type: "", text: "" });

  const setField = (key, value) => setForm((p) => ({ ...p, [key]: value }));

  const updateTip = (index, key, value) => {
    setForm((p) => {
      const next = [...(p.miniTutorials || [])];
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
      const next = [...(p.miniTutorials || [])];
      next.splice(index, 1);
      const renumbered = next.map((t, i) => ({ ...t, tip_number: i + 1 }));
      return {
        ...p,
        miniTutorials: renumbered.length > 0 ? renumbered : [{ tip_number: 1, tip_content: "" }],
      };
    });
  };

  // ---- validations  ----
  const validate = () => {
    if (!form.title.trim()) return "Title is required";
    if (!form.description.trim()) return "Description is required";
    if (!form.difficulty_level) return "Difficulty level is required";

  
    const tips = form.miniTutorials || [];
    const hasAnyTipText = tips.some((t) => (t.tip_content || "").trim().length > 0);

    if (hasAnyTipText) {
      const bad = tips.find((t) => !(t.tip_content || "").trim());
      if (bad) return "Please fill all mini tutorial tip contents (or remove empty ones).";
    }
    return null;
  };

  const buildPayload = () => {
    const title = form.title.trim();
    const description = form.description.trim();
    const miniTutorialsName = form.miniTutorialsName?.trim() || "";

    const tips = form.miniTutorials || [];
    const hasAnyTipText = tips.some((t) => (t.tip_content || "").trim().length > 0);

    return {
      title,
      description,
      difficulty_level: form.difficulty_level,
      miniTutorialsName,
      
      miniTutorials: hasAnyTipText
        ? tips
          .map((t, i) => ({
            tip_number: i + 1,
            tip_content: (t.tip_content || "").trim(),
          }))
          .filter((t) => t.tip_content.length > 0)
        : [],
    };
  };

  // ---- fetch existing lesson ----
  useEffect(() => {
    const run = async () => {
      if (!id) {
        setLoading(false);
        setMsg({ type: "error", text: "Missing lesson id for edit page." });
        return;
      }

      try {
        setLoading(true);
        const res = await ProblemSolvingLessonService.getById(id);

        const data = res?.data || {};
        const tips = Array.isArray(data.miniTutorials) ? data.miniTutorials : [];

        setForm({
          title: data.title || "",
          description: data.description || "",
          difficulty_level: data.difficulty_level || "Beginner",
          miniTutorialsName: data.miniTutorialsName || "",
          miniTutorials:
            tips.length > 0
              ? tips
                .sort((a, b) => (a.tip_number || 0) - (b.tip_number || 0))
                .map((t, i) => ({
                  tip_number: i + 1,
                  tip_content: t.tip_content || "",
                }))
              : [{ tip_number: 1, tip_content: "" }],
        });
      } catch (error) {
        setMsg({ type: "error", text: error?.message || "Failed to load lesson" });
      } finally {
        setLoading(false);
      }
    };

    run();
  }, [id]);

  // ---- submit update ----
  const onSubmit = async (e) => {
    e.preventDefault();
    setMsg({ type: "", text: "" });

    const err = validate();
    if (err) return setMsg({ type: "error", text: err });

    try {
      setSaving(true);
      await ProblemSolvingLessonService.update(id, buildPayload());
      navigate("/wellness_module");
    } catch (error) {
      setMsg({ type: "error", text: error?.message || "Failed to update lesson" });
    } finally {
      setSaving(false);
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
          {loading ? (
            <div className="p-20 text-center text-[#BD9A6B] font-bold">Loading Lesson...</div>
          ) : (
            <form onSubmit={onSubmit} className="p-8 md:p-12 space-y-8">
              {/* Header */}
              <div className="flex items-center justify-between border-b border-[#BD9A6B]/30 pb-4 mb-8">
                <h2 className="text-[#BD9A6B] text-xl font-bold">Edit Problem Solving Lesson</h2>
                <IoChevronDownSharp className="text-[#BD9A6B] text-xl" />
              </div>

              {msg.text && (
                <div className={`p-4 rounded-xl border text-sm ${msg.type === "success" ? "bg-green-100 text-green-700 border-green-200" : "bg-red-100 text-red-700 border-red-200"}`}>
                  {msg.text}
                </div>
              )}

              <div className="space-y-3">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">TITLE</label>
                <input
                  value={form.title}
                  onChange={(e) => setField("title", e.target.value)}
                  className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                />
              </div>

              <div className="space-y-3">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">DESCRIPTION</label>
                <textarea
                  rows={6}
                  value={form.description}
                  onChange={(e) => setField("description", e.target.value)}
                  className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                />
              </div>

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

              <div className="space-y-3">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">Mini Tutorials Name (optional)</label>
                <input
                  value={form.miniTutorialsName}
                  onChange={(e) => setField("miniTutorialsName", e.target.value)}
                  className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                />
              </div>

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
                          className="text-[#711A0C] text-[12px] font-bold hover:underline uppercase"
                        >
                          Remove
                        </button>
                      </div>
                      <input
                        value={tip.tip_content}
                        onChange={(e) => updateTip(idx, "tip_content", e.target.value)}
                        className="w-full bg-white/60 border border-[#BD9A6B]/30 rounded-[8px] px-4 py-2 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                      />
                    </div>
                  ))}
                </div>
              </div>

              <div className="flex justify-end pt-6">
                <button
                  type="submit"
                  disabled={saving}
                  className="bg-[#A47C5B] text-white px-10 py-3 rounded-[10px] font-bold shadow-lg hover:brightness-95 transition disabled:opacity-50"
                >
                  {saving ? "Saving..." : "Save Changes"}
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
