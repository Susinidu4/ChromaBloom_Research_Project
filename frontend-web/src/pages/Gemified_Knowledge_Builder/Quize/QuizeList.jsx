// src/pages/Gamified_Knowledge_Builder/Quize/QuizeList.jsx
import React, { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import QuizeService from "../../../services/Gemified_Knowledge_Builder/quizeService.js";
import ProblemSolvingLessonService from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

export default function QuizeList() {
  const [quizes, setQuizes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState({ type: "", text: "" });

  // filter lessons
  const [lessons, setLessons] = useState([]);
  const [lessonFilter, setLessonFilter] = useState("");

  const loadLessons = async () => {
    try {
      const res = await ProblemSolvingLessonService.getAll();

      const list =
        Array.isArray(res?.data?.data)
          ? res.data.data
          : Array.isArray(res?.data)
          ? res.data
          : res?.data?.data || res?.data || [];

      setLessons(
        [...list].sort((a, b) => String(a._id).localeCompare(String(b._id)))
      );
    } catch {
      setLessons([]);
    }
  };

  // ✅ UPDATED: service getAll() has NO lesson filter now
  // if lessonFilter is selected -> call getByLessonId()
  const loadQuizes = async (lessonId = "") => {
    setLoading(true);
    setMsg({ type: "", text: "" });

    try {
      const res = lessonId
        ? await QuizeService.getByLessonId(lessonId)
        : await QuizeService.getAll();

      const list = Array.isArray(res?.data) ? res.data : [];
      setQuizes(list);
    } catch (e) {
      setMsg({
        type: "error",
        text: e?.response?.data?.message || e?.message || "Failed to load quizzes",
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadLessons();
    loadQuizes("");
  }, []);

  const onDelete = async (id) => {
    const ok = window.confirm(`Delete quiz ${id}?`);
    if (!ok) return;

    try {
      await QuizeService.remove(id);
      setMsg({ type: "success", text: "Quiz deleted successfully." });
      loadQuizes(lessonFilter);
    } catch (e) {
      setMsg({
        type: "error",
        text: e?.response?.data?.message || e?.message || "Failed to delete quiz",
      });
    }
  };

  const filteredCount = useMemo(() => quizes.length, [quizes]);

  return (
    <div className="min-h-screen bg-[#F5ECEC] p-6 flex justify-center items-start">
      <div className="w-full max-w-6xl bg-white rounded-2xl p-5 shadow-[0_10px_30px_rgba(0,0,0,0.08)] border border-black/5">
        {/* Header */}
        <div className="flex items-center justify-between gap-3 mb-4">
          <h2 className="m-0 text-[22px] font-bold">All Quizzes</h2>

          <Link
            to="/quizes/create"
            className="px-4 py-2.5 rounded-xl bg-[#3D6B86] text-white font-extrabold text-[13px] no-underline inline-flex items-center justify-center"
          >
            + Create Quiz
          </Link>
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

        {/* Filters */}
        <div className="flex flex-col md:flex-row md:items-end gap-3 mb-4">
          <div className="flex flex-col gap-1 w-full md:w-[420px]">
            <label className="text-[13px] font-semibold opacity-85">
              Filter by Lesson
            </label>
            <select
              className="px-3 py-2.5 rounded-xl border border-black/15 outline-none text-[14px] bg-white"
              value={lessonFilter}
              onChange={(e) => {
                const v = e.target.value;
                setLessonFilter(v);
                loadQuizes(v);
              }}
            >
              <option value="">All lessons</option>
              {lessons.map((l) => (
                <option key={l._id} value={l._id}>
                  {l._id} — {l.title || "(No title)"}
                </option>
              ))}
            </select>
          </div>

          <div className="h-[42px] px-3 rounded-xl bg-[rgba(233,221,204,0.35)] border border-black/5 flex items-center text-[13px]">
            Showing <b className="mx-1">{filteredCount}</b>
          </div>
        </div>

        {/* Table */}
        {loading ? (
          <div className="p-3 rounded-xl border border-dashed border-black/20 opacity-80">
            Loading quizzes...
          </div>
        ) : quizes.length === 0 ? (
          <div className="p-3 rounded-xl border border-dashed border-black/20 opacity-80">
            No quizzes found.
          </div>
        ) : (
          <div className="overflow-x-auto rounded-xl border border-black/5">
            <table className="w-full border-collapse">
              <thead>
                <tr className="bg-black/3">
                  <th className="text-left text-[13px] p-3 border-b border-black/10 whitespace-nowrap">
                    Quiz ID
                  </th>
                  <th className="text-left text-[13px] p-3 border-b border-black/10 whitespace-nowrap">
                    Lesson
                  </th>
                  <th className="text-left text-[13px] p-3 border-b border-black/10 whitespace-nowrap">
                    Difficulty
                  </th>
                  <th className="text-left text-[13px] p-3 border-b border-black/10 whitespace-nowrap">
                    Correct
                  </th>
                  <th className="text-left text-[13px] p-3 border-b border-black/10 whitespace-nowrap">
                    Answers
                  </th>
                  <th className="text-left text-[13px] p-3 border-b border-black/10 whitespace-nowrap">
                    Actions
                  </th>
                </tr>
              </thead>

              <tbody>
                {quizes.map((q) => (
                  <tr key={q._id} className="hover:bg-black/2">
                    <td className="text-[13px] p-3 border-b border-black/5 align-top">
                      <b>{q._id}</b>
                    </td>
                    <td className="text-[13px] p-3 border-b border-black/5 align-top">
                      {q.lesson_id}
                    </td>
                    <td className="text-[13px] p-3 border-b border-black/5 align-top">
                      {q.difficulty_level}
                    </td>
                    <td className="text-[13px] p-3 border-b border-black/5 align-top">
                      #{q.correct_answer}
                    </td>
                    <td className="text-[13px] p-3 border-b border-black/5 align-top">
                      {(q.answers || []).length}
                    </td>
                    <td className="text-[13px] p-3 border-b border-black/5 align-top">
                      <div className="flex flex-wrap gap-2">
                        <Link
                          to={`/quizes/view/${q._id}`}
                          className="px-3 py-2 rounded-xl border border-black/20 bg-white font-extrabold text-[12px] text-black no-underline inline-flex items-center justify-center"
                        >
                          View
                        </Link>
                        <Link
                          to={`/quizes/edit/${q._id}`}
                          className="px-3 py-2 rounded-xl border border-black/20 bg-white font-extrabold text-[12px] text-black no-underline inline-flex items-center justify-center"
                        >
                          Edit
                        </Link>
                        <button
                          type="button"
                          onClick={() => onDelete(q._id)}
                          className="px-3 py-2 rounded-xl border border-red-500/25 bg-red-500/10 font-extrabold text-[12px]"
                        >
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
