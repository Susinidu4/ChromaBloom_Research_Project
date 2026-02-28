// src/pages/Gamified_Knowledge_Builder/Quize/QuizeView.jsx
import React, { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";

export default function QuizeView() {
  const { id } = useParams(); // QZ-0001
  const [quiz, setQuiz] = useState(null);
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState({ type: "", text: "" });

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      setMsg({ type: "", text: "" });
      try {
        const res = await QuizeService.getById(id);
        setQuiz(res?.data || null);
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
  }, [id]);

  const getCorrectImageUrl = () => {
    // ✅ NEW: use correct_img_url if exists
    if (quiz?.correct_img_url) return quiz.correct_img_url;

    // fallback: from answers using correct_answer index
    const idx = Number(quiz?.correct_answer || 1) - 1;
    return quiz?.answers?.[idx]?.img_url || "";
  };

  const correctUrl = getCorrectImageUrl();

  return (
    <AdminLayout>
      <div className="min-h-screen bg-[#F5ECEC] p-6 flex justify-center items-start">
        <div className="w-full max-w-5xl bg-white rounded-2xl p-5 shadow-[0_10px_30px_rgba(0,0,0,0.08)] border border-black/5">
          {/* Header */}
          <div className="flex items-center justify-between gap-3 mb-4">
            <h2 className="m-0 text-[22px] font-bold">View Quiz</h2>

            <div className="flex gap-2">
              <Link
                to="/quizes/list"
                className="px-3 py-2 rounded-xl border border-black/20 bg-white font-bold text-[13px] text-black no-underline inline-flex items-center justify-center"
              >
                Back
              </Link>
              <Link
                to={`/quizes/edit/${id}`}
                className="px-3 py-2 rounded-xl border border-transparent bg-[#3D6B86] text-white font-extrabold text-[13px] no-underline inline-flex items-center justify-center"
              >
                Edit
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

          {/* Content */}
          {loading ? (
            <div className="p-3 rounded-xl border border-dashed border-black/20 opacity-80">
              Loading quiz...
            </div>
          ) : !quiz ? (
            <div className="p-3 rounded-xl border border-dashed border-black/20 opacity-80">
              Quiz not found.
            </div>
          ) : (
            <>
              {/* Info Cards */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3 mb-4">
                <Info label="Quiz ID" value={quiz._id} />
                <Info label="Lesson ID" value={quiz.lesson_id} />
                <Info label="Difficulty" value={quiz.difficulty_level} />
                <Info label="Correct Answer" value={`#${quiz.correct_answer}`} />
                <Info label="Name Tag" value={quiz.name_tag || "-"} />
              </div>

              {/* Question */}
              <div className="p-4 rounded-2xl bg-[rgba(233,221,204,0.45)] border border-black/5 mb-4">
                <h3 className="m-0 text-[16px] font-bold">Question</h3>
                <div className="mt-2 p-3 rounded-xl border border-black/10 bg-white text-[14px] leading-relaxed">
                  {quiz.question}
                </div>
              </div>

              {/* ✅ NEW: Correct image panel */}
              <div className="p-4 rounded-2xl bg-[rgba(233,221,204,0.45)] border border-black/5 mb-4">
                <h3 className="m-0 text-[16px] font-bold">Correct Image</h3>

                <div className="mt-3">
                  {correctUrl ? (
                    <img
                      src={correctUrl}
                      alt="Correct"
                      className="w-full h-[320px] object-cover rounded-2xl border border-black/10 bg-white"
                    />
                  ) : (
                    <div className="w-full h-[220px] rounded-2xl border border-dashed border-black/20 flex items-center justify-center opacity-75 bg-white">
                      No correct image
                    </div>
                  )}
                </div>
              </div>

              {/* Answers */}
              <div className="p-4 rounded-2xl bg-[rgba(233,221,204,0.45)] border border-black/5">
                <h3 className="m-0 text-[16px] font-bold">Answers</h3>

                <div className="mt-3 grid grid-cols-1 md:grid-cols-2 gap-3">
                  {(quiz.answers || []).map((a, idx) => {
                    const isCorrect = Number(quiz.correct_answer) === idx + 1;

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
                              Correct Option
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
                      </div>
                    );
                  })}
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}

function Info({ label, value }) {
  return (
    <div className="p-3 rounded-2xl border border-black/5 bg-[rgba(233,221,204,0.25)]">
      <div className="text-[12px] opacity-70 mb-1">{label}</div>
      <div className="text-[14px] font-extrabold">{value}</div>
    </div>
  );
}
