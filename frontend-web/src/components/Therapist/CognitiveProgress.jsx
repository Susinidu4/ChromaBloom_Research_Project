import React from "react";

export default function CognitiveProgress() {
  return (
    <div className="space-y-4">
      <Card title="Overall Progress">
        <MiniLineChart />
      </Card>

      {/* avatar row */}
      <div className="flex items-center gap-2 px-2">
        {Array.from({ length: 6 }).map((_, i) => (
          <div
            key={i}
            className="w-10 h-10 rounded-full bg-[#E8DED0] border border-[#D7C6AE]"
          />
        ))}
      </div>

      <Card title="Top Positive Factors">
        <Factors />
      </Card>
    </div>
  );
}

function Card({ title, children }) {
  return (
    <div className="bg-[#E8DED0] border border-[#D7C6AE] rounded-xl shadow-[0_6px_10px_rgba(0,0,0,0.08)] p-4">
      <div className="text-xs font-semibold text-[#8A6B3E] mb-3">{title}</div>
      {children}
    </div>
  );
}

function MiniLineChart() {
  const points = [10, 18, 22, 30, 34, 28, 26, 36, 42];
  const w = 520;
  const h = 150;
  const pad = 18;

  const toX = (i) => pad + (i * (w - pad * 2)) / (points.length - 1);
  const toY = (v) => h - pad - (v * (h - pad * 2)) / 50;

  const d = points
    .map((v, i) => `${i === 0 ? "M" : "L"} ${toX(i)} ${toY(v)}`)
    .join(" ");

  return (
    <div className="bg-[#F2E9E3] border border-[#D7C6AE] rounded-lg p-3">
      <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-[150px]">
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

function Factors() {
  const rows = [
    ["Memory Accuracy", 78],
    ["Motor Skill Accuracy", 62],
    ["Problem Solving Accuracy", 70],
    ["Completion Rate", 55],
    ["Average response time", 45],
  ];

  return (
    <div className="space-y-4">
      {rows.map(([label, v]) => (
        <div key={label} className="grid grid-cols-1 md:grid-cols-[1fr_180px] gap-3 items-center">
          <div className="h-3 bg-[#D9D9D9] rounded-full overflow-hidden border border-[#D7C6AE]">
            <div
              className="h-full bg-[#B7A078]"
              style={{ width: `${v}%` }}
            />
          </div>
          <div className="text-[10px] md:text-xs text-[#7A5E36] md:text-right">
            {label}
          </div>
        </div>
      ))}
    </div>
  );
}
