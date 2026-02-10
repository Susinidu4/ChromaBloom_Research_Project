import React from "react";

export default function StressAnalysis() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
      <div className="md:col-span-2">
        <div className="bg-[#E8DED0] border border-[#D7C6AE] rounded-xl shadow-[0_6px_10px_rgba(0,0,0,0.08)] p-4">
          <div className="flex items-center justify-end mb-2">
            <div className="text-[10px] text-[#7A5E36] bg-[#F2E9E3] border border-[#D7C6AE] rounded-md px-2 py-1">
              2/11/2025
            </div>
          </div>
          <StressLine />
        </div>
      </div>

      {/* therapist character placeholder */}
      <div className="hidden md:flex justify-center">
        <div className="w-[160px] h-[220px] bg-[#E8DED0] border border-[#D7C6AE] rounded-xl flex items-center justify-center text-xs text-[#7A5E36]">
          Therapist Image
        </div>
      </div>
    </div>
  );
}

function StressLine() {
  const points = [35, 55, 40, 22, 42, 75, 45, 30, 30, 78];
  const w = 560;
  const h = 220;
  const pad = 24;

  const toX = (i) => pad + (i * (w - pad * 2)) / (points.length - 1);
  const toY = (v) => h - pad - (v * (h - pad * 2)) / 100;

  const d = points
    .map((v, i) => `${i === 0 ? "M" : "L"} ${toX(i)} ${toY(v)}`)
    .join(" ");

  return (
    <div className="bg-[#F2E9E3] border border-[#D7C6AE] rounded-lg p-3">
      <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-[220px]">
        {/* axis labels */}
        <text x="6" y="40" fontSize="10" fill="#7A5E36">Critical</text>
        <text x="6" y="85" fontSize="10" fill="#7A5E36">High</text>
        <text x="6" y="130" fontSize="10" fill="#7A5E36">Medium</text>
        <text x="6" y="175" fontSize="10" fill="#7A5E36">Low</text>

        <path d={d} fill="none" stroke="#B7A078" strokeWidth="3" />
        <path
          d={`${d} L ${toX(points.length - 1)} ${h - pad} L ${toX(0)} ${h - pad} Z`}
          fill="#CBB79B"
          opacity="0.35"
        />
      </svg>
    </div>
  );
}
