// src/pages/Gamified_Knowledge_Builder/Quize/QuizeView.jsx
import React, { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { IoChevronBack, IoChevronDown } from "react-icons/io5";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";

export default function QuizeView() {
  const { id } = useParams();
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
    if (quiz?.correct_img_url) return quiz.correct_img_url;
    const idx = Number(quiz?.correct_answer || 1) - 1;
    return quiz?.answers?.[idx]?.img_url || "";
  };

  const correctUrl = getCorrectImageUrl();

  return (
    <AdminLayout>
      <div className="min-h-screen bg-[#F5ECEC] p-6 lg:p-10 font-sans text-[#8C7355]">
        {/* Back Button */}
        <div className="max-w-4xl mx-auto mb-6">
          <Link
            to="/learning_module"
            className="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-md hover:shadow-lg transition-all text-[#8C7355]"
          >
            <IoChevronBack size={20} />
          </Link>
        </div>

        <div className="max-w-4xl mx-auto bg-[#FDFCFB] rounded-[30px] p-8 lg:p-12 shadow-[0_15px_50px_rgba(0,0,0,0.05)] border border-[#E8D8C3] relative">


          {/* Alert */}
          {msg.text && (
            <div className={`p-4 rounded-2xl mb-6 text-sm border ${msg.type === "success" ? "bg-green-50 border-green-200 text-green-700" : "bg-red-50 border-red-200 text-red-700"
              }`}>
              {msg.text}
            </div>
          )}

          {loading ? (
            <div className="flex flex-col items-center justify-center py-20 opacity-50">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#8C7355] mb-4"></div>
              <p>Loading your quiz...</p>
            </div>
          ) : !quiz ? (
            <div className="text-center py-20 opacity-60">
              <p className="text-xl">Quiz not found.</p>
            </div>
          ) : (
            <div className="space-y-8">
              {/* Header Info */}
              <div className="space-y-4 border-b border-[#E8D8C3] pb-6">
                <div className="flex items-center gap-2">
                  <span className="font-bold text-lg uppercase tracking-wider">ID :</span>
                  <span className="text-lg opacity-80">{quiz._id}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-bold text-lg uppercase tracking-wider">Difficulty Level :</span>
                  <span className="text-lg opacity-80">{quiz.difficulty_level}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-bold text-lg uppercase tracking-wider">Lesson:</span>
                  <span className="text-lg opacity-80">{quiz.lesson_name || "Drawing a circle"}</span>
                </div>
                <div className="flex items-center justify-between border-t border-[#E8D8C3] pt-4 mt-4">
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-lg uppercase tracking-wider">Question :</span>
                    <span className="text-lg opacity-80">{quiz.question}</span>
                  </div>
                  <IoChevronDown size={24} className="opacity-40" />
                </div>
              </div>

              {/* Main Subject Section */}
              <div className="flex flex-col items-center space-y-4">
                <h3 className="text-2xl font-black uppercase tracking-[0.2em] text-[#8C7355]">
                  {quiz.name_tag || "OBJECT"}
                </h3>

                <div className="relative group">
                  <div className="absolute -inset-4 bg-[#8C7355]/5 rounded-[40px] blur-xl opacity-0 group-hover:opacity-100 transition-opacity"></div>
                  {correctUrl ? (
                    <img
                      src={correctUrl}
                      alt="Question Context"
                      className="relative w-64 h-64 object-contain transition-transform group-hover:scale-105"
                    />
                  ) : (
                    <div className="w-64 h-64 rounded-[40px] bg-[#F5ECEC] flex items-center justify-center text-sm italic opacity-50">
                      No image available
                    </div>
                  )}
                </div>
              </div>

              {/* Answers Grid */}
              <div className="grid grid-cols-2 gap-6 lg:gap-10 pt-10">
                {(quiz.answers || []).map((a, idx) => {
                  const isCorrect = Number(quiz.correct_answer) === idx + 1;
                  return (
                    <div
                      key={idx}
                      className={`relative group p-4 rounded-[25px] transition-all duration-300 ${isCorrect
                        ? "bg-[#E3F2E1] border-4 border-[#6BCB77] shadow-[0_8px_25px_rgba(107,203,119,0.2)]"
                        : "bg-[#FDF7F0] border-2 border-transparent hover:border-[#E8D8C3] hover:shadow-lg"
                        }`}
                    >
                      {a.img_url ? (
                        <div className="aspect-square flex items-center justify-center p-2">
                          <img
                            src={a.img_url}
                            alt={`Option ${idx + 1}`}
                            className="max-w-full max-h-full object-contain rounded-xl"
                          />
                        </div>
                      ) : (
                        <div className="aspect-square rounded-xl bg-white/50 flex items-center justify-center text-[12px] italic opacity-40">
                          Option {idx + 1}
                        </div>
                      )}

                      {/* Decorative notch like the image */}
                      <div className="absolute top-0 right-10 w-8 h-2 bg-[#F5ECEC] rounded-b-full"></div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
