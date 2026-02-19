import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";
import { IoArrowBack, IoChevronDownSharp } from "react-icons/io5";

const LEVELS = [
  { label: "Beginner", value: "Beginner" },
  { label: "Intermediate", value: "Intermediate" },
  { label: "Hard", value: "Advanced" },
];

export default function QuizeEdit() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState({ type: "", text: "" });

  const [lessons, setLessons] = useState([]);

  const [form, setForm] = useState({
    question: "",
    lesson_id: "",
    name_tag: "",
    difficulty_level: "Beginner",
    correct_answer: 1,
    answers: [],
    correct_img_url: "",
  });

  const [correctFile, setCorrectFile] = useState(null);
  const [answerFiles, setAnswerFiles] = useState([]);

  const setField = (key, value) => setForm((p) => ({ ...p, [key]: value }));

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const lr = await ProblemSolvingLessonService.getAll();
        const list = Array.isArray(lr?.data) ? lr.data : [];
        setLessons([...list].sort((a, b) => String(a._id).localeCompare(String(b._id))));

        const res = await QuizeService.getById(id);
        const quiz = res?.data;

        if (quiz) {
          const answers = Array.isArray(quiz.answers) ? quiz.answers : [];
          const normalizedAnswers = answers
            .sort((a, b) => (a.image_no || 0) - (b.image_no || 0))
            .map((a, i) => ({ image_no: i + 1, img_url: a.img_url || "" }));

          setForm({
            question: quiz.question || "",
            lesson_id: quiz.lesson_id || "",
            name_tag: quiz.name_tag || "",
            difficulty_level: quiz.difficulty_level || "Beginner",
            correct_answer: Number(quiz.correct_answer || 1),
            correct_img_url: quiz.correct_img_url || "",
            answers: normalizedAnswers,
          });
          setAnswerFiles(new Array(normalizedAnswers.length).fill(null));
        }
      } catch (e) {
        setMsg({ type: "error", text: e?.message || "Failed to load quiz" });
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [id]);

  const validate = () => {
    if (!form.question.trim()) return "Question is required";
    if (!form.lesson_id?.trim()) return "Lesson is required";
    return null;
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setMsg({ type: "", text: "" });
    const err = validate();
    if (err) return setMsg({ type: "error", text: err });

    const hasNewAnswerImages = answerFiles.some((f) => !!f);
    const useMultipart = !!correctFile || hasNewAnswerImages;

    try {
      setSaving(true);
      const payload = {
        question: form.question.trim(),
        lesson_id: form.lesson_id.trim(),
        name_tag: form.name_tag.trim(),
        difficulty_level: form.difficulty_level,
        correct_answer: Number(form.correct_answer),
        answers: (form.answers || []).map((_, i) => ({ image_no: i + 1 })),
        correctImage: correctFile || undefined,
        answerImages: hasNewAnswerImages ? answerFiles.filter(Boolean) : undefined,
        correct_img_url: !correctFile ? form.correct_img_url : undefined,
      };

      await QuizeService.update(id, payload, { useMultipart });
      navigate("/wellness_module");
    } catch (e) {
      setMsg({ type: "error", text: e?.message || "Failed to update quiz" });
    } finally {
      setSaving(false);
    }
  };

  const correctPreviewUrl = useMemo(() => {
    if (correctFile) return URL.createObjectURL(correctFile);
    return form.correct_img_url || "";
  }, [correctFile, form.correct_img_url]);

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
          {loading ? (
            <div className="p-20 text-center text-[#BD9A6B] font-bold">Loading Quiz...</div>
          ) : (
            <form onSubmit={onSubmit} className="p-8 md:p-12 space-y-8">
              <div className="flex items-center justify-between border-b border-[#BD9A6B]/30 pb-4 mb-8">
                <h2 className="text-[#BD9A6B] text-xl font-bold">Edit Quiz</h2>
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
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-3">
                  <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">LESSON</label>
                  <select
                    value={form.lesson_id}
                    onChange={(e) => setField("lesson_id", e.target.value)}
                    className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                  >
                    {lessons.map((l) => (
                      <option key={l._id} value={l._id}>{l.title || l._id}</option>
                    ))}
                  </select>
                </div>
                <div className="space-y-3">
                  <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">NAME TAG</label>
                  <input
                    value={form.name_tag}
                    onChange={(e) => setField("name_tag", e.target.value)}
                    className="w-full bg-transparent rounded-[10px] border border-[#BD9A6B]/40 px-5 py-3 text-[#7A6357] outline-none focus:border-[#BD9A6B]"
                  />
                </div>
              </div>

              <div className="space-y-4">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">DIFFICULTY LEVEL</label>
                <div className="flex flex-wrap gap-4">
                  {LEVELS.map((l) => (
                    <button
                      key={l.value}
                      type="button"
                      onClick={() => setField("difficulty_level", l.value)}
                      className={["px-10 py-2.5 rounded-[10px] border font-semibold transition text-sm", form.difficulty_level === l.value ? "bg-[#BD9A6B] text-white border-[#BD9A6B] shadow-md" : "bg-transparent text-[#BD9A6B] border-[#BD9A6B]/40 hover:bg-[#BD9A6B]/5",].join(" ")}
                    >
                      {l.label}
                    </button>
                  ))}
                </div>
              </div>

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

              {/* Correct Image Panel */}
              <div className="space-y-4 bg-[#EADED7]/50 rounded-[20px] p-6 border border-[#BD9A6B]/20">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">CORRECT IMAGE PREVIEW</label>
                {correctPreviewUrl ? (
                  <img src={correctPreviewUrl} alt="Correct" className="w-full h-[350px] object-cover rounded-[15px] border border-[#BD9A6B]/30 shadow-sm" />
                ) : (
                  <div className="w-full h-[200px] flex items-center justify-center border-2 border-dashed border-[#BD9A6B]/40 rounded-[15px] text-[#BD9A6B] italic">No image available</div>
                )}
                <div className="flex flex-col gap-3">
                  <label className="text-[13px] font-bold text-[#A47C5B]">CHOOSE NEW IMAGE (OPTIONAL)</label>
                  <div className="flex items-center gap-4">
                    <label className="cursor-pointer bg-[#BD9A6B] text-white px-6 py-2 rounded-[8px] font-bold text-xs hover:brightness-95 transition">
                      Browse Files
                      <input type="file" accept="image/*" onChange={(e) => setCorrectFile(e.target.files?.[0] || null)} className="hidden" />
                    </label>
                    <span className="text-[#BD9A6B] text-xs font-medium">{correctFile ? correctFile.name : "No file selected"}</span>
                  </div>
                </div>
              </div>

              {/* Answer Options Grid */}
              <div className="space-y-4">
                <label className="block text-[14px] font-bold text-[#BD9A6B] tracking-wider uppercase">ANSWER OPTIONS (EXISTING + REPLACE)</label>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {form.answers.map((a, idx) => {
                    const isCorrect = form.correct_answer === idx + 1;
                    return (
                      <div key={idx} className={["bg-white rounded-[15px] border p-4 space-y-4 shadow-sm transition", isCorrect ? "border-[#BD9A6B] bg-[#BD9A6B]/5 shadow-md" : "border-[#BD9A6B]/20",].join(" ")}>
                        <div className="flex justify-between items-center">
                          <span className="bg-[#BD9A6B]/10 text-[#BD9A6B] px-3 py-1 rounded-full text-[11px] font-bold uppercase">Answer #{idx + 1}</span>
                          {isCorrect && <span className="text-[#BD9A6B] text-[11px] font-black uppercase tracking-tight">Correct Choice</span>}
                        </div>
                        <img src={a.img_url} alt={`Option ${idx + 1}`} className="w-full h-[180px] object-cover rounded-[10px] border border-[#BD9A6B]/10" />
                        <div className="space-y-2">
                          <label className="text-[11px] font-bold text-[#BD9A6B] uppercase opacity-70">Replace this option</label>
                          <div className="flex items-center gap-3">
                            <label className="cursor-pointer bg-[#EADED7] text-[#BD9A6B] px-3 py-1.5 rounded-[6px] font-bold text-[10px] hover:bg-[#DFC7A7] transition">
                              Select Cloud File
                              <input type="file" accept="image/*" onChange={(e) => {
                                const next = [...answerFiles];
                                next[idx] = e.target.files?.[0];
                                setAnswerFiles(next);
                              }} className="hidden" />
                            </label>
                            <span className="text-[10px] text-[#A47C5B] truncate max-w-[150px]">{answerFiles[idx] ? answerFiles[idx].name : "Original Image"}</span>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
                <p className="text-[12px] text-[#A47C5B]/80 italic mt-2">Note: To replace images, please select files for ALL slots to ensure consistency.</p>
              </div>

              <div className="flex justify-end pt-6">
                <button
                  type="submit"
                  disabled={saving}
                  className="bg-[#A47C5B] text-white px-10 py-3 rounded-[10px] font-bold shadow-lg hover:brightness-95 transition disabled:opacity-50"
                >
                  {saving ? "Saving Changes..." : "Save Changes"}
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
