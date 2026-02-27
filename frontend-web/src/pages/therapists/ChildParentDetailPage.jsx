import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { FaArrowLeft } from "react-icons/fa";
import Swal from "sweetalert2";

import { getChildByIdService } from "../../services/childService";

import RoutineProgress from "../../components/Therapist/RoutineProgress";
import SkillDevelopmentProgress from "../../components/Therapist/SkillDevelopmentProgress";
import CognitiveProgress from "../../components//Therapist/CognitiveProgress";
import StressAnalysis from "../../components/Therapist/StressAnalysis";

import TherapistLayout from "../therapists/TherapistLayout";

export default function ChildParentDetailPage() {
  const [tab, setTab] = useState("child"); // "child" | "parent"

  const { id } = useParams();
  const [child, setChild] = useState(null);
  const [parent, setParent] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const load = async () => {
      try {
        setLoading(true);

        const token = localStorage.getItem("therapist_token");
        const data = await getChildByIdService(id, token);

        // console.log("===== RAW CHILD DATA FROM API =====");
        // console.log(data);

        setChild(data);

        // parent might be inside child object (adjust according to your backend)
        setParent(data?.caregiver || data?.parent || null);
      } catch (e) {
        Swal.fire({
          icon: "error",
          title: "Failed to load details",
          text:
            e?.response?.data?.message ||
            "Unable to fetch child information. Please try again.",
          confirmButtonColor: "#BD9A6B",
        });
      } finally {
        setLoading(false);
      }
    };
    if (id) load();
  }, [id]);

  // Accordions for the "other information" sections
  const [open, setOpen] = useState({
    childBasic: true,
    childMedical: true,
    childOtherHealth: true,
    routine: true,
    skill: true,
    cognitive: true,

    parentBasic: true,
    stress: true,
  });

  const toggle = (key) => setOpen((s) => ({ ...s, [key]: !s[key] }));

  return (
    <TherapistLayout>
      <div className="bg-[#F3E8E8] min-h-[calc(100vh-64px)]">
        {/* Page container */}
        <div className="max-w-[1100px] mx-auto px-4 md:px-6 py-6 relative pt-10">
          {/* Back button */}
          <button
            onClick={() => navigate("/therapists_dashboard")}
            className="absolute -left-10 top-10 h-10 w-10 rounded-full bg-white/80
             shadow-[0_10px_18px_rgba(0,0,0,0.18)]
             grid place-items-center hover:brightness-95 active:scale-[0.98]"
            title="Back"
          >
            <FaArrowLeft className="text-[#BD9A6B]" />
          </button>

          {/* Tabs */}
          <div className="flex ">
            <button
              onClick={() => setTab("child")}
              className={`px-6 py-2 rounded-t-md text-sm font-semibold border
              ${
                tab === "child"
                  ? "bg-[#BD9A6B] text-white border-[#DFC7A7]"
                  : "bg-[#DFC7A7] text-white border-[#BD9A6B] hover:bg-[#E5D6C4]"
              }`}
            >
              Child Information
            </button>

            <button
              onClick={() => setTab("parent")}
              className={`px-6 py-2 rounded-t-md text-sm font-semibold border
              ${
                tab === "parent"
                  ? "bg-[#BD9A6B] text-white border-[#DFC7A7]"
                  : "bg-[#DFC7A7] text-white border-[#BD9A6B] hover:bg-[#E5D6C4]"
              }`}
            >
              Parent Information
            </button>
          </div>

          {/* Outer card */}
          <div className="border border-[#BD9A6B] rounded-b-md rounded-tr-md p-4 md:p-6">
            {/* ---------------- CHILD TAB ---------------- */}
            {tab === "child" && (
              <div className="space-y-8">
                {/* Basic Information */}
                <Section
                  title="Basic Information"
                  open={open.childBasic}
                  onToggle={() => toggle("childBasic")}
                >
                  <TwoColInfo
                    items={[
                      ["Name", child?.childName],
                      ["Date of Birth", formatDMY(child?.dateOfBirth)],
                      ["Gender", child?.gender],
                      ["Height", child?.heightCm],
                      ["Weight", child?.weightKg],
                    ]}
                  />
                </Section>

                {/* Medical Information */}
                <Section
                  title="Medical Information"
                  open={open.childMedical}
                  onToggle={() => toggle("childMedical")}
                >
                  <TwoColInfo
                    items={[
                      ["Down Syndrome Type", child?.downSyndromeType],
                      ["DS Confirmed By", child?.downSyndromeConfirmedBy],
                    ]}
                  />
                </Section>

                {/* Other Health Conditions */}
                <Section
                  title="Other Health Conditions"
                  open={open.childOtherHealth}
                  onToggle={() => toggle("childOtherHealth")}
                >
                  <TwoColInfo
                    items={[
                      [
                        "Hearing Problems",
                        child?.otherHealthConditions?.hearingProblems
                          ? "Yes"
                          : "No",
                      ],
                      [
                        "Heart Issues",
                        child?.otherHealthConditions?.heartIssues
                          ? "Yes"
                          : "No",
                      ],
                      [
                        "Thyroid",
                        child?.otherHealthConditions?.thyroid ? "Yes" : "No",
                      ],
                      [
                        "Vision Problems",
                        child?.otherHealthConditions?.visionProblems
                          ? "Yes"
                          : "No",
                      ],
                    ]}
                  />
                </Section>

                {/* Routine Progress (component) */}
                <Section
                  title="Routine Progress"
                  open={open.routine}
                  onToggle={() => toggle("routine")}
                >
                  <RoutineProgress
                    caregiverId={child?.caregiver?._id}
                    childId={child?._id}
                  />
                </Section>

                {/* Skill Development Progress (component) */}
                <Section
                  title="Skill Development Progress"
                  open={open.skill}
                  onToggle={() => toggle("skill")}
                >
                  <SkillDevelopmentProgress />
                </Section>

                {/* Cognitive Progress (component) */}
                <Section
                  title="Cognitive Progress"
                  open={open.cognitive}
                  onToggle={() => toggle("cognitive")}
                >
                  <CognitiveProgress />
                </Section>
              </div>
            )}

            {/* ---------------- PARENT TAB ---------------- */}
            {tab === "parent" && (
              <div className="space-y-6">
                {/* Basic Information */}
                <Section
                  title="Basic Information"
                  open={open.parentBasic}
                  onToggle={() => toggle("parentBasic")}
                >
                  <TwoColInfo
                    items={[
                      ["Name", parent?.full_name || parent?.name],
                      ["Gender", parent?.gender],
                      ["Date of Birth", formatDMY(parent?.dob)],
                      ["No of children", String(parent?.child_count)],
                    ]}
                  />
                </Section>

                {/* Stress Analysis (component) */}
                <Section
                  title="Stress Analysis"
                  open={open.stress}
                  onToggle={() => toggle("stress")}
                >
                  <StressAnalysis caregiverId={child?.caregiver?._id} />
                </Section>
              </div>
            )}
          </div>
        </div>
      </div>
    </TherapistLayout>
  );
}

/* ---------------- Small UI helpers inside same file ---------------- */

function Section({ title, open, onToggle, children }) {
  return (
    <div className="bg-transparent">
      <button
        type="button"
        onClick={onToggle}
        className="w-full flex items-center justify-between
                   text-left font-semibold text-[#BD9A6B]
                   pb-2"
      >
        <span className="text-sm md:text-base">{title}</span>

        <svg
          className={`w-5 h-5 transition-transform ${open ? "rotate-180" : ""}`}
          viewBox="0 0 24 24"
          fill="none"
        >
          <path
            d="M6 9l6 6 6-6"
            stroke="#8A6B3E"
            strokeWidth="2.2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </button>

      <div className="h-px bg-[#BD9A6B]" />

      {open && <div className="pt-4">{children}</div>}
    </div>
  );
}

function TwoColInfo({ items }) {
  return (
    <div className="max-w-[400px] text-sm text-[#BD9A6B]">
      <div className="grid grid-cols-[140px_18px_1fr] gap-y-2">
        {items.map(([k, v]) => (
          <React.Fragment key={k}>
            <div className="opacity-90">{k}</div>
            <div className="opacity-60">:</div>
            <div className="border-b border-[#BD9A6B] inline-block w-full pr-6">
              {v}
            </div>
          </React.Fragment>
        ))}
      </div>
    </div>
  );
}

const formatDMY = (iso) => {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";

  const day = String(d.getDate()).padStart(2, "0");
  const month = String(d.getMonth() + 1).padStart(2, "0");
  const year = d.getFullYear();
  return `${day}/${month}/${year}`;
};
