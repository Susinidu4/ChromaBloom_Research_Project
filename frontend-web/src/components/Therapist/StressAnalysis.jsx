import React, { useEffect, useMemo, useState } from "react";
import therapist_stress_analysis from "../../assets/Parental_Stress_Monitoring/therapist_stress_analysis.png";
import StressAnalysisService from "../../services/Therapist/Parental_Stress_Monitoring/stressAnalysisService.js";

export default function StressAnalysis({ caregiverId }) {
  const [items, setItems] = useState([]);

  // fetch stress score history for the caregiver when component mounts or caregiverId changes
  useEffect(() => {
    if (!caregiverId) return;

    let mounted = true;

    (async () => {
      try {
        const data = await StressAnalysisService.getHistory(caregiverId, 14);
        const ordered = (data.items || []).slice().reverse(); // oldest -> newest
        if (mounted) setItems(ordered);
      } catch {
        // ignore errors (or add console.log if you want)
      }
    })();

    return () => {
      mounted = false;
    };
  }, [caregiverId]);

  // get the date label of the latest stress score (from score_date or computed_at), formatted as "dd/mm/yyyy"
  const latestDateLabel = useMemo(() => {
    if (!items.length) return "—";
    const last = items[items.length - 1];
    const d = last.score_date || last.computed_at;
    if (!d) return "—";
    const dt = new Date(d);
    return `${dt.getDate()}/${dt.getMonth() + 1}/${dt.getFullYear()}`;
  }, [items]);

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
      <div className="md:col-span-2">
        <div className="bg-[#E9DDCC] border border-[#BD9A6B] rounded-xl shadow-[0_6px_10px_rgba(0,0,0,0.08)] p-4">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-[20px] underline font-semibold text-[#BD9A6B]">
              Past 14 days stress summary
            </h2>
          </div>

          <StressLine items={items} /> {/* line chart of stress levels over time */}
        </div>
      </div>

      <div className="hidden md:flex justify-center">
        <div className="w-[160px] h-[230px] flex items-center justify-center text-xs text-[#7A5E36]">
          <img
            src={therapist_stress_analysis}
            alt="Therapist"
            className="w-full h-full object-contain"
          />
        </div>
      </div>
    </div>
  );
}
 // Line chart component to visualize stress levels over time, with y-axis labels and x-axis date labels
function StressLine({ items }) {
  const levelToRow = (level) => {
    switch ((level || "").toLowerCase()) {
      case "critical":
        return 0;
      case "high":
        return 1;
      case "medium":
        return 2;
      case "low":
      default:
        return 3;
    }
  };

  // Get date label "dd/mm" from score_date OR computed_at
  const getLabel = (it) => {
    const raw = it?.score_date || it?.computed_at;
    if (!raw) return "";
    const dt = new Date(raw);
    return `${dt.getDate()}/${dt.getMonth() + 1}`;
  };

  const points = items.map((x) => levelToRow(x.stress_level));
  const labels = items.map(getLabel);

  const w = 560;
  const h = 220;

  const leftPad = 60;
  const rightPad = 24;
  const topPad = 24;
  const bottomPad = 36;

  const yStep = (h - topPad - bottomPad) / 3;

  const toX = (i) =>
    points.length <= 1
      ? leftPad
      : leftPad + (i * (w - leftPad - rightPad)) / (points.length - 1);

  const toY = (row) => topPad + row * yStep;

  const baseY = h - bottomPad; // x-axis baseline

  const d =
    points.length === 0
      ? ""
      : points
          .map((row, i) => `${i === 0 ? "M" : "L"} ${toX(i)} ${toY(row)}`)
          .join(" ");

  // reduce x-label clutter (show every 2nd label if > 8 points)
  const showEvery = points.length > 8 ? 2 : 1;

  return (
    <div className="p-3">
      <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-[220px]">
        {/* Y-axis labels */}
        <text x="2" y={toY(0) + 4} fontSize="10" fill="#BD9A6B">
          Critical
        </text>
        <text x="2" y={toY(1) + 4} fontSize="10" fill="#BD9A6B">
          High
        </text>
        <text x="2" y={toY(2) + 4} fontSize="10" fill="#BD9A6B">
          Medium
        </text>
        <text x="2" y={toY(3) + 4} fontSize="10" fill="#BD9A6B">
          Low
        </text>

        {/* Y-Axis Title */}
        <text
          x="-5"
          y={h / 2}
          transform={`rotate(-90 -10 ${h / 2})`}
          fontSize="12"
          fill="#BD9A6B"
          textAnchor="middle"
          fontWeight="600"
        >
          Stress
        </text>
        {/* X-axis line */}
        <line
          x1={leftPad}
          y1={baseY}
          x2={w - rightPad}
          y2={baseY}
          stroke="#BD9A6B"
          strokeWidth="1"
        />

        {/* HORIZONTAL GRID LINES */}
        {[0, 1, 2, 3].map((row) => (
          <line
            key={`h-${row}`}
            x1={leftPad}
            y1={toY(row)}
            x2={w - rightPad}
            y2={toY(row)}
            stroke="#DFC7A7"
            strokeWidth="1"
            opacity="0.6"
          />
        ))}

        {/* VERTICAL GRID LINES */}
        {points.map((_, i) => (
          <line
            key={`v-${i}`}
            x1={toX(i)}
            y1={topPad}
            x2={toX(i)}
            y2={baseY}
            stroke="#DFC7A7"
            strokeWidth="1"
            opacity="0.4"
          />
        ))}

        {d && (
          <>
            {/* line */}
            <path d={d} fill="none" stroke="#BD9A6B" strokeWidth="3" />

            {/* area fill */}
            <path
              d={`${d} L ${toX(points.length - 1)} ${baseY} L ${toX(0)} ${baseY} Z`}
              fill="#DFC7A7"
              opacity="0.5"
            />

            {/* dots + x labels */}
            {points.map((row, i) => (
              <g key={i}>
                <circle cx={toX(i)} cy={toY(row)} r="4" fill="#BD9A6B" />

                {/* show x label */}
                {labels[i] && i % showEvery === 0 && (
                  <text
                    x={toX(i)}
                    y={baseY + 16}
                    fontSize="9"
                    fill="#BD9A6B"
                    textAnchor="middle"
                  >
                    {labels[i]}
                  </text>
                )}
              </g>
            ))}
          </>
        )}
        {/* X-Axis Title */}
        <text
          x={w / 2}
          y={h - 4}
          fontSize="12"
          fill="#BD9A6B"
          textAnchor="middle"
          fontWeight="600"
        >
          Date
        </text>
      </svg>
    </div>
  );
}
