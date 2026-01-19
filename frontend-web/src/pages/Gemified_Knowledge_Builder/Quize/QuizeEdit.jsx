import React, { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

export default function QuizeEdit() {
  const { id } = useParams(); // QZ-0001
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
  });

  // selected new files (optional). if provided -> replace images on backend
  const [files, setFiles] = useState([]); // File|null aligned with answers

  const answerCount = useMemo(() => form.answers?.length || 0, [form.answers]);

  const setField = (key, value) => setForm((p) => ({ ...p, [key]: value }));

  const ensureCorrectAnswerInRange = (n) => {
    setForm((p) => {
      const current = Number(p.correct_answer || 1);
      const fixed = Math.min(Math.max(current, 1), n);
      return { ...p, correct_answer: fixed };
    });
  };

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      setMsg({ type: "", text: "" });

      try {
        // load lessons for dropdown
        try {
          const lr = await ProblemSolvingLessonService.getAll();
          const list = Array.isArray(lr?.data) ? lr.data : lr?.data?.data || [];
          setLessons([...list].sort((a, b) => String(a._id).localeCompare(String(b._id))));
        } catch {
          setLessons([]);
        }

        // load quiz
        const res = await QuizeService.getById(id);
        const quiz = res?.data;

        if (!quiz) {
          setMsg({ type: "error", text: "Quiz not found" });
          setLoading(false);
          return;
        }

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
          answers: normalizedAnswers,
        });

        setFiles(new Array(normalizedAnswers.length).fill(null));
        ensureCorrectAnswerInRange(normalizedAnswers.length);
      } catch (e) {
        setMsg({
          type: "error",
          text: e?.response?.data?.message || e?.message || "Failed to load quiz",
        });
      } finally {
        setLoading(false);
      }
    };

    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const onPickFile = (index, file) => {
    setFiles((p) => {
      const next = [...p];
      next[index] = file || null;
      return next;
    });
  };

  const validate = () => {
    if (!form.question.trim()) return "Question is required";
    if (!form.lesson_id?.trim()) return "Lesson is required";
    if (!form.difficulty_level) return "Difficulty level is required";

    const n = form.answers?.length || 0;
    if (n < 2) return "At least 2 answers are required";

    const ca = Number(form.correct_answer);
    if (!Number.isFinite(ca) || ca < 1 || ca > n) {
      return `Correct answer must be between 1 and ${n}`;
    }

    return null;
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setMsg({ type: "", text: "" });

    const err = validate();
    if (err) return setMsg({ type: "error", text: err });

    const hasNewImages = files.some((f) => !!f);

    try {
      setSaving(true);

      if (hasNewImages) {
        const missing = files.findIndex((f) => !f);
        if (missing !== -1) {
          setMsg({
            type: "error",
            text: `You selected image replacement. Please upload ALL images (missing Answer #${
              missing + 1
            }).`,
          });
          setSaving(false);
          return;
        }

        const payload = {
          question: form.question.trim(),
          lesson_id: form.lesson_id.trim(),
          name_tag: form.name_tag.trim(),
          difficulty_level: form.difficulty_level,
          correct_answer: Number(form.correct_answer),
          answers: (form.answers || []).map((a, i) => ({
            image_no: i + 1,
            img_url: a.img_url || "",
          })),
          images: files.filter(Boolean),
        };

        const res = await QuizeService.update(id, payload, { useMultipart: true });
        setMsg({ type: "success", text: `Updated: ${res?.data?._id || id}` });
      } else {
        const payload = {
          question: form.question.trim(),
          lesson_id: form.lesson_id.trim(),
          name_tag: form.name_tag.trim(),
          difficulty_level: form.difficulty_level,
          correct_answer: Number(form.correct_answer),
          answers: (form.answers || []).map((a, i) => ({
            image_no: i + 1,
            img_url: a.img_url || "",
          })),
        };

        const res = await QuizeService.update(id, payload, { useMultipart: false });
        setMsg({ type: "success", text: `Updated: ${res?.data?._id || id}` });
      }
    } catch (e) {
      setMsg({
        type: "error",
        text: e?.response?.data?.message || e?.message || "Failed to update quiz",
      });
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F5ECEC] p-6 flex justify-center items-start">
      <div className="w-full max-w-5xl bg-white rounded-2xl p-5 shadow-[0_10px_30px_rgba(0,0,0,0.08)] border border-black/5">
        {/* Header */}
        <div className="flex items-center justify-between gap-3 mb-4">
          <h2 className="m-0 text-[22px] font-bold">Edit Quiz</h2>

          <div className="flex gap-2">
            <Link
              to="/quizes_list"
              className="px-3 py-2 rounded-xl border border-black/20 bg-white font-bold text-[13px] text-black no-underline inline-flex items-center justify-center"
            >
              Back
            </Link>
            <Link
              to={`/quizes/view/${id}`}
              className="px-3 py-2 rounded-xl border border-black/20 bg-white font-bold text-[13px] text-black no-underline inline-flex items-center justify-center"
            >
              View
            </Link>
          </div>
        </div>

        {/* Alert */}
        {msg.text ? (
          <div
            className={[
              "p-3 rounded-xl mb-3 text-[14px] border",
              msg.type === "success"
                ? "bg-green-500/10 border-green-700/20"
                : "bg-red-500/10 border-red-700/20",
            ].join(" ")}
          >
            {msg.text}
          </div>
        ) : null}

        {loading ? (
          <div className="p-3 rounded-xl border border-dashed border-black/20 opacity-80">
            Loading quiz...
          </div>
        ) : (
          <form onSubmit={onSubmit} className="flex flex-col gap-4">
            {/* Question */}
            <div className="flex flex-col gap-1">
              <label className="text-[13px] font-semibold opacity-85">Question *</label>
              <input
                className="px-3 py-2.5 rounded-xl border border-black/15 outline-none text-[14px] bg-white"
                value={form.question}
                onChange={(e) => setField("question", e.target.value)}
              />
            </div>

            {/* Lesson + Difficulty */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="flex flex-col gap-1">
                <label className="text-[13px] font-semibold opacity-85">Lesson *</label>
                <select
                  className="px-3 py-2.5 rounded-xl border border-black/15 outline-none text-[14px] bg-white"
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
              </div>

              <div className="flex flex-col gap-1">
                <label className="text-[13px] font-semibold opacity-85">Difficulty Level *</label>
                <select
                  className="px-3 py-2.5 rounded-xl border border-black/15 outline-none text-[14px] bg-white"
                  value={form.difficulty_level}
                  onChange={(e) => setField("difficulty_level", e.target.value)}
                >
                  <option value="Beginner">Beginner</option>
                  <option value="Intermediate">Intermediate</option>
                  <option value="Advanced">Advanced</option>
                </select>
              </div>
            </div>

            {/* Name Tag + Correct Answer */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="flex flex-col gap-1">
                <label className="text-[13px] font-semibold opacity-85">Name Tag (optional)</label>
                <input
                  className="px-3 py-2.5 rounded-xl border border-black/15 outline-none text-[14px] bg-white"
                  value={form.name_tag}
                  onChange={(e) => setField("name_tag", e.target.value)}
                />
              </div>

              <div className="flex flex-col gap-1">
                <label className="text-[13px] font-semibold opacity-85">Correct Answer *</label>
                <select
                  className="px-3 py-2.5 rounded-xl border border-black/15 outline-none text-[14px] bg-white"
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

            {/* Answers */}
            <div className="p-4 rounded-2xl bg-[rgba(233,221,204,0.45)] border border-black/5">
              <div className="flex items-center justify-between mb-3">
                <h3 className="m-0 text-[16px] font-bold">
                  Answers (Existing + Optional Replace)
                </h3>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {(form.answers || []).map((a, idx) => {
                  const isCorrect = Number(form.correct_answer) === idx + 1;

                  return (
                    <div
                      key={idx}
                      className={[
                        "rounded-2xl bg-white border p-3",
                        isCorrect ? "border-green-700/30" : "border-black/10",
                      ].join(" ")}
                    >
                      <div className="flex items-center justify-between mb-2">
                        <b className="text-[14px]">Answer #{idx + 1}</b>
                        {isCorrect ? (
                          <span className="text-[12px] font-black px-3 py-1 rounded-full bg-green-600/10 border border-green-700/20">
                            Correct
                          </span>
                        ) : null}
                      </div>

                      {a.img_url ? (
                        <img
                          src={a.img_url}
                          alt={`Answer ${idx + 1}`}
                          className="w-full h-[220px] object-cover rounded-xl border border-black/10"
                        />
                      ) : (
                        <div className="w-full h-[220px] rounded-xl border border-dashed border-black/20 flex items-center justify-center opacity-75">
                          No image
                        </div>
                      )}

                      <div className="mt-3 flex flex-col gap-2">
                        <div className="text-[12px] opacity-75 font-semibold">
                          Replace image (optional)
                        </div>

                        <input
                          type="file"
                          accept="image/*"
                          onChange={(e) => onPickFile(idx, e.target.files?.[0] || null)}
                          className="px-3 py-2 rounded-xl border border-black/15 bg-white text-[13px]"
                        />

                        {files[idx] ? (
                          <div className="text-[12px] opacity-80">
                            New: <b>{files[idx].name}</b>
                          </div>
                        ) : (
                          <div className="text-[12px] opacity-80">No new image selected</div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>

              <p className="mt-3 mb-0 text-[12px] opacity-75">
                If you upload any new image, backend replaces the whole answers set. So upload ALL images for a clean update.
              </p>
            </div>

            {/* Actions */}
            <div className="flex gap-2 mt-1">
              <button
                type="submit"
                disabled={saving}
                className="px-4 py-2.5 rounded-xl bg-[#3D6B86] text-white font-extrabold text-[13px] disabled:opacity-60"
              >
                {saving ? "Saving..." : "Save Changes"}
              </button>
            </div>

            {/* small debug info if needed */}
            <div className="text-[12px] opacity-60">
              Answers: {answerCount}
            </div>
          </form>
        )}
      </div>
    </div>
  );
}
