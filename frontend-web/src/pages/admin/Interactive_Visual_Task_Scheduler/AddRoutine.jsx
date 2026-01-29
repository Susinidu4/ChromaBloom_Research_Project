import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import AdminLayout from "../AdminLayout";
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
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState("");

  // ✅ UX states
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const onBack = () => navigate(-1);

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
    if (!title.trim()) return "Title is required";
    if (!description.trim()) return "Description is required";
    if (!ageGroup) return "Age group is required";
    if (!devArea) return "Development area is required";
    if (!difficulty) return "Difficulty level is required";

    const cleanSteps = steps.map((x) => x.trim()).filter(Boolean);
    if (cleanSteps.length === 0) return "At least one step is required";

    const dur = durationToMinutes();
    if (!dur || dur <= 0) return "Duration must be a valid number";

    return "";
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccessMsg("");

    const v = validate();
    if (v) {
      setError(v);
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
      age_group: ageGroup, // backend expects "1".."10"
      development_area: devArea, // backend expects enum values
      difficulty_level: difficulty, // easy/medium/hard
      estimated_duration_minutes: durationToMinutes(),
      steps: cleanSteps,
      imageFile,
    };

    try {
      setSubmitting(true);
      const res = await createSystemActivityService(payload);
      setSuccessMsg(res?.message || "Created successfully!");

      // ✅ after success you can redirect to list
      // navigate("/routine_list");
      // or clear form:
      setTitle("");
      setDescription("");
      setMinutes("");
      setSeconds("");
      setDifficulty("");
      setDevArea("");
      setAgeGroup("");
      setSteps(["", ""]);
      setImageFile(null);
    } catch (err) {
      const msg =
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        err?.message ||
        "Failed to create routine";
      setError(msg);
    } finally {
      setSubmitting(false);
    }
  };

  useEffect(() => {
    if (!imageFile) {
      setImagePreview("");
      return;
    }
    const url = URL.createObjectURL(imageFile);
    setImagePreview(url);

    return () => URL.revokeObjectURL(url);
  }, [imageFile]);

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
      <div className="w-full h-full bg-[#F3ECE7]">
        <div className="px-10 py-10">
          <div className="relative min-h-[660px] rounded-[14px] px-10 py-10">
            {/* Back button */}
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
              className="mx-auto w-[760px] max-w-[92%] bg-[#E9DDCC] rounded-[14px]
                         shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                         px-14 py-12 border border-[#BD9A6B]/40"
            >
              <h2 className="text-center text-[22px] font-semibold text-[#BD9A6B] underline underline-offset-4">
                Add new Routine
              </h2>

              {/* Illustration */}
              <div className="mt-8 flex justify-center">
                <img
                  src={createRoutineImg}
                  alt="create routine"
                  className="h-[150px] w-auto object-contain"
                />
              </div>

              {/* Messages */}
              {error && (
                <div className="mt-6 rounded-lg bg-red-50 text-red-600 px-4 py-3 text-sm">
                  {error}
                </div>
              )}
              {successMsg && (
                <div className="mt-6 rounded-lg bg-green-50 text-green-700 px-4 py-3 text-sm">
                  {successMsg}
                </div>
              )}

              {/* Title */}
              <div className="mt-10 grid grid-cols-[120px_1fr] gap-6 items-center">
                <label className="text-[#BD9A6B] text-sm font-semibold">
                  Title :
                </label>
                <input
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="bg-transparent border-b border-[#BD9A6B]/60 focus:border-[#BD9A6B]
                             outline-none py-2 text-sm text-[#8F6F4C]"
                />
              </div>

              {/* Description */}
              <div className="mt-6 grid grid-cols-[120px_1fr] gap-6">
                <label className="text-[#BD9A6B] text-sm font-semibold pt-2">
                  Description :
                </label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={4}
                  className="w-full rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                             outline-none px-4 py-3 text-sm text-[#8F6F4C]
                             shadow-[0_6px_10px_rgba(0,0,0,0.12)]"
                />
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
                      className="w-[60px] h-[50px] text-center rounded-[18px]
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
              <div className="mt-6 grid grid-cols-[160px_1fr] gap-6 items-center">
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
                  Media (Images) :
                </label>

                <div>
                  <div className="flex items-center gap-3">
                    <label
                      className="flex-1 rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                   px-4 py-2 text-sm text-[#8F6F4C] outline-none cursor-pointer
                   flex items-center justify-between"
                    >
                      <span className="truncate">
                        {imageFile ? imageFile.name : "Choose image"}
                      </span>
                      <FiUpload className="text-[#BD9A6B]" />
                      <input
                        type="file"
                        accept="image/*"
                        hidden
                        onChange={(e) =>
                          setImageFile(e.target.files?.[0] || null)
                        }
                      />
                    </label>

                    {imageFile && (
                      <button
                        type="button"
                        onClick={() => setImageFile(null)}
                        className="h-10 w-10 rounded-full bg-white/70
                     shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                     grid place-items-center hover:brightness-95"
                        title="Remove image"
                      >
                        <MdClose className="text-[#BD9A6B]" />
                      </button>
                    )}
                  </div>

                  {/* User selected image preview (only here) */}
                  {imageFile && (
                    <div className="mt-4">
                      <p className="text-xs text-[#BD9A6B] mb-2">Preview:</p>
                      <img
                        src={imagePreview}
                        alt="uploaded preview"
                        className="h-[120px] w-auto rounded-[12px] border border-[#BD9A6B]/40
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
                  className="w-[160px] rounded-[10px] bg-[#BD9A6B] py-2 text-sm font-semibold text-white
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
