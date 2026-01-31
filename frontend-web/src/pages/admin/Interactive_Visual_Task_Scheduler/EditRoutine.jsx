import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Swal from "sweetalert2";
import AdminLayout from "../AdminLayout";

import {
  getSystemActivityByIdService,
  updateSystemActivityService,
} from "../../../services/Admin/Interactive_Visual_Task_Scheduler/adminRoutineService";

import createRoutineImg from "../../../assets/Interactive_Visual_Task_Scheduler/admin_create_routine.png";

import { IoIosArrowDown, IoIosArrowUp } from "react-icons/io";
import { FaArrowLeft } from "react-icons/fa";
import { FiUpload } from "react-icons/fi";
import { HiPlus } from "react-icons/hi";
import { MdClose } from "react-icons/md";

export default function EditRoutine() {
  const navigate = useNavigate();
  const { id } = useParams();

  // ✅ form states
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [minutes, setMinutes] = useState(""); // 0..60
  const [difficulty, setDifficulty] = useState("");
  const [devArea, setDevArea] = useState("");
  const [ageGroup, setAgeGroup] = useState("");

  const [steps, setSteps] = useState(["", ""]); // at least 2 lines
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState(""); // local preview
  const [existingImageUrl, setExistingImageUrl] = useState(""); // already saved url

  // ✅ UX states
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  const onBack = () => navigate(`/routine_detail/${id}`);

  // -----------------------------
  // Helpers
  // -----------------------------
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

  const durationToMinutes = () => {
    const m = Number(minutes || 0);
    return Number.isNaN(m) ? 0 : m;
  };

  const validate = () => {
    if (!title.trim()) return "Title is required";

    if (title.length > 50) return "Title cannot exceed 50 characters";

    if (!description.trim()) return "Description is required";

    if (description.length > 150)
      return "Description cannot exceed 150 characters";

    const dur = durationToMinutes();
    if (!dur || dur <= 0) return "Duration is required";

    const cleanSteps = steps.map((x) => x.trim()).filter(Boolean);
    if (cleanSteps.length === 0) return "At least one step is required";

    if (!difficulty) return "Difficulty level is required";

    if (!devArea) return "Development area is required";

    if (!ageGroup) return "Age group is required";

    // image is optional → no check
    return "";
  };

  // -----------------------------
  // Load existing routine
  // -----------------------------
  useEffect(() => {
    const fetchOne = async () => {
      try {
        setLoading(true);
        // setError("");
        // setSuccessMsg("");

        const res = await getSystemActivityByIdService(id);
        const a = res?.data;

        setTitle(a?.title || "");
        setDescription(a?.description || "");
        setMinutes(String(clamp60(a?.estimated_duration_minutes || 0)));
        setDifficulty(a?.difficulty_level || "");
        setDevArea(a?.development_area || "");
        setAgeGroup(a?.age_group || "");

        const stepList = (a?.steps || []).map((s) => s?.instruction || "");
        setSteps(stepList.length ? stepList : ["", ""]);

        const firstUrl = (a?.media_links && a.media_links[0]) || "";
        setExistingImageUrl(firstUrl);
        setImageFile(null);
        setImagePreview("");
      } catch (e) {
        setError(e?.message || "Failed to load routine");
      } finally {
        setLoading(false);
      }
    };

    fetchOne();
  }, [id]);

  // local image preview
  useEffect(() => {
    if (!imageFile) {
      setImagePreview("");
      return;
    }
    const url = URL.createObjectURL(imageFile);
    setImagePreview(url);
    return () => URL.revokeObjectURL(url);
  }, [imageFile]);

  // -----------------------------
  // Submit update
  // -----------------------------

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
    };

    try {
      setSubmitting(true);

      await updateSystemActivityService(id, payload);

      Swal.fire({
        icon: "success",
        title: "Routine Updated",
        text: "The routine was updated successfully.",
        confirmButtonColor: "#BD9A6B",
      }).then(() => {
        navigate(`/routine_detail/${id}`);
      });
    } catch (err) {
      const msg =
        err?.response?.data?.error ||
        err?.response?.data?.message ||
        err?.message ||
        "Failed to update routine";

      Swal.fire({
        icon: "error",
        title: "Update Failed",
        text: msg,
        confirmButtonColor: "#BD9A6B",
      });
    } finally {
      setSubmitting(false);
    }
  };

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

            {/* Loading state */}
            {loading && (
              <div className="mx-auto w-[760px] max-w-[92%] text-center text-[#BD9A6B] py-24">
                Loading...
              </div>
            )}

            {!loading && (
              <form
                onSubmit={onSubmit}
                className="mx-auto w-[760px] max-w-[92%] bg-[#E9DDCC] rounded-[14px]
                           shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                           px-14 py-12 border border-[#BD9A6B]/40"
              >
                <h2 className="text-center text-[22px] font-semibold text-[#BD9A6B] underline underline-offset-4">
                  Edit Routine
                </h2>

                {/* Illustration */}
                <div className="mt-8 flex justify-center">
                  <img
                    src={createRoutineImg}
                    alt="routine"
                    className="h-[150px] w-auto object-contain"
                  />
                </div>

                {/* Title */}
                <div className="mt-10 grid grid-cols-[120px_1fr] gap-6 items-center">
                  <label className="text-[#BD9A6B] text-sm font-semibold">
                    Title :
                  </label>

                  <div className="relative">
                    <input
                      value={title}
                      maxLength={50}
                      onChange={(e) => setTitle(e.target.value)}
                      className="w-full bg-transparent border-b border-[#BD9A6B]/60
                 focus:border-[#BD9A6B] outline-none py-2 text-sm text-[#8F6F4C]"
                    />

                    <span className="absolute right-0 -bottom-4 text-[11px] text-[#BD9A6B] opacity-80">
                      {title.length}/50
                    </span>
                  </div>
                </div>

                {/* Description */}
                <div className="mt-6 grid grid-cols-[120px_1fr] gap-6">
                  <label className="text-[#BD9A6B] text-sm font-semibold pt-2">
                    Description :
                  </label>

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

                    <span className="absolute right-3 bottom-2 text-[11px] text-[#BD9A6B] opacity-80">
                      {description.length}/150
                    </span>
                  </div>
                </div>

                {/* Duration (UI style) */}
                <div className="mt-6 grid grid-cols-[120px_1fr] gap-6 items-center">
                  <label className="text-[#BD9A6B] text-sm font-semibold">
                    Duration :
                  </label>

                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-3">
                      <input
                        value={minutes}
                        inputMode="numeric"
                        onChange={(e) => setMinutesClamped(e.target.value)}
                        onBlur={() => {
                          if (minutes === "") return;
                          setMinutesClamped(minutes);
                        }}
                        className="w-[60px] h-[50px] text-center rounded-[18px]
                                   border border-[#BD9A6B] bg-[#E9DDCC]
                                   outline-none text-[18px] font-semibold text-[#8F6F4C]
                                   shadow-[0_10px_18px_rgba(0,0,0,0.12)]"
                      />

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
                    <button
                      type="button"
                      onClick={addStep}
                      className="absolute -right-2 -top-2 h-9 w-9 rounded-full bg-[#F7EAD7]
                                 shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                                 grid place-items-center transition-all duration-200
                                 hover:brightness-95 hover:shadow-[0_14px_22px_rgba(0,0,0,0.22)]
                                 hover:-translate-y-[1px] active:translate-y-0"
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

                {/* Elegant dropdown (keeps your colors, removes blue focus ring) */}
                <FieldSelect
                  label="Difficulty Level :"
                  value={difficulty}
                  onChange={setDifficulty}
                  options={[
                    { value: "easy", label: "Easy" },
                    { value: "medium", label: "Medium" },
                    { value: "hard", label: "Hard" },
                  ]}
                />

                <FieldSelect
                  label="Development Area :"
                  value={devArea}
                  onChange={setDevArea}
                  options={[
                    { value: "self-care", label: "Self - Care" },
                    { value: "motor", label: "Motor" },
                    { value: "language", label: "Language" },
                    { value: "cognitive", label: "Cognitive" },
                    { value: "social", label: "Social" },
                    { value: "emotional", label: "Emotional" },
                  ]}
                />

                <FieldSelect
                  label="Age Group :"
                  value={ageGroup}
                  onChange={setAgeGroup}
                  options={Array.from({ length: 10 }).map((_, i) => ({
                    value: String(i + 1),
                    label: String(i + 1),
                  }))}
                />

                {/* Media */}
                <div className="mt-4 grid grid-cols-[160px_1fr] gap-6 items-start">
                  <label className="text-[#BD9A6B] text-sm font-semibold pt-2">
                    Media (Images) :
                  </label>

                  <div>
                    <div className="flex items-center gap-3">
                      <label
                        className="flex-1 rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                                   px-4 py-2 text-sm text-[#8F6F4C] outline-none cursor-pointer
                                   flex items-center justify-between shadow-[0_6px_10px_rgba(0,0,0,0.10)]
                                   hover:shadow-[0_10px_16px_rgba(0,0,0,0.14)] transition"
                      >
                        <span className="truncate">
                          {imageFile
                            ? imageFile.name
                            : existingImageUrl
                              ? "Existing image (optional change)"
                              : "Choose image"}
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

                      {(imageFile || existingImageUrl) && (
                        <button
                          type="button"
                          onClick={() => {
                            setImageFile(null);
                            setExistingImageUrl("");
                          }}
                          className="h-10 w-10 rounded-full bg-white/70
                                     shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                                     grid place-items-center hover:brightness-95"
                          title="Remove image"
                        >
                          <MdClose className="text-[#BD9A6B]" />
                        </button>
                      )}
                    </div>

                    {/* Preview (new file first, else existing url) */}
                    {(imagePreview || existingImageUrl) && (
                      <div className="mt-4">
                        <p className="text-xs text-[#BD9A6B] mb-2">Preview:</p>
                        <img
                          src={imagePreview || existingImageUrl}
                          alt="preview"
                          className="h-[120px] w-auto rounded-[12px] border border-[#BD9A6B]/40
                                     shadow-[0_8px_14px_rgba(0,0,0,0.12)] object-contain"
                        />
                      </div>
                    )}
                  </div>
                </div>

                {/* Submit right side */}
                <div className="mt-10 flex justify-end pr-2">
                  <button
                    disabled={submitting}
                    type="submit"
                    className="w-[160px] rounded-[10px] bg-[#BD9A6B] py-2 text-sm font-semibold text-white
                               shadow-[0_10px_16px_rgba(0,0,0,0.20)] hover:brightness-95
                               disabled:opacity-60 disabled:cursor-not-allowed"
                  >
                    {submitting ? "Updating..." : "Update"}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}

// ✅ Elegant dropdown component (same colors, brown focus ring, no default blue)
function FieldSelect({ label, value, onChange, options }) {
  return (
    <div className="mt-4 grid grid-cols-[160px_1fr] gap-6 items-center">
      <label className="text-[#BD9A6B] text-sm font-semibold">{label}</label>

      <div className="relative">
        <select
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="w-full appearance-none rounded-[12px] border border-[#BD9A6B] bg-[#E9DDCC]
                     px-4 py-2 pr-10 text-sm text-[#8F6F4C]
                     outline-none shadow-[0_6px_10px_rgba(0,0,0,0.10)]
                     hover:shadow-[0_10px_16px_rgba(0,0,0,0.14)]
                     focus:ring-2 focus:ring-[#BD9A6B]/50 focus:border-[#BD9A6B]
                     transition"
        >
          <option value="">Select</option>
          {options.map((op) => (
            <option key={op.value} value={op.value}>
              {op.label}
            </option>
          ))}
        </select>

        <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-[#BD9A6B]">
          ▾
        </span>
      </div>
    </div>
  );
}
