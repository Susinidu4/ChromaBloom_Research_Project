import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Swal from "sweetalert2";
import { FaArrowLeft, FaRegEdit } from "react-icons/fa";
import { MdDelete } from "react-icons/md";
import AdminLayout from "../Admin_Management/AdminLayout";

import {
  getRecommendationByIdService,
  deleteRecommendationByIdService,
} from "../../../services/Admin/Parental_Stress_Monitoring/AdminRecommendationService";

export default function RecommendationDetail() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [rec, setRec] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Show error alert if there's an error
  useEffect(() => {
    if (!error) return;

    Swal.fire({
      icon: "error",
      title: "Failed",
      text: error,
      confirmButtonColor: "#BD9A6B",
    });
  }, [error]);

  // Handlers for back, edit, delete actions
  const onBack = () => navigate("/stress_recommendation_list");
  // Edit navigates to the edit page for this recommendation
  const onEdit = () => {
    navigate(`/stress_recommendation_edit/${id}`);
  };

  // Delete shows a confirmation dialog, then calls the delete service, and shows success/error alerts accordingly
  const onDelete = async () => {
    if (!rec?.id) return;

    const r = await Swal.fire({
      title: "Delete this recommendation?",
      text: "This action will permanently remove it.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#6B3B30",
      confirmButtonText: "Yes, Delete",
      cancelButtonText: "No",
    });

    if (!r.isConfirmed) {
      await Swal.fire({
        icon: "info",
        title: "Cancelled",
        text: "Deletion cancelled.",
        confirmButtonColor: "#BD9A6B",
      });
      return;
    }

    try {
      // call the delete service with the recommendation id
      await deleteRecommendationByIdService(rec.id);

      await Swal.fire({
        icon: "success",
        title: "Deleted",
        text: "Recommendation deleted successfully.",
        confirmButtonColor: "#BD9A6B",
      });

      // after deletion,
      navigate("/stress_recommendation_list");
    } catch (e) {
      const msg =
        e?.response?.data?.message ||
        e?.response?.data?.error ||
        e?.message ||
        "Delete failed";

      await Swal.fire({
        icon: "error",
        title: "Failed",
        text: msg,
        confirmButtonColor: "#BD9A6B",
      });
    }
  };

  // fetch the recommendation details by id when component mounts or id changes.
  useEffect(() => {
    let alive = true;

    const fetchOne = async () => {
      try {
        setLoading(true);
        setError("");

        // call the getRecommendationByIdService with the id from URL params.
        const res = await getRecommendationByIdService(id);
        const r = res?.data?.data;

        // map the response to the format needed for display, with fallbacks for missing fields
        const mapped = {
          id: r?.recommendationId || r?._id,
          title: r?.title || "Untitled",
          message: r?.message || "",
          stressLevel: r?.level || "Low",
          category: r?.category || "",
          duration: r?.duration ? `${r.duration} min` : "",
          steps: Array.isArray(r?.steps)
            ? r.steps
                .sort((a, b) => (a.step_number ?? 0) - (b.step_number ?? 0))
                .map((s) => s.instruction)
            : [],
          source: r?.source || "",
        };

        if (alive) setRec(mapped);
      } catch (e) {
        if (alive)
          setError(
            e?.response?.data?.message || e.message || "Failed to fetch",
          );
      } finally {
        if (alive) setLoading(false);
      }
    };

    fetchOne();
    return () => {
      alive = false;
    };
  }, [id]);

  return (
    <AdminLayout>
      <div className="w-full min-h-screen bg-[#F3E8E8]">
        <div className="px-4 py-6 sm:px-6 sm:py-8 md:px-8 lg:px-10">
          <div className="relative min-h-[630px] rounded-[14px] px-0 py-4 sm:px-4 sm:py-6 md:px-8 lg:px-10">
            {/* Back button */}
            <button
              onClick={onBack}
              className="absolute left-0 top-0 h-10 w-10 rounded-full bg-white/70
           shadow-[0_10px_18px_rgba(0,0,0,0.18)]
           grid place-items-center hover:brightness-95 active:scale-[0.98]
           sm:left-4 sm:top-4 md:left-8 md:top-8 lg:left-10 lg:top-10"
            >
              <FaArrowLeft className="text-[#BD9A6B]" />
            </button>

            {loading && (
              <div className="mx-auto w-full max-w-[680px] px-2 text-sm text-[#8B7A68] sm:max-w-[92%] sm:px-0">
                Loading...
              </div>
            )}

            {/* Card */}
            {rec && (
              <div
                className="mx-auto w-full max-w-[420px] rounded-[14px] bg-[#E9DDCC]
             shadow-[0_10px_18px_rgba(0,0,0,0.18)] px-4 py-6
             sm:max-w-[60%] sm:px-6 sm:py-8 md:px-8 md:py-10 lg:px-10"
              >
                {/* Title + icons */}
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <h2 className="mt-3 text-[18px] font-semibold text-[#BD9A6B] sm:text-[20px] lg:text-[22px]">
                    {rec.title}
                  </h2>

                  <div className="mt-2 flex items-center gap-3 self-start">
                    {/* Edit button */}
                    <button
                      onClick={onEdit}
                      className="text-[#BD9A6B] hover:brightness-90"
                      title="Edit"
                    >
                      <FaRegEdit size={20} />
                    </button>

                    {/* Delete button */}
                    <button
                      onClick={onDelete}
                      disabled={loading}
                      className="text-[#6B3B30] hover:brightness-90"
                      title="Delete"
                    >
                      <MdDelete size={22} />
                    </button>
                  </div>
                </div>

                {/* MESSAGE label */}
                <div className="mt-8 text-[13px] text-[#BD9A6B] font-semibold">
                  MESSAGE:
                </div>

                {/* Message text (no div inside p) */}
                <p className="mt-3 max-w-full text-[13px] leading-6 text-[#B79A6A] opacity-90 md:max-w-[560px]">
                  {rec.message}
                </p>

                {/* Field rows (aligned like screenshot) */}
                <div className="mt-8 space-y-4 text-[13px] text-[#BD9A6B]">
                  <div className="flex flex-wrap gap-2 sm:gap-3">
                    <span className="w-[120px] font-semibold">
                      STRESS LEVEL
                    </span>
                    <span>:</span>
                    <span className="break-words text-[#B79A6A]">
                      {rec.stressLevel}
                    </span>
                  </div>

                  {/* Category row */}
                  <div className="flex flex-wrap gap-2 sm:gap-3">
                    <span className="w-[120px] font-semibold">CATEGORY</span>
                    <span>:</span>
                    <span className="break-words text-[#B79A6A]">
                      {rec.category}
                    </span>
                  </div>

                  {/* Duration row */}
                  <div className="flex flex-wrap gap-2 sm:gap-3">
                    <span className="w-[120px] font-semibold">DURATION</span>
                    <span>:</span>
                    <span className="break-words text-[#B79A6A]">
                      {rec.duration}
                    </span>
                  </div>
                </div>

                {/* STEPS */}
                <div className="mt-8">
                  <p className="text-[13px] font-semibold text-[#BD9A6B]">
                    STEPS:
                  </p>

                  <ol className="mt-4 list-decimal space-y-3 pl-6 text-[13px] text-[#B79A6A] sm:pl-8 md:pl-10">
                    {rec.steps?.length ? (
                      rec.steps.map((s, idx) => <li key={idx}>{s}</li>)
                    ) : (
                      <li>No steps provided.</li>
                    )}
                  </ol>
                </div>

                {/* SOURCE */}
                <div className="mt-8 text-[13px] text-[#BD9A6B]">
                  <div className="flex flex-wrap gap-2 sm:gap-3">
                    <span className="w-[120px] font-semibold">SOURCE</span>
                    <span>:</span>
                    <span className="break-words text-[#B79A6A]">
                      {rec.source}
                    </span>
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
