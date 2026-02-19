import { useEffect, useState } from "react";
import { Link, useParams, useNavigate } from "react-router-dom";
import { getDrawingLessonById } from "../../../services/Gemified_Knowledge_Builder/drawingLessonService.js";
import AdminLayout from "../../admin/Admin_Management/AdminLayout.jsx";
import { IoArrowBack, IoChevronDownSharp, IoPencil } from "react-icons/io5";

export default function DrawingLessonView() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [lesson, setLesson] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setError("");
        const res = await getDrawingLessonById(id);
        setLesson(res.data);
      } catch (e) {
        setError(e?.response?.data?.message || e.message || "Failed to load lesson");
      } finally {
        setLoading(false);
      }
    })();
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
            onClick={() => navigate("/drawing_lessons")}
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
            to={`/drawing_lessons/${lesson._id}/edit`}
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
                <span className="text-[#7A6357] font-semibold text-[14px]">{lesson.difficulty_level}</span>
              </div>

              {/* Description */}
              <div className="space-y-4">
                <div className="flex items-start gap-2">
                  <span className="text-[#BD9A6B] font-bold text-[14px] tracking-wider uppercase whitespace-nowrap">DISCRIPTION :</span>
                  <span className="text-[#7A6357] font-semibold text-[14px] leading-relaxed">
                    {lesson.description}
                  </span>
                </div>
              </div>

              {/* Video Player */}
              <div className="py-4 flex justify-center">
                <div className="w-full max-w-3xl aspect-video rounded-[15px] overflow-hidden border border-[#BD9A6B]/30 bg-[#EADED7]/50 shadow-inner flex items-center justify-center relative">
                  {lesson.video_url ? (
                    <video
                      src={lesson.video_url}
                      controls
                      className="w-full h-full object-contain"
                    />
                  ) : (
                    <div className="text-[#BD9A6B] font-bold opacity-40 italic">Video not available</div>
                  )}
                </div>
              </div>

              {/* Tips Section */}
              <div className="space-y-4 pt-4">
                <div className="flex items-start gap-2">
                  <span className="text-[#BD9A6B] font-bold text-[14px] tracking-wider uppercase whitespace-nowrap">TIPS :</span>
                  <div className="space-y-3">
                    {lesson.tips?.length ? (
                      lesson.tips.map((t, idx) => (
                        <div key={idx} className="text-[#7A6357] font-semibold text-[14px] leading-relaxed">
                          {t.tip}
                        </div>
                      ))
                    ) : (
                      <span className="text-[#7A6357]/60 italic text-[14px]">No tips added.</span>
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
