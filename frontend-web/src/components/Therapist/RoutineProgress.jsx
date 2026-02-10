import React from "react";
// import kids3 from "../../assets/kids3.png"; // optional image (if you have)

export default function RoutineProgress() {
  return (
    <div className="space-y-4">
      {/* Top cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card title="Routine Analysis" rightSlot={<DatePill label="21/01/2025 - 11/01/2025" />}>
          <div className="flex gap-6 items-center">
            <Donut />
            <div className="text-xs text-[#7A5E36] space-y-2">
              <LegendItem label="Completed Steps" />
              <LegendItem label="Skipped Steps" />
            </div>
          </div>
        </Card>

        <Card title="Routine Progress" rightSlot={<DatePill label="21/01/2025 - 11/01/2025" />}>
          <MiniBarChart />
        </Card>
      </div>

      {/* Bottom card + illustration */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="md:col-span-2" title="Overall Progress">
          <MiniLineChart />
        </Card>

        <div className="hidden md:flex items-end justify-center">
          {/* Replace this with your own image */}
          <div className="w-[220px] h-[180px] bg-[#E8DED0] border border-[#D7C6AE] rounded-xl flex items-center justify-center text-xs text-[#7A5E36]">
            Illustration
          </div>
        </div>
      </div>
    </div>
  );
}

/* UI pieces */

function Card({ title, rightSlot, className = "", children }) {
  return (
    <div
      className={`bg-[#E8DED0] border border-[#D7C6AE] rounded-xl
                  shadow-[0_6px_10px_rgba(0,0,0,0.08)]
                  p-4 ${className}`}
    >
      <div className="flex items-center justify-between mb-3">
        <div className="text-xs font-semibold text-[#8A6B3E]">{title}</div>
        {rightSlot}
      </div>
      {children}
    </div>
  );
}

function DatePill({ label }) {
  return (
    <div className="text-[10px] text-[#7A5E36] bg-[#F2E9E3] border border-[#D7C6AE] rounded-md px-2 py-1">
      {label}
    </div>
  );
}

function LegendItem({ label }) {
  return (
    <div className="flex items-center gap-2">
      <span className="w-3 h-3 rounded-full bg-[#CBB79B] border border-[#B7A078]" />
      <span>{label}</span>
    </div>
  );
}

/* Chart placeholders (simple SVG to look like your UI) */

function Donut() {
  return (
    <svg width="110" height="110" viewBox="0 0 120 120">
      <circle cx="60" cy="60" r="42" fill="#F2E9E3" stroke="#D7C6AE" strokeWidth="2" />
      <path
        d="M60 18 A42 42 0 1 1 24 90"
        fill="none"
        stroke="#CBB79B"
        strokeWidth="18"
        strokeLinecap="round"
      />
      <path
        d="M24 90 A42 42 0 0 1 60 18"
        fill="none"
        stroke="#E0D2BC"
        strokeWidth="18"
        strokeLinecap="round"
      />
      <circle cx="60" cy="60" r="24" fill="#E8DED0" />
      <text x="40" y="68" fontSize="12" fill="#7A5E36" fontWeight="700">
        25
      </text>
      <text x="66" y="68" fontSize="12" fill="#7A5E36" fontWeight="700">
        10
      </text>
    </svg>
  );
}

function MiniBarChart() {
  const bars = [12, 35, 28, 6, 2, 0, 26, 32, 28, 14, 22, 30, 34];
  return (
    <div className="h-[140px] bg-[#F2E9E3] border border-[#D7C6AE] rounded-lg p-3">
      <div className="h-full flex items-end gap-2">
        {bars.map((v, i) => (
          <div
            key={i}
            className="flex-1 bg-[#CBB79B] rounded-sm border border-[#B7A078]"
            style={{ height: `${Math.max(6, v)}%` }}
            title={`Day ${i + 1}: ${v}`}
          />
        ))}
      </div>
    </div>
  );
}

function MiniLineChart() {
  const points = [20, 40, 30, 55, 32, 42, 25, 38, 44, 35, 50];
  const w = 420;
  const h = 140;
  const pad = 18;

  const toX = (i) => pad + (i * (w - pad * 2)) / (points.length - 1);
  const toY = (v) => h - pad - (v * (h - pad * 2)) / 60;

  const d = points
    .map((v, i) => `${i === 0 ? "M" : "L"} ${toX(i)} ${toY(v)}`)
    .join(" ");

  return (
    <div className="bg-[#F2E9E3] border border-[#D7C6AE] rounded-lg p-3 overflow-hidden">
      <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-[140px]">
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
