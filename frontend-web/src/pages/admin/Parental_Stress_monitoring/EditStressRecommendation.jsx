import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Swal from "sweetalert2";
import AdminLayout from "../Admin_Management/AdminLayout";

import { FaArrowLeft } from "react-icons/fa";
import { IoIosArrowUp, IoIosArrowDown } from "react-icons/io";
import { HiPlus } from "react-icons/hi";
import { MdClose } from "react-icons/md";

import {
  getRecommendationByIdService,
  updateRecommendationService,
} from "../../../services/Admin/Parental_Stress_Monitoring/AdminRecommendationService";

const LEVELS = ["Low", "Medium", "High", "Critical"];
const CATEGORIES = [
  { label: "Calm Reset", value: "calm reset" },
  { label: "Positivity", value: "positivity" },
  { label: "Hydration", value: "hydration" },
  { label: "Self Awareness", value: "self awareness" },
  { label: "Digital Break", value: "digital break" },
  { label: "Grounding", value: "grounding" },
  { label: "Communication", value: "communication" },
  { label: "Wellbeing", value: "wellbeing" },
];

export default function EditStressRecommendation() {
  const navigate = useNavigate();
  const { id } = useParams();

  // form
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [stressLevel, setStressLevel] = useState("");
  const [category, setCategory] = useState("");
  const [minutes, setMinutes] = useState("");
  const [source, setSource] = useState("");
  const [steps, setSteps] = useState(["", ""]); // at least 2 inputs
  const [submitting, setSubmitting] = useState(false);
  const [loading, setLoading] = useState(true);

  // track initial state for discard check
  const [initialSnapshot, setInitialSnapshot] = useState(null);

  // duration controls
  const clamp60 = (v) => Math.max(0, Math.min(60, v));

  const setMinutesClamped = (raw) => {
    if (raw === "") return setMinutes("");
    const num = Number(String(raw).replace(/\D/g, ""));
    if (Number.isNaN(num)) return setMinutes("");
    setMinutes(String(clamp60(num)));
  };

  const incMinutes = () =>
    setMinutes((prev) => String(clamp60((Number(prev) || 0) + 1)));
  const decMinutes = () =>
    setMinutes((prev) => String(clamp60((Number(prev) || 0) - 1)));

  const addStep = () => setSteps((prev) => [...prev, ""]);
  const removeStep = (index) =>
    setSteps((prev) => prev.filter((_, i) => i !== index));
  const updateStep = (index, value) =>
    setSteps((prev) => prev.map((s, i) => (i === index ? value : s)));

  // Fetch & prefill
  useEffect(() => {
    let alive = true;

    const fetchOne = async () => {
      try {
        setLoading(true);

        const res = await getRecommendationByIdService(id);
        const r = res?.data?.data;

        const t = r?.title ?? "";
        const m = r?.message ?? "";
        const lvl = r?.level ?? "";
        const cat = r?.category ?? "";
        const dur = r?.duration != null ? String(r.duration) : "";
        const src = r?.source ?? "";

        // steps from backend: [{ step_number, instruction }]
        const stepInstructions = Array.isArray(r?.steps)
          ? r.steps
            .slice()
            .sort((a, b) => (a.step_number ?? 0) - (b.step_number ?? 0))
            .map((s) => s?.instruction ?? "")
          : [];

        // Keep at least 2 inputs
        const uiSteps =
          stepInstructions.length >= 2
            ? stepInstructions
            : [
              ...stepInstructions,
              ...Array(2 - stepInstructions.length).fill(""),
            ];

        if (!alive) return;

        setTitle(t.slice(0, 50));
        setMessage(m.slice(0, 150));
        setStressLevel(lvl);
        setCategory(cat);
        setMinutesClamped(dur);
        setSource(src);
        setSteps(uiSteps);

        setInitialSnapshot({
          title: t.slice(0, 50),
          message: m.slice(0, 150),
          stressLevel: lvl,
          category: cat,
          minutes:
            String(clamp60(Number(dur) || 0)) === "0"
              ? ""
              : String(clamp60(Number(dur) || 0)),
          source: src,
          steps: uiSteps,
        });
      } catch (e) {
        const msg =
          e?.response?.data?.message ||
          e?.response?.data?.error ||
          e?.message ||
          "Failed to fetch recommendation";

        await Swal.fire({
          icon: "error",
          title: "Failed",
          text: msg,
          confirmButtonColor: "#BD9A6B",
        });

        navigate("/stress_recommendation_list");
      } finally {
        if (alive) setLoading(false);
      }
    };

    fetchOne();
    return () => {
      alive = false;
    };
  }, [id, navigate]);

  const isDirty = useMemo(() => {
    if (!initialSnapshot) return false;

    const current = {
      title,
      message,
      stressLevel,
      category,
      minutes,
      source,
      steps,
    };

    return JSON.stringify(current) !== JSON.stringify(initialSnapshot);
  }, [
    initialSnapshot,
    title,
    message,
    stressLevel,
    category,
    minutes,
    source,
    steps,
  ]);

  const onBack = async () => {
    if (!isDirty) {
      navigate(-1);
      return;
    }

    const r = await Swal.fire({
      title: "Discard changes?",
      text: "Your edited data will be lost.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#6B3B30",
      confirmButtonText: "Yes, go back",
      cancelButtonText: "No",
    });

    if (r.isConfirmed) navigate(-1);
  };

  const validate = () => {
    const t = title.trim();
    const m = message.trim();
    const mins = Number(minutes);

    if (!t) return "Title is required";
    if (t.length > 50) return "Title must be 50 characters or less";

    if (!m) return "Message is required";
    if (m.length > 150) return "Message must be 150 characters or less";

    if (!stressLevel) return "Stress level is required";
    if (!category) return "Category is required";

    if (!minutes || Number.isNaN(mins) || mins <= 0)
      return "Duration is required";
    if (mins > 60) return "Duration must be 60 minutes or less";

    const cleanSteps = steps.map((x) => x.trim()).filter(Boolean);
    if (cleanSteps.length < 1) return "At least one step is required";

    // Source NOT required (as you said)
    return "";
  };

  const onSubmit = async (e) => {
    e.preventDefault();

    const v = validate();
    if (v) {
      await Swal.fire({
        icon: "error",
        title: "Validation Error",
        text: v,
        confirmButtonColor: "#BD9A6B",
      });
      return;
    }

    const cleanSteps = steps.map((x) => x.trim()).filter(Boolean);

    // ✅ base payload
    const payload = {
      title: title.trim(),
      message: message.trim(),
      level: stressLevel,
      category,
      duration: Number(minutes),
      steps: cleanSteps.map((instruction, idx) => ({
        step_number: idx + 1,
        instruction,
      })),
      is_active: true,
    };

    // ✅ source optional: include ONLY if user typed something
    const cleanSource = source.trim();
    if (cleanSource) payload.source = cleanSource;

    const confirm = await Swal.fire({
      title: "Update this recommendation?",
      text: "Please confirm to save your changes.",
      icon: "question",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#6B3B30",
      confirmButtonText: "Yes, Update",
      cancelButtonText: "No",
    });

    if (!confirm.isConfirmed) {
      await Swal.fire({
        icon: "info",
        title: "Cancelled",
        text: "Update cancelled.",
        confirmButtonColor: "#BD9A6B",
      });
      return;
    }

    try {
      setSubmitting(true);

      const data = await updateRecommendationService(id, payload);

      await Swal.fire({
        icon: "success",
        title: "Updated",
        text: data?.message || "Recommendation updated successfully.",
        confirmButtonColor: "#BD9A6B",
      });

      navigate(`/stress_recommendation_detail/${id}`);
    } catch (err) {
      const msg =
        err?.response?.data?.message ||
        err?.response?.data?.error ||
        err?.message ||
        "Update failed";

      await Swal.fire({
        icon: "error",
        title: "Failed",
        text: msg,
        confirmButtonColor: "#BD9A6B",
      });
    } finally {
      setSubmitting(false);
    }
  };

  const labelCol = "w-[140px]";

  return (
    <AdminLayout>
      <div className="w-full h-full bg-[#F3E8E8]">
        <div className="px-10 py-10">
          <div className="relative min-h-[660px] rounded-[14px] px-10 py-10">
            {/* Back */}
            <button
              onClick={onBack}
              className="absolute left-10 top-10 h-10 w-10 rounded-full bg-white/70
                         shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                         grid place-items-center hover:brightness-95 active:scale-[0.98]"
              title="Back"
              type="button"
            >
              <FaArrowLeft className="text-[#BD9A6B]" />
            </button>

            {/* Form Card */}
            <form
              onSubmit={onSubmit}
              className="mx-auto w-[860px] max-w-[95%] bg-[#E9DDCC] rounded-[14px]
                         shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                         px-6 sm:px-10 md:px-16 py-10 md:py-14 border border-[#BD9A6B]/40"
            >
              <h2 className="text-left text-[24px] font-semibold text-[#BD9A6B] underline underline-offset-4 pl-0 md:pl-8">
                Edit Stress Support Recommendation
              </h2>

              {loading && (
                <div className="mt-8 text-sm text-[#8B7A68]">
                  Loading existing data...
                </div>
              )}

              {/* Title row */}
              <div className="mt-12 grid grid-cols-1 md:grid-cols-[160px_20px_1fr] items-center gap-4">
                <label className={`text-[#BD9A6B] text-[18px] ${labelCol}`}>
                  Title
                </label>
                <span className="hidden md:block text-[#BD9A6B] text-[18px]">
                  :
                </span>

                <div className="relative w-full">
                  <input
                    value={title}
                    maxLength={50}
                    disabled={loading}
                    onChange={(e) => setTitle(e.target.value.slice(0, 50))}
                    className="w-full rounded-[10px] border border-[#BD9A6B] bg-[#E9DDCC]
                               px-3 py-2 pr-12 text-sm text-[#8F6F4C] outline-none
                               shadow-[0_6px_10px_rgba(0,0,0,0.12)] disabled:opacity-60"
                  />

                  <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[11px] text-[#BD9A6B] opacity-80">
                    {title.length}/50
                  </span>
                </div>
              </div>

              {/* Message row */}
              <div className="mt-10 grid grid-cols-1 md:grid-cols-[160px_20px_1fr] items-start gap-4">
                <label className={`text-[#BD9A6B] text-[18px] ${labelCol}`}>
                  Message
                </label>
                <span className="hidden md:block text-[#BD9A6B] text-[18px] pt-2">
                  :
                </span>

                <div className="relative w-full">
                  <textarea
                    value={message}
                    maxLength={150}
                    disabled={loading}
                    onChange={(e) => setMessage(e.target.value.slice(0, 150))}
                    rows={5}
                    className="w-full rounded-[14px] border border-[#BD9A6B] bg-[#E9DDCC]
                               px-3 py-2 pb-7 text-sm text-[#8F6F4C] outline-none
                               shadow-[0_6px_10px_rgba(0,0,0,0.12)] disabled:opacity-60"
                  />

                  <span className="absolute right-3 bottom-2 text-[11px] text-[#BD9A6B] opacity-80">
                    {message.length}/150
                  </span>
                </div>
              </div>

              {/* Stress level */}
              <div className="mt-10 grid grid-cols-1 md:grid-cols-[160px_20px_1fr] items-center gap-4">
                <label className={`text-[#BD9A6B] text-[18px] ${labelCol}`}>
                  Stress Level
                </label>
                <span className="hidden md:block text-[#BD9A6B] text-[18px]">
                  :
                </span>

                <select
                  value={stressLevel}
                  disabled={loading}
                  onChange={(e) => setStressLevel(e.target.value)}
                  className="w-full max-w-[560px] rounded-[10px] border border-[#BD9A6B] bg-[#E9DDCC]
                             px-3 py-2 text-sm text-[#8F6F4C] outline-none
                             shadow-[0_6px_10px_rgba(0,0,0,0.12)] disabled:opacity-60"
                >
                  <option value=""></option>
                  {LEVELS.map((x) => (
                    <option key={x} value={x}>
                      {x}
                    </option>
                  ))}
                </select>
              </div>

              {/* Category */}
              <div className="mt-8 grid grid-cols-1 md:grid-cols-[160px_20px_1fr] items-center gap-4">
                <label className={`text-[#BD9A6B] text-[18px] ${labelCol}`}>
                  Category
                </label>
                <span className="hidden md:block text-[#BD9A6B] text-[18px]">
                  :
                </span>

                <select
                  value={category}
                  disabled={loading}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full max-w-[560px] rounded-[10px] border border-[#BD9A6B] bg-[#E9DDCC]
                             px-3 py-2 text-sm text-[#8F6F4C] outline-none
                             shadow-[0_6px_10px_rgba(0,0,0,0.12)] disabled:opacity-60"
                >
                  <option value=""></option>
                  {CATEGORIES.map((x) => (
                    <option key={x.value} value={x.value}>
                      {x.label}
                    </option>
                  ))}
                </select>
              </div>

              {/* Duration */}
              <div className="mt-8 grid grid-cols-1 md:grid-cols-[160px_20px_1fr] items-center gap-4">
                <label className={`text-[#BD9A6B] text-[18px] ${labelCol}`}>
                  Duration
                </label>
                <span className="hidden md:block text-[#BD9A6B] text-[18px]">
                  :
                </span>

                <div className="flex items-center gap-3">
                  <input
                    value={minutes}
                    inputMode="numeric"
                    disabled={loading}
                    onChange={(e) => setMinutesClamped(e.target.value)}
                    className="w-[56px] h-[46px] text-center rounded-[14px]
                               border border-[#BD9A6B] bg-[#E9DDCC]
                               outline-none text-[18px] font-semibold text-[#8F6F4C]
                               shadow-[0_10px_18px_rgba(0,0,0,0.12)] disabled:opacity-60"
                  />

                  <div className="flex flex-col gap-1">
                    <button
                      type="button"
                      disabled={loading}
                      onClick={incMinutes}
                      className="h-[20px] w-[26px] rounded-[8px]
                                 border border-[#BD9A6B] bg-[#E9DDCC]
                                 shadow-[0_10px_18px_rgba(0,0,0,0.12)]
                                 grid place-items-center hover:brightness-95 active:translate-y-[1px] disabled:opacity-60"
                      aria-label="Increase duration"
                    >
                      <span className="text-[#BD9A6B] text-lg leading-none">
                        <IoIosArrowUp />
                      </span>
                    </button>

                    <button
                      type="button"
                      disabled={loading}
                      onClick={decMinutes}
                      className="h-[20px] w-[26px] rounded-[8px]
                                 border border-[#BD9A6B] bg-[#E9DDCC]
                                 shadow-[0_10px_18px_rgba(0,0,0,0.12)]
                                 grid place-items-center hover:brightness-95 active:translate-y-[1px] disabled:opacity-60"
                      aria-label="Decrease duration"
                    >
                      <span className="text-[#BD9A6B] text-lg leading-none">
                        <IoIosArrowDown />
                      </span>
                    </button>
                  </div>

                  <span className="text-[#BD9A6B] text-[16px] ml-1">min</span>
                  <span className="text-[12px] text-[#BD9A6B] opacity-70 ml-3">
                    (max 60)
                  </span>
                </div>
              </div>

              {/* Steps */}
              <div className="mt-10 grid grid-cols-1 md:grid-cols-[160px_20px_1fr] items-start gap-4">
                <label className={`text-[#BD9A6B] text-[18px] ${labelCol}`}>
                  Steps
                </label>
                <span className="hidden md:block text-[#BD9A6B] text-[18px] pt-1">
                  :
                </span>

                <div className="relative w-full">
                  <button
                    type="button"
                    disabled={loading}
                    onClick={addStep}
                    className="absolute right-0 -top-2 h-11 w-11 rounded-full bg-[#F7EAD7]
                               shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                               grid place-items-center hover:brightness-95 active:scale-[0.98] disabled:opacity-60"
                    title="Add Step"
                  >
                    <HiPlus className="text-[#BD9A6B]" size={22} />
                  </button>

                  <div className="mt-12 space-y-6">
                    {steps.map((s, idx) => (
                      <div key={idx} className="flex items-center gap-4">
                        <div className="w-8 text-[#BD9A6B] text-sm">
                          {idx + 1}.
                        </div>

                        <input
                          value={s}
                          disabled={loading}
                          onChange={(e) => updateStep(idx, e.target.value)}
                          className="flex-1 bg-transparent border-b border-[#BD9A6B]
                                     outline-none py-2 text-sm text-[#8F6F4C] disabled:opacity-60"
                        />

                        <button
                          type="button"
                          disabled={loading}
                          onClick={() => removeStep(idx)}
                          className="text-[#BD9A6B] hover:brightness-90 disabled:opacity-60"
                          title="Remove"
                        >
                          <MdClose size={22} />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Source (optional) */}
              <div className="mt-12 grid grid-cols-1 md:grid-cols-[160px_20px_1fr] items-center gap-4">
                <label className={`text-[#BD9A6B] text-[18px] ${labelCol}`}>
                  Source
                </label>
                <span className="hidden md:block text-[#BD9A6B] text-[18px]">
                  :
                </span>

                <input
                  value={source}
                  disabled={loading}
                  onChange={(e) => setSource(e.target.value)}
                  className="w-full max-w-[560px] rounded-[10px] border border-[#BD9A6B] bg-[#E9DDCC]
                             px-3 py-2 text-sm text-[#8F6F4C] outline-none
                             shadow-[0_6px_10px_rgba(0,0,0,0.12)] disabled:opacity-60"
                />
              </div>

              {/* Submit */}
              <div className="mt-14 flex justify-end">
                <button
                  disabled={submitting || loading}
                  type="submit"
                  className="w-[160px] rounded-[10px] bg-[#BD9A6B] py-2 text-sm font-semibold text-white
                             shadow-[0_10px_16px_rgba(0,0,0,0.20)] hover:brightness-95
                             disabled:opacity-60 disabled:cursor-not-allowed"
                >
                  {submitting ? "Updating..." : "Update"}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
