import React, { useEffect, useState } from "react";
import children1 from "../../assets/Therapists/children1.png";
import children2 from "../../assets/Therapists/children2.png";
import { getChildByIdService } from "../../services/childService";
import { getCompleteDrawingLessonsByUserId } from "../../services/Therapist/completeDrawingLessonService";
import { getCompleteProblemSolvingSessionByUserId } from "../../services/Therapist/completeProblemSolvingSessionService";

export default function SkillDevelopmentProgress({ childId }) {
  const [drawingProgress, setDrawingProgress] = useState([]);
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
            // Sort by createdAt ascending to show progress over time
            const sortedData = drawingResponse.data.sort(
              (a, b) => new Date(a.createdAt) - new Date(b.createdAt)
            );
            // Extract correctness rates
            const rates = sortedData.map(item => item.correctness_rate);
            setDrawingProgress(rates);
          }
        }

        // Fetch Problem Solving Progress (directly via childId)
        const problemSolvingResponse = await getCompleteProblemSolvingSessionByUserId(childId);

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

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <ChartCard title="Drawing Skill Development" rightSlot={<TinySelect label="Easy" />}>
          {loadingDrawing ? (
            <div className="h-[140px] flex items-center justify-center text-[#8A6B3E] text-xs">
              Loading...
            </div>
          ) : drawingProgress.length > 0 ? (
            <MiniBarChart data={drawingProgress} />
          ) : (
            <div className="h-[140px] flex items-center justify-center text-[#8A6B3E] text-xs">
              No data available
            </div>
          )}
        </ChartCard>

        <ChartCard title="Problem Solving Skill Development" rightSlot={<TinySelect label="Easy" />}>
          {loadingProblemSolving ? (
            <div className="h-[140px] flex items-center justify-center text-[#8A6B3E] text-xs">
              Loading...
            </div>
          ) : problemSolvingProgress.length > 0 ? (
            <MiniBarChart data={problemSolvingProgress} variant />
          ) : (
            <div className="h-[140px] flex items-center justify-center text-[#8A6B3E] text-xs">
              No data available
            </div>
          )}
        </ChartCard>
      </div>

      {/* Illustration row */}
      <div className="hidden md:flex items-center justify-center mt-8">
        <img src={children2} alt="children2" className="h-[150px] object-contain" />
        <img src={children1} alt="children1" className="h-[170px] object-contain" />
      </div>
    </div>
  );
}

function ChartCard({ title, rightSlot, children }) {
  return (
    <div className="bg-[#E8DED0] border border-[#D7C6AE] rounded-xl shadow-[0_6px_10px_rgba(0,0,0,0.08)] p-4">
      <div className="flex items-center justify-between mb-3">
        <div className="text-xs font-semibold text-[#8A6B3E] uppercase tracking-wider">{title}</div>
        {rightSlot}
      </div>
      {children}
    </div>
  );
}

function TinySelect({ label }) {
  return (
    <div className="flex items-center gap-2 text-[10px] text-[#7A5E36] bg-[#F2E9E3] border border-[#D7C6AE] rounded-md px-2 py-1">
      <span>{label}</span>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
        <path
          d="M6 9l6 6 6-6"
          stroke="#8A6B3E"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    </div>
  );
}

function MiniBarChart({ data, variant = false }) {
  // Use provided data or fallback to defaults
  const bars = data || (variant
    ? [38, 22, 8, 5, 2, 0, 12, 18, 8, 6, 10, 12, 18]
    : [10, 25, 18, 8, 2, 0, 28, 30, 26, 14, 20, 24, 30]);

  return (
    <div className="h-[140px] bg-[#F2E9E3] border border-[#D7C6AE] rounded-lg p-3">
      <div className="h-full flex items-end gap-2 overflow-x-auto custom-scrollbar">
        {bars.map((v, i) => (
          <div
            key={i}
            className="min-w-[12px] flex-1 bg-[#CBB79B] rounded-sm border border-[#B7A078] transition-all hover:bg-[#B7A078]"
            style={{ height: `${Math.max(6, Math.min(v, 100))}%` }}
            title={`${v.toFixed(1)}%`}
          />
        ))}
      </div>
      <style dangerouslySetInnerHTML={{
        __html: `
        .custom-scrollbar::-webkit-scrollbar {
          height: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: #F2E9E3;
          border-radius: 10px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background: #D7C6AE;
          border-radius: 10px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background: #8A6B3E;
        }
      `}} />
    </div>
  );
}