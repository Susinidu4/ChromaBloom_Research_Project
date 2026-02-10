import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { deleteDrawingLesson, getAllDrawingLessons } from "../../../services/Gemified_Knowledge_Builder/drawingLessonService.js";
import { HiPencil, HiTrash } from "react-icons/hi";
import Swal from "sweetalert2";

export default function DrawingLessonList({ searchTerm = "", difficultyFilter = "" }) {
  const [loading, setLoading] = useState(true);
  const [lessons, setLessons] = useState([]);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  async function load() {
    try {
      setLoading(true);
      setError("");
      const res = await getAllDrawingLessons();
      setLessons(res.data || []);
    } catch (e) {
      setError(e?.response?.data?.message || e.message || "Failed to load lessons");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function onDelete(id) {
    const result = await Swal.fire({
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#711A0C",
      cancelButtonColor: "#BD9A6B",
      confirmButtonText: "Yes, delete it!"
    });

    if (result.isConfirmed) {
      try {
        await deleteDrawingLesson(id);
        Swal.fire("Deleted!", "Lesson has been deleted.", "success");
        await load();
      } catch (e) {
        Swal.fire("Error", e?.response?.data?.message || e.message || "Delete failed", "error");
      }
    }
  }

  const filteredLessons = lessons.filter(l => {
    const matchesSearch = l.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (l._id && l._id.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesDifficulty = difficultyFilter === "" || l.difficulty_level === difficultyFilter;
    return matchesSearch && matchesDifficulty;
  });

  if (loading) return <div className="text-center py-10 text-[#BD9A6B]">Loading...</div>;
  if (error) return <div className="text-center py-10 text-[#711A0C]">{error}</div>;

  return (
    <div className="w-full">
      <div className="flex justify-end mb-6">
        <button
          onClick={() => navigate("/drawing_lessons_create")}
          className="bg-[#BD9A6B] text-white px-6 py-2 rounded-[10px] shadow-[0_6px_14px_rgba(0,0,0,0.15)] hover:brightness-95 transition font-semibold"
        >
          + Add New Lesson
        </button>
      </div>

      {filteredLessons.length === 0 ? (
        <div className="text-center py-10 text-[#9C8577]">No lessons found.</div>
      ) : (
        <div className="flex flex-col gap-5">
          {filteredLessons.map((l) => (
            <div
              key={l._id}
              className="bg-[#F5ECE9] rounded-[15px] shadow-[0_4px_12px_rgba(0,0,0,0.08)] border border-[#EACFC8] flex items-center overflow-hidden"
            >
              {/* Left Accent Bar */}
              <div className="w-6 self-stretch bg-[#DFC7A7]/40 flex flex-col items-center justify-center gap-1.5 border-r border-[#EACFC8]/50">
                <div className="w-[3px] h-[3px] rounded-full bg-[#BD9A6B]" />
                <div className="w-[3px] h-[3px] rounded-full bg-[#BD9A6B]" />
                <div className="w-[3px] h-[3px] rounded-full bg-[#BD9A6B]" />
              </div>

              {/* Main Content */}
              <div
                className="flex-1 px-8 py-2 flex items-center justify-between cursor-pointer hover:bg-black/5 transition"
                onClick={() => navigate(`/drawing_lessons/${l._id}`)}
              >
                <div>
                  <h3 className="text-[16px] font-bold text-[#A47C5B] mb-2 leading-tight">
                    {l.title}
                  </h3>
                  <div className="flex gap-12 text-[13px] text-[#BD9A6B] font-medium opacity-90">
                    <span>ID : {l._id}</span>
                    <span>Difficulty Level : {l.difficulty_level}</span>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-5">
                  <button
                    onClick={() => navigate(`/drawing_lessons/${l._id}/edit`)}
                    className="text-[#B79264] hover:scale-110 transition p-1"
                    title="Edit"
                  >
                    <HiPencil size={28} />
                  </button>
                  <button
                    onClick={() => onDelete(l._id)}
                    className="text-[#711A0C] hover:scale-110 transition p-1"
                    title="Delete"
                  >
                    <HiTrash size={28} />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
