import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";

import AdminLayout from "../Admin_Management/AdminLayout";
import { createSystemActivityService } from "../../../services/Admin/Interactive_Visual_Task_Scheduler/adminRoutineService";
import createRoutineImg from "../../../assets/Interactive_Visual_Task_Scheduler/admin_create_routine.png";

import { IoIosArrowDown } from "react-icons/io";
import { IoIosArrowUp } from "react-icons/io";
import { FaArrowLeft } from "react-icons/fa";
import { FiUpload } from "react-icons/fi";
import { HiPlus } from "react-icons/hi";
import { MdClose } from "react-icons/md";

export default function AddRoutine() {
  const navigate = useNavigate();

  // ✅ form states
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [minutes, setMinutes] = useState(""); // UI small box
  const [difficulty, setDifficulty] = useState(""); // easy/medium/hard
  const [devArea, setDevArea] = useState(""); // self-care/motor/language/cognitive/social/emotional
  const [ageGroup, setAgeGroup] = useState(""); // "1".."10"

  const [steps, setSteps] = useState(["", ""]); // UI has at least 2 lines
  const [videoFile, setVideoFile] = useState(null);
  const [videoPreview, setVideoPreview] = useState("");

  // ✅ UX states
  const [submitting, setSubmitting] = useState(false);

  const onBack = () => {
    Swal.fire({
      title: "Discard changes?",
      text: "Your entered data will be lost.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#6B3B30",
      confirmButtonText: "Yes, go back",
    }).then((result) => {
      if (result.isConfirmed) {
        navigate(-1);
      }
    });
  };

  const addStep = () => setSteps((prev) => [...prev, ""]);
  const removeStep = (index) =>
    setSteps((prev) => prev.filter((_, i) => i !== index));

  const updateStep = (index, value) =>
    setSteps((prev) => prev.map((s, i) => (i === index ? value : s)));

  const durationToMinutes = () => {
    const m = Number(minutes || 0);
    return Number.isNaN(m) ? 0 : m;
  };

  const validate = () => {
    const t = title.trim();
    const d = description.trim();

    if (!t) return "Title is required";
    if (t.length > 50) return "Title cannot exceed 50 characters";

    if (!d) return "Description is required";
    if (d.length > 150) return "Description cannot exceed 150 characters";

    const dur = durationToMinutes();
    if (!dur || dur <= 0) return "Duration is required";

    if (!difficulty) return "Difficulty level is required";
    if (!devArea) return "Development area is required";
    if (!ageGroup) return "Age group is required";

    const cleanSteps = steps.map((x) => x.trim()).filter(Boolean);
    if (cleanSteps.length < 1) return "At least one step is required";

    // ✅ image not required → no validation for imageFile

    return "";
  };

  const onSubmit = async (e) => {
    e.preventDefault();

    const v = validate();
    if (v) {
      Swal.fire({
        icon: "error",
        title: "Validation Error",
        text: v,
        confirmButtonColor: "#BD9A6B",
      });
      return;
    }

    const cleanSteps = steps
      .map((x) => x.trim())
      .filter(Boolean)
      .map((instruction, idx) => ({
        step_number: idx + 1,
        instruction,
      }));

    const payload = {
      title: title.trim(),
      description: description.trim(),
      age_group: ageGroup,
      development_area: devArea,
      difficulty_level: difficulty,
      estimated_duration_minutes: durationToMinutes(),
      steps: cleanSteps,
      videoFile,
    };

    try {
      setSubmitting(true);
      const res = await createSystemActivityService(payload);

      Swal.fire({
        icon: "success",
        title: "Routine Created",
        text: res?.message || "Routine created successfully!",
        confirmButtonColor: "#BD9A6B",
      }).then(() => {
        navigate("/routine_list");
      });
    } catch (err) {
      const msg =
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        err?.message ||
        "Failed to create routine";

      Swal.fire({
        icon: "error",
        title: "Creation Failed",
        text: msg,
        confirmButtonColor: "#BD9A6B",
      });
    } finally {
      setSubmitting(false);
    }
  };

  useEffect(() => {
    if (!videoFile) {
      setVideoPreview("");
      return;
    }
    const url = URL.createObjectURL(videoFile);
    setVideoPreview(url);

    return () => URL.revokeObjectURL(url);
  }, [videoFile]);

  const clamp60 = (v) => Math.max(0, Math.min(60, v));

  const setMinutesClamped = (raw) => {
    // allow empty while typing
    if (raw === "") return setMinutes("");

    // digits only
    const num = Number(String(raw).replace(/\D/g, ""));
    if (Number.isNaN(num)) return setMinutes("");
    setMinutes(String(clamp60(num)));
  };

  const incMinutes = () =>
    setMinutes((prev) => String(clamp60((Number(prev) || 0) + 1)));
  const decMinutes = () =>
    setMinutes((prev) => String(clamp60((Number(prev) || 0) - 1)));

  return (
    <AdminLayout>
      <div className="w-full h-full bg-[#F3E8E8]">
        <div className="px-4 sm:px-6 lg:px-10 py-6 sm:py-8 lg:py-10">
          <div className="relative min-h-[660px] rounded-[14px] px-10 py-10">
            {/* Back button */}
            <button
              onClick={onBack}
              className="mb-6 sm:absolute sm:left-0 sm:top-0 h-10 w-10 rounded-full bg-white/70
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
              className="mx-auto w-full max-w-3xl bg-[#E9DDCC] rounded-[14px] shadow-[0_10px_18px_rgba(0,0,0,0.18)] px-5 sm:px-8 lg:px-12 py-8 sm:py-10 border border-[#BD9A6B]/40"
            >
              <h2 className="text-center text-[22px] font-semibold text-[#BD9A6B] underline underline-offset-4">
                Add new Routine
              </h2>

              {/* Illustration */}
              {/* <div className="mt-8 flex justify-center">
                <img
                  src={createRoutineImg}
                  alt="create routine"
                  className="h-[150px] w-auto object-contain"
                />
              </div> */}

              {/* Title */}
              <div className="mt-10 grid grid-cols-1 sm:grid-cols-[140px_1fr] gap-4 sm:gap-6 items-start sm:items-center">
                <label className="text-[#BD9A6B] text-sm font-semibold">
                  Title :
                </label>

                {/* Input wrapper */}
                <div className="relative">
                  <input
                    value={title}
                    maxLength={50}
                    onChange={(e) => setTitle(e.target.value)}
                    className="w-full bg-transparent border-b border-[#BD9A6B]/60
                 focus:border-[#BD9A6B]
                 outline-none py-2 pr-12 text-sm text-[#8F6F4C]"
                  />

                  {/* Counter */}
                  <span
                    className="absolute right-0 bottom-0 text-[11px]
                     text-[#BD9A6B] opacity-80"
                  >
                    {title.length}/50
                  </span>
                </div>
              </div>

              {/* Description */}
              <div className="mt-6 grid grid-cols-[120px_1fr] gap-6">
                <label className="text-[#BD9A6B] text-sm font-semibold pt-2">
                  Description :
                </label>

                {/* Textarea wrapper */}
                <div className="relative">
                  <textarea
                    value={description}
                    maxLength={150}
                    onChange={(e) => setDescription(e.target.value)}
                    rows={4}
                    className="w-full rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                 outline-none px-4 py-3 pb-7 text-sm text-[#8F6F4C]
                 shadow-[0_6px_10px_rgba(0,0,0,0.12)]"
                  />

                  {/* Counter */}
                  <span
                    className="absolute right-3 bottom-2 text-[11px]
                     text-[#BD9A6B] opacity-80"
                  >
                    {description.length}/150
                  </span>
                </div>
              </div>

              {/* Duration */}
              <div className="mt-6 grid grid-cols-[120px_1fr] gap-6 items-center">
                <label className="text-[#BD9A6B] text-sm font-semibold">
                  Duration :
                </label>

                <div className="flex items-center gap-4">
                  {/* Big rounded input */}
                  <div className="flex items-center gap-3">
                    <input
                      value={minutes}
                      inputMode="numeric"
                      onChange={(e) => setMinutesClamped(e.target.value)}
                      onBlur={() => {
                        // if left empty, keep it empty (validation will catch)
                        if (minutes === "") return;
                        setMinutesClamped(minutes);
                      }}
                      className="w-16 sm:w-20 h-12 sm:h-[50px] text-center rounded-[18px]
                   border border-[#BD9A6B] bg-[#E9DDCC]
                   outline-none text-[18px] font-semibold text-[#8F6F4C]
                   shadow-[0_10px_18px_rgba(0,0,0,0.12)]"
                      placeholder=""
                    />

                    {/* Up / Down buttons */}
                    <div className="flex flex-col gap-1">
                      <button
                        type="button"
                        onClick={incMinutes}
                        className="h-[20px] w-[25px] rounded-[8px]
                     border border-[#BD9A6B] bg-[#E9DDCC]
                     shadow-[0_10px_18px_rgba(0,0,0,0.12)]
                     grid place-items-center hover:brightness-95 active:translate-y-[1px]
                     transition"
                        aria-label="Increase duration"
                      >
                        <span className="text-[#BD9A6B] text-lg leading-none">
                          <IoIosArrowUp />
                        </span>
                      </button>

                      <button
                        type="button"
                        onClick={decMinutes}
                        className="h-[20px] w-[25px] rounded-[8px]
                     border border-[#BD9A6B] bg-[#E9DDCC]
                     shadow-[0_10px_18px_rgba(0,0,0,0.12)]
                     grid place-items-center hover:brightness-95 active:translate-y-[1px]
                     transition"
                        aria-label="Decrease duration"
                      >
                        <span className="text-[#BD9A6B] text-lg leading-none">
                          <IoIosArrowDown />
                        </span>
                      </button>
                    </div>
                  </div>

                  <span className="text-[#BD9A6B] text-lg">min</span>
                </div>
              </div>

              {/* Steps */}
              <div className="mt-6 grid grid-cols-[120px_1fr] gap-6">
                <label className="text-[#BD9A6B] text-sm font-semibold pt-2">
                  Steps :
                </label>

                <div className="relative">
                  {/* Add step button */}
                  <button
                    type="button"
                    onClick={addStep}
                    className="absolute -right-2 -top-2 h-9 w-9 rounded-full bg-[#F7EAD7]
                               shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                               grid place-items-center hover:brightness-95 transition-all duration-200
                             hover:bg-[#F7EAD7]/15
                                hover:shadow-[0_14px_22px_rgba(0,0,0,0.22)]
                                hover:-translate-y-[1px]
                                active:translate-y-0"
                    title="Add Step"
                  >
                    <HiPlus className="text-[#BD9A6B]" size={18} />
                  </button>

                  <div className="space-y-4 mt-10">
                    {steps.map((s, idx) => (
                      <div key={idx} className="flex items-center gap-4">
                        <div className="w-5 text-[#BD9A6B] text-sm">
                          {idx + 1}.
                        </div>

                        <input
                          value={s}
                          onChange={(e) => updateStep(idx, e.target.value)}
                          className="flex-1 bg-transparent border-b border-[#BD9A6B]
                                     outline-none py-2 text-sm text-[#8F6F4C]"
                        />

                        {/* remove step */}
                        <button
                          type="button"
                          onClick={() => removeStep(idx)}
                          className="text-[#BD9A6B] hover:brightness-90"
                          title="Remove"
                        >
                          <MdClose size={18} />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Difficulty */}
              <div className="mt-6 grid grid-cols-1 sm:grid-cols-[160px_1fr] gap-4 sm:gap-6 items-start sm:items-center">
                <label className="text-[#BD9A6B] text-sm font-semibold">
                  Difficulty Level :
                </label>

                <select
                  value={difficulty}
                  onChange={(e) => setDifficulty(e.target.value)}
                  className="appearance-none rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                             px-4 py-2 text-sm text-[#8F6F4C] outline-none"
                >
                  <option value="">Select</option>
                  {/* backend enum: easy/medium/hard */}
                  <option value="easy">Easy</option>
                  <option value="medium">Medium</option>
                  <option value="hard">Hard</option>
                </select>
              </div>

              {/* Development Area */}
              <div className="mt-4 grid grid-cols-[160px_1fr] gap-6 items-center">
                <label className="text-[#BD9A6B] text-sm font-semibold">
                  Development Area :
                </label>

                <select
                  value={devArea}
                  onChange={(e) => setDevArea(e.target.value)}
                  className="appearance-none rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                             px-4 py-2 text-sm text-[#8F6F4C] outline-none"
                >
                  <option value="">Select</option>
                  {/* backend enum values */}
                  <option value="self-care">Self - Care</option>
                  <option value="motor">Motor</option>
                  <option value="language">Language</option>
                  <option value="cognitive">Cognitive</option>
                  <option value="social">Social</option>
                  <option value="emotional">Emotional</option>
                </select>
              </div>

              {/* Age group */}
              <div className="mt-4 grid grid-cols-[160px_1fr] gap-6 items-center">
                <label className="text-[#BD9A6B] text-sm font-semibold">
                  Age Group :
                </label>

                <select
                  value={ageGroup}
                  onChange={(e) => setAgeGroup(e.target.value)}
                  className="appearance-none rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                             px-4 py-2 text-sm text-[#8F6F4C] outline-none"
                >
                  <option value="">Select</option>
                  {Array.from({ length: 10 }).map((_, i) => (
                    <option key={i + 1} value={String(i + 1)}>
                      {i + 1}
                    </option>
                  ))}
                </select>
              </div>

              {/* Media (Images) */}
              <div className="mt-4 grid grid-cols-[160px_1fr] gap-6 items-start">
                <label className="text-[#BD9A6B] text-sm font-semibold pt-2">
                  Media (Video) :
                </label>

                <div>
                  <div className="flex items-center gap-3">
                    <label
                      className="flex-1 rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                   px-4 py-2 text-sm text-[#8F6F4C] outline-none cursor-pointer
                   flex items-center justify-between"
                    >
                      <span className="truncate">
                        {videoFile ? videoFile.name : "Choose video"}
                      </span>
                      <FiUpload className="text-[#BD9A6B]" />
                      <input
                        type="file"
                        accept="video/*"
                        hidden
                        onChange={(e) =>
                          setVideoFile(e.target.files?.[0] || null)
                        }
                      />
                    </label>

                    {videoFile && (
                      <button
                        type="button"
                        onClick={() => setVideoFile(null)}
                        className="h-10 w-10 rounded-full bg-white/70
                     shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                     grid place-items-center hover:brightness-95"
                        title="Remove video"
                      >
                        <MdClose className="text-[#BD9A6B]" />
                      </button>
                    )}
                  </div>

                  {/* User selected video preview (only here) */}
                  {videoFile && (
                    <div className="mt-4">
                      <p className="text-xs text-[#BD9A6B] mb-2">Preview:</p>
                      <video
                        src={videoPreview}
                        controls
                        className="w-full max-w-xs sm:max-w-sm h-[140px] sm:h-[160px] rounded-[12px] border border-[#BD9A6B]/40
                     shadow-[0_8px_14px_rgba(0,0,0,0.12)] object-contain"
                      />
                    </div>
                  )}
                </div>
              </div>

              {/* Submit */}
              <div className="mt-10 flex justify-end pr-2">
                <button
                  disabled={submitting}
                  type="submit"
                  className="w-full sm:w-[180px] rounded-[10px] bg-[#BD9A6B] py-2 text-sm font-semibold text-white
                             shadow-[0_10px_16px_rgba(0,0,0,0.20)] hover:brightness-95
                             disabled:opacity-60 disabled:cursor-not-allowed"
                >
                  {submitting ? "Adding..." : "Add"}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
