import React, { useEffect, useState } from "react";
import { getProgressByUserId } from "../../services/Therapist/cognitiveProgressService";

export default function CognitiveProgress({ childId }) {
  const [progressData, setProgressData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      if (!childId) return;
      try {
        setLoading(true);
        const response = await getProgressByUserId(childId);
        if (response.success) {
          // Sort by date ascending for the chart
          const sortedData = response.data.sort(
            (a, b) => new Date(a.createdAt) - new Date(b.createdAt)
          );
          setProgressData(sortedData);
        }
      } catch (error) {
        console.error("Error fetching cognitive progress:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [childId]);

  return (
    <div className="space-y-4">
      <Card title="Overall Progress">
        {loading ? (
          <div className="h-[250px] flex items-center justify-center text-[#8A6B3E] text-xs">
            Loading progress data...
          </div>
        ) : progressData.length > 0 ? (
          <MiniLineChart data={progressData} />
        ) : (
          <div className="h-[250px] flex items-center justify-center text-[#8A6B3E] text-xs">
            No progress data available
          </div>
        )}
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
    <div className="bg-[#EADBC8] border border-[#D7C6AE] rounded-xl shadow-[0_6px_10px_rgba(0,0,0,0.08)] p-6">
      <div className="mb-8">
        <span className="text-2xl font-bold text-[#8A6B3E] border-b-4 border-[#8A6B3E] pb-1 uppercase tracking-wider">
          {title}
        </span>
      </div>
      {children}
    </div>
  );
}

function MiniLineChart({ data }) {
  const [hoveredPoint, setHoveredPoint] = useState(null);

  const points = data.map((item) => item.progress_prediction);
  const labels = data.map((item) => {
    const date = new Date(item.createdAt);
    return `${date.getDate()}/${date.getMonth() + 1}`;
  });

  const w = 600;
  const h = 320;
  const padLeft = 110;
  const padRight = 40;
  const padTop = 40;
  const padBottom = 100;

  const actualMin = Math.min(...points);
  const actualMax = Math.max(...points);
  const rangeBuffer = (actualMax - actualMin) * 0.15 || 0.1;
  const minVal = actualMin - rangeBuffer;
  const maxVal = actualMax + rangeBuffer;
  const range = maxVal - minVal;

  const toX = (i) => padLeft + (i * (w - padLeft - padRight)) / Math.max(points.length - 1, 1);
  const toY = (v) => h - padBottom - ((v - minVal) * (h - padBottom - padTop)) / range;

  const d = points
    .map((v, i) => `${i === 0 ? "M" : "L"} ${toX(i)} ${toY(v)}`)
    .join(" ");

  // Create 6 well-spaced ticks
  const yTicks = Array.from({ length: 6 }, (_, i) => minVal + (i * range) / 5);

  // Decide which X labels to show to prevent overlap
  const step = Math.max(1, Math.ceil(labels.length / 10));
  const xIndices = labels.map((_, i) => i).filter(i => i % step === 0 || i === labels.length - 1);

  return (
    <div className="space-y-4">
      <div className="bg-[#F2E9E3] border border-[#D7C6AE] rounded-lg p-3 overflow-x-auto custom-scrollbar relative">
        <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-auto block overflow-visible">
          {/* Y-Axis Label */}
          <text
            transform={`translate(20, ${(h - padBottom + padTop) / 2}) rotate(-90)`}
            textAnchor="middle"
            className="fill-[#8A6B3E] text-sm font-bold opacity-80"
          >
            Improvment
          </text>

          {/* X-Axis Labels (Dates) */}
          {xIndices.map((i) => {
            const x = toX(i);
            return (
              <React.Fragment key={`v-${i}`}>
                <line
                  x1={x}
                  y1={padTop}
                  x2={x}
                  y2={h - padBottom}
                  stroke="#D7C6AE"
                  strokeWidth="0.5"
                  opacity="0.3"
                />
                <line
                  x1={x}
                  y1={h - padBottom}
                  x2={x}
                  y2={h - padBottom + 5}
                  stroke="#8A6B3E"
                  strokeWidth="1"
                />
                <text
                  x={x}
                  y={h - padBottom + 25}
                  textAnchor="end"
                  transform={`rotate(-45, ${x}, ${h - padBottom + 25})`}
                  className="fill-[#8A6B3E] text-[10px] font-bold"
                >
                  {labels[i]}
                </text>
              </React.Fragment>
            );
          })}

          {/* Background Grid - Horizontal Lines & Y Ticks */}
          {yTicks.map((tick) => {
            const y = toY(tick);
            return (
              <React.Fragment key={`h-${tick}`}>
                <line
                  x1={padLeft}
                  y1={y}
                  x2={w - padRight}
                  y2={y}
                  stroke="#D7C6AE"
                  strokeWidth="0.5"
                  opacity="0.4"
                />
                <line
                  x1={padLeft - 5}
                  y1={y}
                  x2={padLeft}
                  y2={y}
                  stroke="#8A6B3E"
                  strokeWidth="1"
                />
                <text
                  x={padLeft - 20}
                  y={y}
                  textAnchor="end"
                  alignmentBaseline="middle"
                  className="fill-[#8A6B3E] text-xs font-bold"
                >
                  {tick.toFixed(2)}
                </text>
              </React.Fragment>
            );
          })}

          {/* Main Axes */}
          <line
            x1={padLeft}
            y1={padTop}
            x2={padLeft}
            y2={h - padBottom}
            stroke="#8A6B3E"
            strokeWidth="1"
          />
          <line
            x1={padLeft}
            y1={h - padBottom}
            x2={w - padRight}
            y2={h - padBottom}
            stroke="#8A6B3E"
            strokeWidth="1"
          />

          {/* The Actual Data Line */}
          <path
            d={d}
            fill="none"
            stroke="#8A6B3E"
            strokeWidth="1.8"
            strokeLinejoin="round"
            strokeLinecap="round"
          />

          {/* Data Points */}
          {points.map((v, i) => (
            <g
              key={i}
              onMouseEnter={() => setHoveredPoint(i)}
              onMouseLeave={() => setHoveredPoint(null)}
              className="cursor-pointer"
            >
              <circle
                cx={toX(i)}
                cy={toY(v)}
                r={hoveredPoint === i ? 6 : 3}
                fill={hoveredPoint === i ? "#BD9A6B" : "#8A6B3E"}
                className="transition-all"
              />
              {hoveredPoint === i && (
                <g>
                  <rect
                    x={toX(i) - 50}
                    y={toY(v) - 35}
                    width="100"
                    height="25"
                    rx="4"
                    fill="#8A6B3E"
                  />
                  <text
                    x={toX(i)}
                    y={toY(v) - 18}
                    textAnchor="middle"
                    className="fill-white text-[10px] font-bold"
                  >
                    {v.toFixed(3)}% ({labels[i]})
                  </text>
                </g>
              )}
            </g>
          ))}
        </svg>
      </div>
      <style dangerouslySetInnerHTML={{
        __html: `
        .custom-scrollbar::-webkit-scrollbar {
          height: 6px;
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
