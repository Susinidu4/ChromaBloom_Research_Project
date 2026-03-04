import React, { useEffect, useState } from "react";
import children1 from "../../assets/Therapists/children1.png";
import children2 from "../../assets/Therapists/children2.png";
import { getChildByIdService } from "../../services/childService";
import { getCompleteDrawingLessonsByUserId } from "../../services/Therapist/completeDrawingLessonService";
import { getCompleteProblemSolvingSessionByUserId } from "../../services/Therapist/completeProblemSolvingSessionService";

export default function SkillDevelopmentProgress({ childId }) {
  const [allDrawingData, setAllDrawingData] = useState([]);
  const [drawingDifficulty, setDrawingDifficulty] = useState("All");
  const [problemSolvingProgress, setProblemSolvingProgress] = useState([]);
  const [loadingDrawing, setLoadingDrawing] = useState(true);
  const [loadingProblemSolving, setLoadingProblemSolving] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      if (!childId) return;

      try {
        setLoadingDrawing(true);
        setLoadingProblemSolving(true);

        // 1. Fetch child info to get caregiver id for drawing lessons
        const childInfo = await getChildByIdService(childId);

        // Fetch Drawing Progress (via caregiver)
        if (childInfo && childInfo.caregiver && childInfo.caregiver._id) {
          const drawingResponse = await getCompleteDrawingLessonsByUserId(childInfo.caregiver._id);

          if (drawingResponse && drawingResponse.success) {
            setAllDrawingData(drawingResponse.data);
          }
        }

        // Fetch Problem Solving Progress (directly via childId)
        const problemSolvingResponse = await getCompleteProblemSolvingSessionByUserId(childId);
        console.log(problemSolvingResponse);
        if (problemSolvingResponse && problemSolvingResponse.data) {
          // Sort by createdAt ascending to show progress over time
          const sortedData = problemSolvingResponse.data.sort(
            (a, b) => new Date(a.createdAt) - new Date(b.createdAt)
          );
          // Extract correctness scores and convert to percentage (0-100)
          const scores = sortedData.map(item => item.correctness_score * 100);
          setProblemSolvingProgress(scores);
        }

      } catch (error) {
        console.error("Error fetching skill development data:", error);
      } finally {
        setLoadingDrawing(false);
        setLoadingProblemSolving(false);
      }
    };

    fetchData();
  }, [childId]);

  const drawingRates = allDrawingData
    .filter(item => drawingDifficulty === "All" || item.lesson_id?.difficulty_level === drawingDifficulty)
    .sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt))
    .map(item => item.correctness_rate);

  const difficultyOptions = [
    { label: "All", value: "All" },
    { label: "Easy", value: "Beginner" },
    { label: "Medium", value: "Intermediate" },
    { label: "Hard", value: "Advanced" },
  ];

  return (
    <div className="space-y-6 md:space-y-10 py-4 max-w-7xl mx-auto">
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <ChartCard
          title="Drawing Skill Development"
          rightSlot={
            <TinySelect
              value={drawingDifficulty}
              onChange={setDrawingDifficulty}
              options={difficultyOptions}
            />
          }
        >
          {loadingDrawing ? (
            <div className="h-[280px] flex items-center justify-center text-[#A68A64] font-medium">
              Loading...
            </div>
          ) : (
            <SkillBarChart data={drawingRates} />
          )}
        </ChartCard>

        <ChartCard title="Problem Solving Progress" rightSlot={<TinySelect label="Easy" disabled />}>
          {loadingProblemSolving ? (
            <div className="h-[280px] flex items-center justify-center text-[#A68A64] font-medium">
              Loading...
            </div>
          ) : (
            <SkillBarChart data={problemSolvingProgress} variant />
          )}
        </ChartCard>
      </div>

      {/* Illustration row */}
      <div className="hidden md:flex items-center justify-center mt-12 gap-8 grayscale-25 opacity-90">
        <img src={children2} alt="children2" className="h-[180px] object-contain transition-transform hover:scale-105 duration-500" />
        <img src={children1} alt="children1" className="h-[200px] object-contain transition-transform hover:scale-105 duration-500" />
      </div>
    </div>
  );
}

function ChartCard({ title, rightSlot, children }) {
  return (
    <div className="bg-[#E9DBC7] rounded-[32px] shadow-[inset_0_2px_4px_rgba(255,255,255,0.4),0_12px_24px_rgba(138,107,62,0.15)] p-6 md:p-10 flex flex-col h-full border border-[#D7C6AE]/30 relative overflow-hidden">
      {/* Decorative grain/texture could be added here if needed */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-10 gap-4">
        <h2 className="text-2xl md:text-[20px] font-bold text-[#A68A64] border-b-[3px] border-[#A68A64] pb-1 leading-tight tracking-tight">
          {title}
        </h2>
        <div className="shrink-0">
          {rightSlot}
        </div>
      </div>
      <div className="flex-1 min-h-[300px]">
        {children}
      </div>
    </div>
  );
}

function TinySelect({ value, onChange, options, label, disabled }) {
  if (disabled) {
    return (
      <div className="flex items-center gap-3 text-sm font-semibold text-[#A68A64]/50 bg-[#E9DBC7] border-2 border-[#D7C6AE]/30 rounded-2xl px-5 py-2.5 shadow-none cursor-default">
        <span className="tracking-tight">{label}</span>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="shrink-0 opacity-30">
          <path d="M6 9l6 6 6-6" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </div>
    );
  }

  return (
    <div className="relative group">
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="appearance-none flex items-center gap-3 text-sm font-semibold text-[#A68A64] bg-[#E9DBC7] border-2 border-[#D7C6AE]/60 rounded-2xl px-5 py-2.5 pr-12 shadow-[0_4px_8px_rgba(138,107,62,0.1)] cursor-pointer hover:bg-[#F2EADA] transition-all outline-none active:scale-95 font-sans"
      >
        {options.map((opt) => (
          <option key={opt.value} value={opt.value} className="bg-[#F2EADA] text-[#A68A64]">
            {opt.label}
          </option>
        ))}
      </select>
      <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-[#A68A64] transition-transform group-hover:translate-y-[-40%]">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="shrink-0">
          <path
            d="M6 9l6 6 6-6"
            stroke="currentColor"
            strokeWidth="3"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>
    </div>
  );
}

function SkillBarChart({ data, variant = false }) {
  // If no data is provided, show 14 zero-value bars to maintain the layout like the image
  const bars = data && data.length > 0 ? data : Array(14).fill(0);

  const yLabels = [100, 80, 60, 40, 20, 0];
  const xLabels = Array.from({ length: bars.length }, (_, i) => i);

  return (
    <div className="relative font-sans text-[#A68A64] h-[320px] mt-4 select-none">
      <div className="flex h-full gap-2">
        {/* Y Axis Label (Vertical) */}
        <div className="flex items-center justify-center w-8">
          <span className="transform -rotate-90 origin-center text-[13px] font-bold tracking-[0.2em] whitespace-nowrap opacity-70 uppercase">
            Score
          </span>
        </div>

        <div className="flex-1 flex flex-col h-full">
          <div className="relative flex-1 flex">
            {/* Y axis numbers */}
            <div className="flex flex-col justify-between py-[1px] pr-4 text-xs font-bold opacity-70 min-w-[30px]">
              {yLabels.map(label => (
                <span key={label} className="h-0 flex items-center justify-end">{label}</span>
              ))}
            </div>

            {/* Grid and Bars Area */}
            <div className="relative flex-1 h-full border-l-[2px] border-b-[2px] border-[#D7C6AE]">
              {/* Horizontal Grid Lines */}
              <div className="absolute inset-0 flex flex-col justify-between pointer-events-none">
                {yLabels.map((label, idx) => (
                  <div key={label} className={`w-full border-t-[1px] border-[#D7C6AE]/40 h-0 ${idx === yLabels.length - 1 ? 'hidden' : ''}`} />
                ))}
              </div>

              {/* Vertical Grid Lines & Bars (Integrated for perfect alignment) */}
              <div className="absolute inset-0 flex pointer-events-none">
                {bars.map((v, i) => (
                  <div key={i} className="flex-1 border-r-[1px] border-[#D7C6AE]/40 h-full relative flex items-end justify-center">
                    <div
                      className="w-[70%] bg-[#B69368] rounded-sm transition-all duration-500 hover:brightness-90 group relative pointer-events-auto cursor-pointer"
                      style={{ height: `${Math.max(2, Math.min(v, 100))}%` }}
                    >
                      {/* Tooltip */}
                      <div className="absolute -top-12 left-1/2 -translate-x-1/2 bg-[#A68A64] text-white text-[11px] font-bold px-2.5 py-1.5 rounded-xl opacity-0 group-hover:opacity-100 transition-all transform scale-90 group-hover:scale-100 whitespace-nowrap z-20 shadow-xl pointer-events-none after:content-[''] after:absolute after:top-full after:left-1/2 after:-translate-x-1/2 after:border-8 after:border-transparent after:border-t-[#A68A64]">
                        {v.toFixed(1)}%
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* X Axis labels */}
          <div className="flex flex-col items-center mt-3 ml-[46px]">
            <div className="w-full flex">
              {xLabels.map(i => (
                <div key={i} className="flex-1 flex justify-center text-xs font-bold opacity-70">
                  <span className="translate-x-[-0.5px]">{i}</span>
                </div>
              ))}
            </div>
            <span className="text-[13px] font-bold tracking-[0.3em] uppercase mt-4 mb-2 opacity-70">
              Lessons
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}


