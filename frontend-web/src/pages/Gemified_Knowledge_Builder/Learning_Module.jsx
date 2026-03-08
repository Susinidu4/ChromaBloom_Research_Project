import React, { useState } from "react";
import AdminLayout from "../admin/Admin_Management/AdminLayout";
import { IoSearchSharp } from "react-icons/io5";
import DrawingLessonList from "./Drawing_Lessons/DrawingLessonList";
import ProblemSolvingLessonList from "./Problem_Solving_Lessons/ProblemSolvingLessonList";
import QuizeList from "./Quize/QuizeList";
import { useNavigate } from "react-router-dom";

export default function Learning_Module() {
    const [activeTab, setActiveTab] = useState("drawing"); 
    const [search, setSearch] = useState("");
    const [difficulty, setDifficulty] = useState(""); 
    const navigate = useNavigate();

    const handleCreate = () => {
        if (activeTab === "drawing") {
            navigate("/drawing_lessons_create");
        } else if (activeTab === "problem_solving") {
            navigate("/problem_solving_lessons_create");
        } else if (activeTab === "quizzes") {
            navigate("/quizes/create");
        }
    };

    return (
        <AdminLayout>
            <div className="w-full h-full bg-[#F3E8E8]">
                {/* Outer canvas */}
                <div className="px-10 py-10 pt-20">

                    {/* Header Actions Area */}
                    <div className="flex flex-col gap-6 mb-2">
                        {/* Top Row: Create Button */}
                        <div className="flex justify-end">
                            <button
                                onClick={handleCreate}
                                className="bg-[#BD9A6B] text-white px-6 py-2 rounded-[10px] shadow-[0_6px_14px_rgba(0,0,0,0.15)] hover:brightness-95 transition font-semibold w-[280px] text-center"
                            >
                                {activeTab === "quizzes" ? "+ Add New Quiz" : "+ Add New Lesson"}
                            </button>
                        </div>

                        {/* Middle Row: Search (Left) and Difficulty (Right) */}
                        <div className="flex justify-between items-center">
                            {/* Search */}
                            <div className="relative w-[280px]">
                                <input
                                    value={search}
                                    onChange={(e) => setSearch(e.target.value)}
                                    className="w-full bg-[#D9D9D9]/50 rounded-full py-1.5 pl-5 pr-10 outline-none text-[#7A6357]"
                                    placeholder="Search here..."
                                />
                                <span className="absolute right-4 top-1/2 -translate-y-1/2 text-[#7A6357]">
                                    <IoSearchSharp />
                                </span>
                            </div>

                            {/* Difficulty Filter */}
                            <div className="flex items-center gap-3">
                                <span className="text-[#7A6357] font-semibold whitespace-nowrap">Filter By:</span>
                                <div className="relative w-[280px]">
                                    <select
                                        value={difficulty}
                                        onChange={(e) => setDifficulty(e.target.value)}
                                        className="w-full bg-[#D9D9D9]/50 rounded-full py-1.5 px-6 outline-none text-[#7A6357] appearance-none cursor-pointer pr-10"
                                    >
                                        <option value="">All Levels</option>
                                        <option value="Beginner">Beginner</option>
                                        <option value="Intermediate">Intermediate</option>
                                        <option value="Advanced">Advanced</option>
                                    </select>
                                    <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-[#7A6357]">
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Tabs */}
                    <div className="pt-8">
                        <div className="inline-flex items-end">
                            <button
                                onClick={() => setActiveTab("drawing")}
                                className={[
                                    "px-8 py-3 font-semibold rounded-t-[8px] shadow-[0_8px_14px_rgba(0,0,0,0.18)]",
                                    activeTab === "drawing"
                                        ? "bg-[#BD9A6B] text-white"
                                        : "bg-[#DFC7A7] text-white/90",
                                ].join(" ")}
                            >
                                Drawing Lessons
                            </button>

                            <button
                                onClick={() => setActiveTab("problem_solving")}
                                className={[
                                    "px-8 py-3 font-semibold rounded-t-[8px] shadow-[0_8px_14px_rgba(0,0,0,0.18)] ",
                                    activeTab === "problem_solving"
                                        ? "bg-[#BD9A6B] text-white"
                                        : "bg-[#DFC7A7] text-white/90",
                                ].join(" ")}
                            >
                                Problem Solving Lessons
                            </button>

                            <button
                                onClick={() => setActiveTab("quizzes")}
                                className={[
                                    "px-8 py-3 font-semibold rounded-t-[8px] shadow-[0_8px_14px_rgba(0,0,0,0.18)] ",
                                    activeTab === "quizzes"
                                        ? "bg-[#BD9A6B] text-white"
                                        : "bg-[#DFC7A7] text-white/90",
                                ].join(" ")}
                            >
                                Quizzes
                            </button>
                        </div>

                        {/* Content Container */}
                        <div className="border border-[#BD9A6B]/70 rounded-b-[10px] rounded-tr-[10px] mt-0 bg-transparent min-h-[500px] p-8">
                            {activeTab === "drawing" && (
                                <div className="overflow-y-auto max-h-[400px] pr-4 [&::-webkit-scrollbar]:w-[6px] [&::-webkit-scrollbar-track]:bg-transparent [&::-webkit-scrollbar-track]:rounded-[10px] [&::-webkit-scrollbar-thumb]:bg-[#BD9A6B] [&::-webkit-scrollbar-thumb]:rounded-[10px] hover:[&::-webkit-scrollbar-thumb]:bg-[#A6865A] [scrollbar-width:thin] [scrollbar-color:#BD9A6B_transparent]">
                                    <DrawingLessonList searchTerm={search} difficultyFilter={difficulty} />
                                </div>
                            )}
                            {activeTab === "problem_solving" && (
                                <div className="overflow-y-auto max-h-[500px] pr-4 [&::-webkit-scrollbar]:w-[6px] [&::-webkit-scrollbar-track]:bg-transparent [&::-webkit-scrollbar-track]:rounded-[10px] [&::-webkit-scrollbar-thumb]:bg-[#BD9A6B] [&::-webkit-scrollbar-thumb]:rounded-[10px] hover:[&::-webkit-scrollbar-thumb]:bg-[#A6865A] [scrollbar-width:thin] [scrollbar-color:#BD9A6B_transparent]">
                                    <ProblemSolvingLessonList searchTerm={search} difficultyFilter={difficulty} />
                                </div>
                            )}
                            {activeTab === "quizzes" && (
                                <div className="overflow-y-auto max-h-[500px] pr-4 [&::-webkit-scrollbar]:w-[6px] [&::-webkit-scrollbar-track]:bg-transparent [&::-webkit-scrollbar-track]:rounded-[10px] [&::-webkit-scrollbar-thumb]:bg-[#BD9A6B] [&::-webkit-scrollbar-thumb]:rounded-[10px] hover:[&::-webkit-scrollbar-thumb]:bg-[#A6865A] [scrollbar-width:thin] [scrollbar-color:#BD9A6B_transparent]">
                                    <QuizeList searchTerm={search} difficultyFilter={difficulty} />
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}
