import React, { useState } from "react";
import AdminLayout from "../admin/Admin_Management/AdminLayout";
import { IoSearchSharp } from "react-icons/io5";
import DrawingLessonList from "./Drawing_Lessons/DrawingLessonList";
import ProblemSolvingLessonList from "./Problem_Solving_Lessons/ProblemSolvingLessonList";
import QuizeList from "./Quize/QuizeList";

export default function Wellness_Module() {
    const [activeTab, setActiveTab] = useState("drawing"); // drawing | problem_solving | quizzes
    const [search, setSearch] = useState("");

    return (
        <AdminLayout>
            <div className="w-full h-full bg-[#F3E8E8]">
                {/* Outer canvas */}
                <div className="px-10 py-10 pt-20">

                    {/* Search top-right */}
                    <div className="absolute right-10 top-25">
                        <div className="relative w-[280px] max-w-[70vw]">
                            <input
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="w-full bg-[#D9D9D9]/50 rounded-full py-1.5 pl-5 pr-10 outline-none text-[#7A6357]"
                                placeholder=""
                            />
                            <span className="absolute right-4 top-1/2 -translate-y-1/2 text-[#7A6357]">
                                <IoSearchSharp />
                            </span>
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
                                <div>
                                    <DrawingLessonList />
                                </div>
                            )}
                            {activeTab === "problem_solving" && (
                                <div>
                                    <ProblemSolvingLessonList searchTerm={search} />
                                </div>
                            )}
                            {activeTab === "quizzes" && (
                                <div>
                                    <QuizeList searchTerm={search} />
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}