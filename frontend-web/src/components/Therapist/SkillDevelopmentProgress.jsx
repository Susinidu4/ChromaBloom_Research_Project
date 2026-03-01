import children1 from "../../assets/Therapists/children1.png";
import children2 from "../../assets/Therapists/children2.png";

export default function SkillDevelopmentProgress() {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <ChartCard title="Drawing Skill Development" rightSlot={<TinySelect label="Easy" />}>
          <MiniBarChart />
        </ChartCard>

        <ChartCard title="Problem Solving Skill Development" rightSlot={<TinySelect label="Easy" />}>
          <MiniBarChart variant />
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
        <div className="text-xs font-semibold text-[#8A6B3E]">{title}</div>
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

function MiniBarChart({ variant = false }) {
  const bars = variant
    ? [38, 22, 8, 5, 2, 0, 12, 18, 8, 6, 10, 12, 18]
    : [10, 25, 18, 8, 2, 0, 28, 30, 26, 14, 20, 24, 30];

  return (
    <div className="h-[140px] bg-[#F2E9E3] border border-[#D7C6AE] rounded-lg p-3">
      <div className="h-full flex items-end gap-2">
        {bars.map((v, i) => (
          <div
            key={i}
            className="flex-1 bg-[#CBB79B] rounded-sm border border-[#B7A078]"
            style={{ height: `${Math.max(6, v)}%` }}
          />
        ))}
      </div>
    </div>
  );
}
