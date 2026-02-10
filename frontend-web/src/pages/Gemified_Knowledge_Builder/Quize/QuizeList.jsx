// src/pages/Gamified_Knowledge_Builder/Quize/QuizeList.jsx
import React, { useEffect, useMemo, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import { HiPencil, HiTrash } from "react-icons/hi";
import Swal from "sweetalert2";

export default function QuizeList({ searchTerm = "" }) {
  const [quizes, setQuizes] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  const loadQuizes = async () => {
    setLoading(true);
    try {
      const res = await QuizeService.getAll();
      setQuizes(Array.isArray(res?.data) ? res.data : []);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadQuizes();
  }, []);

  const onDelete = async (id) => {
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
        await QuizeService.remove(id);
        Swal.fire("Deleted!", "Quiz has been deleted.", "success");
        loadQuizes();
      } catch (e) {
        Swal.fire("Error", "Failed to delete quiz", "error");
      }
    }
  };

  const filteredQuizes = quizes.filter(q =>
    (q._id && q._id.toLowerCase().includes(searchTerm.toLowerCase())) ||
    (q.lesson_id && q.lesson_id.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  if (loading && quizes.length === 0) return <div className="text-center py-10 text-[#BD9A6B]">Loading...</div>;

  return (
    <div className="w-full">
      {/* Header / Actions - Removed Filter dropdown */}
      <div className="flex justify-end mb-8">
        <button
          onClick={() => navigate("/quizes/create")}
          className="bg-[#BD9A6B] text-white px-6 py-2.5 rounded-[10px] shadow-[0_6px_14px_rgba(0,0,0,0.15)] hover:brightness-95 transition font-semibold"
        >
          + Add New Quiz
        </button>
      </div>

      {filteredQuizes.length === 0 ? (
        <div className="text-center py-10 text-[#9C8577]">No quizzes found.</div>
      ) : (
        <div className="flex flex-col gap-5">
          {filteredQuizes.map((q) => (
            <div
              key={q._id}
              className="bg-[#F5ECE9] rounded-[15px] shadow-[0_4px_12px_rgba(0,0,0,0.08)] border border-[#EACFC8] flex items-center overflow-hidden"
            >
              {/* Left Accent Bar */}
              <div className="w-6 self-stretch bg-[#DFC7A7]/40 flex flex-col items-center justify-center gap-1.5 border-r border-[#EACFC8]/50">
                <div className="w-[3px] h-[3px] rounded-full bg-[#BD9A6B]" />
                <div className="w-[3px] h-[3px] rounded-full bg-[#BD9A6B]" />
                <div className="w-[3px] h-[3px] rounded-full bg-[#BD9A6B]" />
              </div>

              {/* Main Content */}
              <div className="flex-1 px-8 py-2 flex items-center justify-between">
                <div>
                  <h3 className="text-[16px] font-bold text-[#A47C5B] mb-2 leading-tight">
                    {q._id}
                  </h3>
                  <div className="flex flex-wrap gap-10 text-[13px] text-[#BD9A6B] font-medium opacity-90">
                    <span>Lesson: {q.lesson_id}</span>
                    <span>Level: {q.difficulty_level}</span>
                    <span>Answers: {(q.answers || []).length}</span>
                    <span className="text-[#2E7D32]">Correct: #{q.correct_answer}</span>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-5">
                  <button
                    onClick={() => navigate(`/quizes/edit/${q._id}`)}
                    className="text-[#B79264] hover:scale-110 transition p-1"
                    title="Edit"
                  >
                    <HiPencil size={28} />
                  </button>
                  <button
                    onClick={() => onDelete(q._id)}
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
