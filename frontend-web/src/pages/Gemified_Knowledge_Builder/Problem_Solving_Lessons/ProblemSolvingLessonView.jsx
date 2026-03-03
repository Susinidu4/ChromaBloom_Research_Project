import React, { useEffect, useState } from "react";
import { Link, useParams, useNavigate } from "react-router-dom";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";
import { IoArrowBack, IoChevronDownSharp, IoPencil } from "react-icons/io5";

export default function ProblemSolvingLessonView() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [lesson, setLesson] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const load = async () => {
    try {
      setLoading(true);
      setError("");
      const res = await ProblemSolvingLessonService.getById(id);
      setLesson(res?.data || null);
    } catch (e) {
      setError(e?.response?.data?.message || e.message || "Failed to load lesson");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [id]);

  if (loading) return (
    <AdminLayout>
      <div className="w-full min-h-screen bg-[#F3E8E8] flex items-center justify-center">
        <p className="text-[#BD9A6B] font-bold text-xl animate-pulse tracking-widest uppercase">Loading Lesson...</p>
      </div>
    </AdminLayout>
  );

  if (error) return (
    <AdminLayout>
      <div className="w-full min-h-screen bg-[#F3E8E8] flex items-center justify-center p-10">
        <div className="bg-red-50 border border-red-200 text-red-700 p-8 rounded-2xl max-w-lg w-full text-center shadow-lg">
          <p className="font-bold text-xl mb-3">Error Occurred</p>
          <p className="mb-6 opacity-80">{error}</p>
          <button
            onClick={() => navigate(-1)}
            className="bg-red-600 text-white px-8 py-2.5 rounded-xl font-bold hover:bg-red-700 transition shadow-md"
          >
            Go Back
          </button>
        </div>
      </div>
    </AdminLayout>
  );

  if (!lesson) return (
    <AdminLayout>
      <div className="w-full min-h-screen bg-[#F3E8E8] flex items-center justify-center p-10">
        <div className="bg-white border border-[#BD9A6B]/30 p-12 rounded-3xl text-center shadow-xl">
          <p className="text-2xl font-bold text-[#BD9A6B] mb-6">Lesson Not Found</p>
          <button
            onClick={() => navigate("/problem_solving_lessons")}
            className="bg-[#A47C5B] text-white px-10 py-3.5 rounded-xl font-bold hover:brightness-95 transition shadow-lg"
          >
            Back to List
          </button>
        </div>
      </div>
    </AdminLayout>
  );

  return (
    <AdminLayout>
      <div className="w-full min-h-full bg-[#F3E8E8] px-6 md:px-10 py-10 md:py-16 relative">
        <div className="max-w-5xl mx-auto mb-10 flex items-center justify-between">
          {/* Back Button */}
          <button
            onClick={() => navigate(-1)}
            className="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-md text-[#BD9A6B] hover:bg-slate-50 transition"
            title="Go Back"
          >
            <IoArrowBack size={18} />
          </button>

          <Link
            to={`/problem_solving_lessons/${lesson._id}/edit`}
            className="flex items-center gap-2 bg-[#BD9A6B] text-white px-5 py-2 rounded-lg text-sm font-bold shadow-sm hover:brightness-95 transition"
          >
            <IoPencil size={16} />
            Edit
          </Link>
        </div>

        {/* Lesson View Card */}
        <div className="w-full max-w-5xl mx-auto rounded-[20px] border border-[#BD9A6B]/50 bg-[#F5ECE9] overflow-hidden shadow-sm">
          <div className="p-8 md:p-12 space-y-8">

            {/* Header Area */}
            <div className="flex items-center justify-between border-b border-[#BD9A6B]/30 pb-4">
              <h2 className="text-[#BD9A6B] text-xl font-bold">
                {lesson.title}
              </h2>
              <IoChevronDownSharp className="text-[#BD9A6B] text-xl" />
            </div>

            {/* Content Section */}
            <div className="space-y-6">

              {/* ID */}
              <div className="flex items-start gap-2">
                <span className="text-[#BD9A6B] font-bold text-[14px] tracking-wider uppercase whitespace-nowrap">ID :</span>
                <span className="text-[#7A6357] font-semibold text-[14px] break-all">{lesson._id}</span>
              </div>

              {/* Difficulty Level */}
              <div className="flex items-start gap-2">
                <span className="text-[#BD9A6B] font-bold text-[14px] tracking-wider uppercase whitespace-nowrap">DIFFICULTY LEVEL :</span>
                <span className="text-[#7A6357] font-semibold text-[14px]">{lesson.difficulty_level || "Beginner"}</span>
              </div>

              {/* Description */}
              <div className="space-y-4">
                <div className="flex items-start gap-2 border-b border-[#BD9A6B]/20 pb-4">
                  <span className="text-[#BD9A6B] font-bold text-[14px] tracking-wider uppercase whitespace-nowrap">DISCRIPTION :</span>
                  <span className="text-[#7A6357] font-semibold text-[14px] leading-relaxed whitespace-pre-wrap">
                    {lesson.description || "-"}
                  </span>
                </div>
              </div>

              {/* Mini Tutorial Name */}
              <div className="flex items-start gap-2">
                <span className="text-[#BD9A6B] font-bold text-[14px] tracking-wider uppercase whitespace-nowrap">TUTORIAL NAME :</span>
                <span className="text-[#7A6357] font-semibold text-[14px]">{lesson.miniTutorialsName || "-"}</span>
              </div>

              {/* Mini Tutorials Section */}
              <div className="space-y-4 pt-4">
                <div className="flex items-start gap-2">
                  <span className="text-[#BD9A6B] font-bold text-[14px] tracking-wider uppercase whitespace-nowrap">MINI TUTORIALS :</span>
                  <div className="space-y-4 flex-1">
                    {lesson.miniTutorials?.length ? (
                      lesson.miniTutorials
                        .slice()
                        .sort((a, b) => (a.tip_number || 0) - (b.tip_number || 0))
                        .map((t, idx) => (
                          <div key={`${t.tip_number}-${idx}`} className="bg-white/40 border border-[#BD9A6B]/20 p-4 rounded-xl shadow-sm">
                            <div className="flex items-center gap-3 mb-2">
                              <span className="w-8 h-8 bg-[#BD9A6B] text-white rounded-lg flex items-center justify-center font-bold text-sm">
                                {t.tip_number}
                              </span>
                              <span className="text-[#BD9A6B] font-bold text-xs tracking-widest uppercase">Step</span>
                            </div>
                            <p className="text-[#7A6357] font-semibold text-[14px] leading-relaxed">
                              {t.tip_content}
                            </p>
                          </div>
                        ))
                    ) : (
                      <span className="text-[#7A6357]/60 italic text-[14px]">No tutorials added.</span>
                    )}
                  </div>
                </div>
              </div>

            </div>
          </div>

          {/* Footer Accent */}
          <div className="bg-[#BD9A6B] h-1.5 w-full opacity-20"></div>
        </div>
      </div>
    </AdminLayout>
  );
}
