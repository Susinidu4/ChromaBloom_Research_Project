import React, { useEffect, useMemo, useRef, useState } from "react";
import { getRoutineDashboardService } from "../../services/Therapist/Interactive_Visual_Task_Scheduler/routineDashboardService.js";

// Optional image
import therapist_routine_progress from "../../assets/Interactive_Visual_Task_Scheduler/therapist_routine_progress.png";

export default function RoutineProgress({ caregiverId, childId }) {
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState("");

  const [cycles, setCycles] = useState([]);
  const [selectedPlanId, setSelectedPlanId] = useState("");
  const [selectedLabel, setSelectedLabel] = useState("Select Cycle");

  // chart data
  const [completedSteps, setCompletedSteps] = useState(0);
  const [skippedSteps, setSkippedSteps] = useState(0);
  const [dailyProgress, setDailyProgress] = useState([]);
  const [overallProgressRaw, setOverallProgressRaw] = useState([]);

  const canLoad = Boolean(caregiverId);

  const diffToNumber = (diff) => {
    const d = String(diff || "")
      .toLowerCase()
      .trim();
    if (d === "easy") return 1;
    if (d === "medium") return 2;
    if (d === "hard") return 3;
    return 0;
  };

  const lineValues = useMemo(
    () => overallProgressRaw.map((p) => diffToNumber(p?.difficulty)),
    [overallProgressRaw],
  );

  // 1) normalizedDaily FIRST
  const normalizedDaily = useMemo(() => {
    const arr = Array.from({ length: 14 }, (_, i) => ({
      dayIndex: i + 1,
      completionPercent: 0,
    }));

    for (const d of dailyProgress || []) {
      const idx = Number(d?.dayIndex ?? 0) - 1;
      if (idx >= 0 && idx < 14) {
        arr[idx] = {
          ...arr[idx],
          ...d,
          completionPercent: Number(d?.completionPercent ?? 0),
        };
      }
    }
    return arr;
  }, [dailyProgress]);

  // 2) THEN barValues uses it
  const barValues = useMemo(
    () => normalizedDaily.map((d) => Number(d.completionPercent ?? 0)),
    [normalizedDaily],
  );

  const barIndexLabels = useMemo(
    () => Array.from({ length: 14 }, (_, i) => String(i + 1)),
    [],
  );

  const planLabels = useMemo(
    () => overallProgressRaw.map((p) => String(p?.version ?? "")),
    [overallProgressRaw],
  );

  const loadDashboard = async (planId) => {
    if (!canLoad) return;

    try {
      setLoading(true);
      setErr("");

      const res = await getRoutineDashboardService({
        caregiverId,
        childId,
        planId,
      });

      if (!res?.success) {
        throw new Error(res?.message || "Failed to load dashboard");
      }

      const data = res?.data || {};

      const apiCycles = Array.isArray(data.cycles) ? data.cycles : [];
      setCycles(apiCycles);

      const selected = data.selectedCycle || {};
      const planMongoId = String(selected.planMongoId || "");

      const matched = apiCycles.find(
        (c) => String(c.planMongoId) === planMongoId,
      );
      const labelFromCycles = matched?.label ? String(matched.label) : "";

      const start = String(selected.cycleStart || "").split("T")[0];
      const end = String(selected.cycleEnd || "").split("T")[0];
      const fallbackLabel = start && end ? `${start} - ${end}` : "Select Cycle";

      setSelectedPlanId(planMongoId);
      setSelectedLabel(labelFromCycles || fallbackLabel);

      const step = data.stepAnalysis || {};
      setCompletedSteps(Number(step.completedStepsTotal ?? 0));
      setSkippedSteps(Number(step.skippedStepsTotal ?? 0));

      const daily = Array.isArray(data.dailyProgress) ? data.dailyProgress : [];
      setDailyProgress(daily);

      const overall = Array.isArray(data.overallProgress)
        ? data.overallProgress
        : [];
      setOverallProgressRaw(overall);
    } catch (e) {
      setErr(e?.message || "Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboard(undefined);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [caregiverId, childId]);

  const onCycleChange = async (e) => {
    const planId = e.target.value;
    setSelectedPlanId(planId);
    await loadDashboard(planId);
  };

  return (
    <div className="space-y-6">
      {/* Header row */}
      <div className="flex items-center justify-between">
        <div className="text-[28px] font-extrabold text-[#BD9A6B]"></div>

        {/* ONE dropdown for ALL */}
        <select
          value={selectedPlanId}
          onChange={onCycleChange}
          className="text-[12px] text-[#BD9A6B] bg-[#E9DDCC] border border-[#BD9A6B]
                   rounded-md px-3 py-2 outline-none shadow-sm"
        >
          {cycles.length === 0 ? (
            <option value="">
              {loading ? "Loading cycles..." : "No cycles"}
            </option>
          ) : (
            cycles.map((c) => (
              <option key={String(c.planMongoId)} value={String(c.planMongoId)}>
                {String(c.label || "")}
              </option>
            ))
          )}
        </select>
      </div>

      {err ? (
        <div className="text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg p-3">
          {err}
        </div>
      ) : null}

      {/* Top cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card
          title="Routine Analysis"
        >
          <div className="flex gap-10 items-center">
            {/* ✅ Solid PIE like your design */}
            <PieSliceChart completed={completedSteps} skipped={skippedSteps} />

            <div className="text-[18px] text-[#BD9A6B] space-y-3">
              <LegendItem label="Completed Steps" boxColor="bg-[#F7EAD7]" />
              <LegendItem label="Skipped Steps" boxColor="bg-[#DFC7A7]" />
            </div>
          </div>
        </Card>

        <Card
          title="Routine Progress"
          subtitle="* 14 days cycle wise"
        >
          {/* ✅ Grid + y-axis like design */}
          <MiniBarChartWithGrid
            bars={barValues}
            labels={barIndexLabels}
            loading={loading}
          />
        </Card>
      </div>

      {/* Bottom */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="md:col-span-2" title="Overall Progress">
          <MiniLineChart
            values={lineValues}
            labels={planLabels}
            loading={loading}
          />
        </Card>

        <div className="hidden md:flex items-end justify-center">
          {/* <img src={kids3} alt="kids" className="w-[320px] h-auto" /> */}
          <div className="w-[320px] h-[240px] flex items-center justify-center text-sm text-[#BD9A6B]">
            <img
              src={therapist_routine_progress}
              alt="Routine Progress Illustration"
              className="w-full h-full object-contain"
            />
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------- UI pieces ---------- */

function Card({ title, subtitle, rightSlot, className = "", children }) {
  return (
    <div
      className={`bg-[#E9DDCC] border border-[#BD9A6B] rounded-xl
                  shadow-[0_6px_10px_rgba(0,0,0,0.10)]
                  p-6 ${className}`}
    >
      <div className="flex items-start justify-between gap-3 mb-4">
        <div>
          <div className="text-[22px] font-extrabold text-[#BD9A6B] underline underline-offset-4 decoration-[#BD9A6B]/50">
            {title}
          </div>
          {subtitle ? (
            <div className="text-[12px] mt-1 text-[#BD9A6B] opacity-80">
              {subtitle}
            </div>
          ) : null}
        </div>
        {rightSlot}
      </div>
      {children}
    </div>
  );
}

function DatePill({ label }) {
  return (
    <div className="text-[11px] text-[#BD9A6B] bg-[#F2E9E3] border border-[#BD9A6B] rounded-md px-3 py-2 whitespace-nowrap shadow-sm">
      {label}
    </div>
  );
}

function LegendItem({ label, boxColor = "bg-[#CBB79B]" }) {
  return (
    <div className="flex items-center gap-3">
      <span
        className={`w-5 h-5 rounded-md ${boxColor} border border-[#BD9A6B]`}
      />
      <span className="font-medium">{label}</span>
    </div>
  );
}

/* ---------- PIE slice chart (matches design) ---------- */

function PieSliceChart({ completed = 0, skipped = 0 }) {
  const total = Math.max(1, completed + skipped);
  const completedPct = completed / total;

  // wedge angle for skipped section
  const startAngle = -90;
  const endAngle = startAngle + completedPct * 360;

  const cx = 70;
  const cy = 70;
  const r = 55;

  const polar = (angleDeg) => {
    const rad = (Math.PI / 180) * angleDeg;
    return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
  };

  const p1 = polar(startAngle);
  const p2 = polar(endAngle);
  const largeArc = completedPct > 0.5 ? 1 : 0;

  // completed wedge path
  const wedge = `
    M ${cx} ${cy}
    L ${p1.x} ${p1.y}
    A ${r} ${r} 0 ${largeArc} 1 ${p2.x} ${p2.y}
    Z
  `;

  return (
    <svg width="180" height="180" viewBox="0 0 140 140">
      {/* base circle */}
      <circle
        cx={cx}
        cy={cy}
        r={r}
        fill="#DFC7A7"
        opacity="0.55"
        stroke="#BD9A6B"
        strokeWidth="1.2"
      />

      {/* skipped wedge (lighter) */}
      <path d={wedge} fill="#F7EAD7" stroke="#BD9A6B" strokeWidth="1.2" />

      {/* values */}
      <text x="48" y="75" fontSize="16" fill="#ffffff" fontWeight="800">
        {completed}
      </text>
      <text x="90" y="85" fontSize="16" fill="#B0896E" fontWeight="800">
        {skipped}
      </text>
    </svg>
  );
}

/* ---------- Bar chart with grid & y-axis ticks ---------- */

function MiniBarChartWithGrid({ bars = [], labels = [], loading }) {
  const safeBars = bars.length ? bars : Array.from({ length: 14 }, () => 0);

  return (
    <div className="p-4">
      <div className="relative h-[190px]">
        {/* grid lines */}
        {[0, 20, 40, 60, 80, 100].map((y) => (
          <div
            key={y}
            className="absolute left-10 right-2 border-t border-[#DFC7A7]"
            style={{ bottom: `${(y / 100) * 150 + 26}px` }}
          />
        ))}

        {/* y-axis labels */}
        <div className="absolute left-0 bottom-[26px] top-[10px] w-10 flex flex-col justify-between text-[11px] text-[#BD9A6B]">
          <span>100</span>
          <span>80</span>
          <span>60</span>
          <span>40</span>
          <span>20</span>
          <span>0</span>
        </div>

        {/* bars */}
        <div className="absolute left-10 right-2 bottom-[26px] h-[150px] flex items-end gap-3">
          {safeBars.map((v, i) => (
            <div
              key={i}
              className="flex-1 h-full flex flex-col justify-end items-center"
            >
              <div
                className="w-full bg-[#BD9A6B]"
                style={{ height: `${Math.max(2, Math.min(100, v))}%` }}
                title={`Day ${i + 1}: ${v}%`}
              />
            </div>
          ))}
        </div>

        {/* x labels */}
        <div className="absolute left-10 right-2 bottom-0 h-[26px] flex items-end gap-3">
          {safeBars.map((_, i) => (
            <div
              key={i}
              className="flex-1 text-center text-[11px] text-[#BD9A6B]"
            >
              {labels[i] ?? i}
            </div>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="mt-2 text-[11px] text-[#BD9A6B] opacity-70">
          Loading…
        </div>
      ) : null}
    </div>
  );
}

/* ---------- Line chart (keep yours but slightly softer fill) ---------- */

function MiniLineChart({ values = [], labels = [], loading }) {
  const safe = values.length ? values : [3, 2, 3, 2, 1, 2, 1, 3, 3, 1];

  const w = 720;
  const h = 220;
  const padL = 85;
  const pad = 22;

  const minY = 0.5;
  const maxY = 3.5;

  const leftW = 90; // fixed y-label column width
  const plotW = safe.length * 70; // scroll width (70px per plan)
  const plotH = 220;
  
  const toX = (i) => padL + (i * (w - padL - pad)) / (safe.length - 1);
  const toY = (v) => {
    const t = (v - minY) / (maxY - minY);
    return h - pad - t * (h - pad * 2);
  };

  const d = safe
    .map((v, i) => `${i === 0 ? "M" : "L"} ${toX(i)} ${toY(v)}`)
    .join(" ");

  const scrollRef = useRef(null);

  useEffect(() => {
    // when chart data changes, jump to the latest (right-most side)
    if (scrollRef.current) {
      scrollRef.current.scrollLeft = scrollRef.current.scrollWidth;
    }
  }, [safe.length]);

  return (
    <div className="p-2 overflow-visible">
      <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-[220px]">
        {/* x-axis tick labels (version) */}
        {safe.map((_, i) => (
          <text
            key={`xlab-${i}`}
            x={toX(i)}
            y={h - 8}
            textAnchor="middle"
            fontSize="11"
            fill="#BD9A6B"
          >
            {labels?.[i] ?? i + 1}
          </text>
        ))}

        {[1, 2, 3].map((y) => (
          <line
            key={`hy-${y}`}
            x1={padL}
            x2={w - pad}
            y1={toY(y)}
            y2={toY(y)}
            stroke="#DFC7A7"
            strokeWidth="1"
            opacity="0.7"
          />
        ))}

        <path
          d={`${d} L ${toX(safe.length - 1)} ${h - pad} L ${toX(0)} ${h - pad} Z`}
          fill="#CBB79B"
          opacity="0.25"
        />

        <path d={d} fill="none" stroke="#B7A078" strokeWidth="3" />

        <text x="25" y={toY(3) + 4} fontSize="12" fill="#BD9A6B">
          Hard
        </text>
        <text x="25" y={toY(2) + 4} fontSize="12" fill="#BD9A6B">
          Medium
        </text>
        <text x="25" y={toY(1) + 4} fontSize="12" fill="#BD9A6B">
          Easy
        </text>

        <text
          x={(padL + (w - pad)) / 2}
          y={h - 2}
          textAnchor="middle"
          fontSize="12"
          fill="#BD9A6B"
        >
          Plan no
        </text>

        <text
          x="16"
          y={h / 2}
          textAnchor="middle"
          fontSize="13"
          fill="#BD9A6B"
          transform={`rotate(-90 10 ${h / 2})`}
        >
          Complexity
        </text>
      </svg>
    </div>
  );
}
