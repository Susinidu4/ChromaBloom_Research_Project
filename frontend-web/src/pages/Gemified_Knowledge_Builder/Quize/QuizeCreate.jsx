// src/pages/Gamified_Knowledge_Builder/Quize/QuizeCreate.jsx
import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";
import { IoArrowBack, IoChevronDownSharp } from "react-icons/io5";

const LEVELS = [
  { label: "Beginner", value: "Beginner" },
  { label: "Intermediate", value: "Intermediate" },
  { label: "Hard", value: "Advanced" },
];

export default function QuizeCreate() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    question: "",
    lesson_id: "",
    name_tag: "",
    difficulty_level: "Beginner",
    correct_answer: 1,
    answers: [
      { image_no: 1 },
      { image_no: 2 },
      { image_no: 3 },
      { image_no: 4 },
    ],
  });

  const [correctFile, setCorrectFile] = useState(null);
  const [answerFiles, setAnswerFiles] = useState([null, null, null, null]);
  const [submitting, setSubmitting] = useState(false);
  const [msg, setMsg] = useState({ type: "", text: "" });

  const [lessons, setLessons] = useState([]);
  const [lessonsLoading, setLessonsLoading] = useState(true);
  const [lessonsError, setLessonsError] = useState("");

  const setField = (key, value) => setForm((p) => ({ ...p, [key]: value }));
  const answerCount = useMemo(() => form.answers?.length || 0, [form.answers]);

  useEffect(() => {
    const loadLessons = async () => {
      setLessonsLoading(true);
      setLessonsError("");
      try {
        const res = await ProblemSolvingLessonService.getAll();
        const normalized = Array.isArray(res?.data) ? res.data : [];
        const sorted = [...normalized].sort((a, b) => String(a._id).localeCompare(String(b._id)));
        setLessons(sorted);
        if (sorted.length > 0) setField("lesson_id", sorted[0]._id);
      } catch (e) {
        setLessonsError(e?.message || "Failed to load lessons");
      } finally {
        setLessonsLoading(false);
      }
    };
    loadLessons();
  }, []);

  const addAnswerSlot = () => {
    setForm((p) => {
      const nextNo = (p.answers?.length || 0) + 1;
      return { ...p, answers: [...p.answers, { image_no: nextNo }] };
    });
    setAnswerFiles((prev) => [...prev, null]);
  };

  const removeAnswerSlot = (index) => {
    if ((form.answers?.length || 0) <= 2) return;
    setForm((p) => {
      const next = [...p.answers];
      next.splice(index, 1);
      return { ...p, answers: next.map((a, i) => ({ ...a, image_no: i + 1 })) };
    });
    setAnswerFiles((p) => {
      const next = [...p];
      next.splice(index, 1);
      return next;
    });
  };

  const onPickAnswerFile = (index, file) => {
    setAnswerFiles((p) => {
      const next = [...p];
      next[index] = file || null;
      return next;
    });
  };

  const validate = () => {
    if (!form.question.trim()) return "Question is required";
    if (!form.lesson_id?.trim()) return "Select a lesson";
    if (!correctFile) return "Correct Answer image is required";
    const missing = answerFiles.findIndex((f) => !f);
    if (missing !== -1) return `Answer #${missing + 1} image is required`;
    return null;
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setMsg({ type: "", text: "" });
    const err = validate();
    if (err) return setMsg({ type: "error", text: err });

    const payload = {
      question: form.question.trim(),
      lesson_id: form.lesson_id.trim(),
      name_tag: form.name_tag.trim(),
      difficulty_level: form.difficulty_level,
      correct_answer: Number(form.correct_answer),
      answers: (form.answers || []).map((_, i) => ({ image_no: i + 1 })),
      correctImage: correctFile,
      answerImages: answerFiles.filter(Boolean),
    };

    try {
      setSubmitting(true);
      await QuizeService.create(payload, { useMultipart: true });
      navigate("/wellness_module");
    } catch (error) {
      setMsg({ type: "error", text: error?.message || "Failed to create quiz" });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <AdminLayout>
      <div className="w-full min-h-full bg-[#F3E8E8] px-10 py-16 relative">
        <button
          onClick={() => navigate(-1)}
          className="mb-10 w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg text-[#BD9A6B] hover:bg-slate-50 transition z-10"
        >
          <IoArrowBack size={20} />
        </button>

        <div className="w-full max-w-5xl mx-auto rounded-[20px] border border-[#BD9A6B]/50 bg-[#F5ECE9] overflow-hidden shadow-sm">
          <form onSubmit={onSubmit} className="p-8 md:p-12 space-y-8">
            <div className="flex items-center justify-between border-b border-[#BD9A6B]/30 pb-4 mb-8">
              <h2 className="text-[#BD9A6B] text-xl font-bold">Create Quiz</h2>
              <IoChevronDownSharp className="text-[#BD9A6B] text-xl" />
            </div>

            {msg.text && (
              <div className={`p-4 rounded-xl border text-sm ${msg.type === "success" ? "bg-green-100 text-green-700 border-green-200" : "bg-red-100 text-red-700 border-red-200"}`}>
                {msg.text}
              </div>
            )}

            <div className="space-y-3">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">QUESTION</label>
              <input
                value={form.question}
                onChange={(e) => setField("question", e.target.value)}
                className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                placeholder="e.g., Which image shows a triangle?"
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="space-y-3">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">LESSON</label>
                {lessonsLoading ? (
                  <div className="text-[14px] text-[#BD9A6B] italic">Loading lessons...</div>
                ) : (
                  <select
                    value={form.lesson_id}
                    onChange={(e) => setField("lesson_id", e.target.value)}
                    className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none appearance-none cursor-pointer focus:border-[#BD9A6B]"
                  >
                    {lessons.map((l) => (
                      <option key={l._id} value={l._id}>{l.title || l._id}</option>
                    ))}
                  </select>
                )}
              </div>
              <div className="space-y-3">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">NAME TAG</label>
                <input
                  value={form.name_tag}
                  onChange={(e) => setField("name_tag", e.target.value)}
                  className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                  placeholder="e.g., Shapes"
                />
              </div>
            </div>

            <div className="space-y-4">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">DIFFICULTY LEVEL</label>
              <div className="flex flex-wrap gap-4">
                {LEVELS.map((l) => {
                  const active = form.difficulty_level === l.value;
                  return (
                    <button
                      key={l.value}
                      type="button"
                      onClick={() => setField("difficulty_level", l.value)}
                      className={["px-10 py-2.5 rounded-[10px] border font-semibold transition text-sm", active ? "bg-[#BD9A6B] text-white border-[#BD9A6B] shadow-md" : "bg-transparent text-[#BD9A6B] border-[#BD9A6B]/40 hover:bg-[#BD9A6B]/5",].join(" ")}
                    >
                      {l.label}
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="space-y-3">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">CORRECT ANSWER (SLOT #)</label>
                <select
                  value={form.correct_answer}
                  onChange={(e) => setField("correct_answer", Number(e.target.value))}
                  className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                >
                  {form.answers.map((_, i) => (
                    <option key={i} value={i + 1}>Answer #{i + 1}</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="space-y-4">
              <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">CORRECT ANSWER IMAGE</label>
              <div className="rounded-[12px] border border-dashed border-[#BD9A6B]/50 p-6 flex flex-col items-center justify-center bg-transparent">
                <div className="flex items-center gap-6 self-start">
                  <label className="cursor-pointer bg-[#BD9A6B] text-white px-8 py-2 rounded-[8px] font-bold text-sm shadow-sm hover:brightness-95 transition">
                    Choose file
                    <input type="file" accept="image/*" onChange={(e) => setCorrectFile(e.target.files?.[0] || null)} className="hidden" />
                  </label>
                  <span className="text-[#BD9A6B] text-sm font-medium">{correctFile ? correctFile.name : "No file chosen"}</span>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">ANSWER OPTIONS (IMAGES)</label>
                <button type="button" onClick={addAnswerSlot} className="bg-[#BD9A6B]/80 hover:bg-[#BD9A6B] text-white px-5 py-2 rounded-lg text-sm font-bold transition shadow-sm">+ Add Answer</button>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {form.answers.map((a, idx) => (
                  <div key={idx} className="bg-[#EADED7]/80 border border-[#BD9A6B]/20 rounded-[12px] p-5 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="bg-white/80 border border-[#BD9A6B]/30 px-4 py-1 rounded-full text-[11px] font-bold text-[#A47C5B]">ANSWER #{idx + 1}</span>
                      <button type="button" onClick={() => removeAnswerSlot(idx)} disabled={form.answers.length <= 2} className="text-[#711A0C] text-[12px] font-bold hover:underline uppercase disabled:opacity-30">Remove</button>
                    </div>
                    <div className="flex items-center gap-4">
                      <label className="cursor-pointer bg-white/60 border border-[#BD9A6B]/40 text-[#BD9A6B] px-4 py-1.5 rounded-[6px] font-bold text-xs shadow-sm hover:bg-white transition whitespace-nowrap">
                        Select Image
                        <input type="file" accept="image/*" onChange={(e) => onPickAnswerFile(idx, e.target.files?.[0] || null)} className="hidden" />
                      </label>
                      <span className="text-[#BD9A6B] text-xs font-medium truncate">{answerFiles[idx] ? answerFiles[idx].name : "No image selected"}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex justify-end pt-6">
              <button
                type="submit"
                disabled={submitting}
                className="bg-[#A47C5B] text-white px-10 py-3 rounded-[10px] font-bold shadow-lg hover:brightness-95 transition disabled:opacity-50"
              >
                {submitting ? "Creating..." : "Create Quiz"}
              </button>
            </div>
          </form>
        </div>
      </div>
    </AdminLayout>
  );
}
