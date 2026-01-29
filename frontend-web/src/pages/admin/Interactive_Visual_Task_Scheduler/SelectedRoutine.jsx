import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { FaArrowLeft, FaRegEdit } from "react-icons/fa";
import { MdDelete } from "react-icons/md";
import { FiClock } from "react-icons/fi";
import AdminLayout from "../AdminLayout";
import { getSystemActivityByIdService } from "../../../services/Admin/Interactive_Visual_Task_Scheduler/adminRoutineService";

export default function SelectedRoutine() {
  const navigate = useNavigate();
  const { id } = useParams();

  const [routine, setRoutine] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchOne = async () => {
      try {
        setLoading(true);
        setError("");

        const res = await getSystemActivityByIdService(id);

        const a = res?.data;

        const mapped = {
          id: a?._id,
          title: a?.title || "Untitled",
          duration: a?.estimated_duration_minutes || 0,
          description: a?.description || "No description yet.",
          difficulty: a?.difficulty_level || "",
          devArea: a?.development_area || "",
          steps: (a?.steps || []).map((s) => s.instruction),
          imageUrl:
            (a?.media_links && a.media_links[0]) ||
            "https://images.emojiterra.com/google/noto-emoji/unicode-15.1/color/512px/1f466.png",
        };

        setRoutine(mapped);
      } catch (e) {
        setError(e?.message || "Failed to load routine");
      } finally {
        setLoading(false);
      }
    };

    fetchOne();
  }, [id]);

  const onBack = () => navigate(-1);
  const onEdit = () => alert(`Edit routine ${id} (connect later)`);
  const onDelete = () => alert(`Delete routine ${id} (connect later)`);

  return (
    <AdminLayout>
      <div className="w-full h-full bg-[#F3ECE7]">
        <div className="px-10 py-10">
          <div className="relative min-h-[640px] rounded-[14px] px-10 py-10">
            {/* Back */}
            <button
              onClick={onBack}
              className="absolute left-10 top-10 h-10 w-10 rounded-full bg-white/70
                         shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                         grid place-items-center hover:brightness-95 active:scale-[0.98]"
              title="Back"
            >
              <FaArrowLeft className="text-[#BD9A6B]" />
            </button>

            {/* Loading / Error */}
            {loading && (
              <div className="mx-auto w-[680px] max-w-[92%] text-center text-[#BD9A6B] py-20">
                Loading...
              </div>
            )}

            {error && (
              <div className="mx-auto w-[680px] max-w-[92%] text-center text-red-500 py-20">
                {error}
              </div>
            )}

            {/* Card */}
            {!loading && !error && routine && (
              <div
                className="mx-auto w-[680px] max-w-[92%] bg-[#E9DDCC] rounded-[14px]
                            shadow-[0_10px_18px_rgba(0,0,0,0.18)] px-10 py-10"
              >
                {/* Title + icons */}
                <div className="flex items-start justify-between">
                  <div>
                    <h2 className="text-[22px] font-semibold text-[#BD9A6B]">
                      {routine.title}
                    </h2>

                    <div className="mt-2 flex items-center gap-2 text-sm text-[#BD9A6B] opacity-90">
                      <FiClock />
                      <span>
                        <span className="font-semibold">Estimated Duration:</span>{" "}
                        {routine.duration} minutes
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <button
                      onClick={onEdit}
                      className="text-[#BD9A6B] hover:brightness-90"
                      title="Edit"
                    >
                      <FaRegEdit size={20} />
                    </button>

                    <button
                      onClick={onDelete}
                      className="text-[#6B3B30] hover:brightness-90"
                      title="Delete"
                    >
                      <MdDelete size={22} />
                    </button>
                  </div>
                </div>

                {/* Image */}
                <div className="mt-8 flex justify-center">
                  <img
                    src={routine.imageUrl}
                    alt="routine"
                    className="h-[220px] w-auto object-contain"
                  />
                </div>

                {/* Description */}
                <p className="mt-10 text-[13px] leading-6 text-[#B79A6A] opacity-90">
                  {routine.description}
                </p>

                {/* Steps */}
                <div className="mt-8">
                  <p className="text-sm font-semibold text-[#BD9A6B]">STEPS:</p>
                  <ol className="mt-3 list-decimal pl-6 text-[13px] text-[#B79A6A] space-y-2">
                    {routine.steps?.length ? (
                      routine.steps.map((s, idx) => <li key={idx}>{s}</li>)
                    ) : (
                      <li>No steps added.</li>
                    )}
                  </ol>
                </div>

                {/* Bottom meta */}
                <div className="mt-10 space-y-3 text-[13px] text-[#BD9A6B]">
                  <div className="flex gap-3">
                    <span className="font-semibold">DIFFICULTY LEVEL</span>
                    <span>:</span>
                    <span className="text-[#B79A6A]">{routine.difficulty}</span>
                  </div>

                  <div className="flex gap-3">
                    <span className="font-semibold">DEVELOPMENT AREA</span>
                    <span>:</span>
                    <span className="text-[#B79A6A]">{routine.devArea}</span>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
