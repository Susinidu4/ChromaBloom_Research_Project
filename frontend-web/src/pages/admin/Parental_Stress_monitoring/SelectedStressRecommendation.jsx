import React, { useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import Swal from "sweetalert2";
import { FaArrowLeft, FaRegEdit } from "react-icons/fa";
import { MdDelete } from "react-icons/md";
import AdminLayout from "../AdminLayout";

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
  

  useEffect(() => {
    if (!error) return;

    Swal.fire({
      icon: "error",
      title: "Failed",
      text: error,
      confirmButtonColor: "#BD9A6B",
    });
  }, [error]);

  const onBack = () => navigate("/stress_recommendation_list");
  const onEdit = () => {
    navigate(`/stress_recommendation_edit/${id}`);
  };

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
      await deleteRecommendationByIdService(rec.id);

      await Swal.fire({
        icon: "success",
        title: "Deleted",
        text: "Recommendation deleted successfully.",
        confirmButtonColor: "#BD9A6B",
      });

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

  useEffect(() => {
    let alive = true;

    const fetchOne = async () => {
      try {
        setLoading(true);
        setError("");

        const res = await getRecommendationByIdService(id);
        const r = res?.data?.data;

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
      <div className="w-full h-full bg-[#F3E8E8]">
        <div className="px-10 py-8">
          <div className="relative min-h-[630px] rounded-[14px] px-10 py-8">
            {/* Back */}
            <button
              onClick={onBack}
              className="absolute left-10 top-10 h-10 w-10 rounded-full bg-white/70
                         shadow-[0_10px_18px_rgba(0,0,0,0.18)]
                         grid place-items-center hover:brightness-95 active:scale-[0.98]"
            >
              <FaArrowLeft className="text-[#BD9A6B]" />
            </button>

            {loading && (
              <div className="mx-auto w-[680px] max-w-[92%] text-sm text-[#8B7A68]">
                Loading...
              </div>
            )}

            {/* Card */}
            {rec && (
              <div
                className="mx-auto w-[680px] max-w-[92%] bg-[#E9DDCC] rounded-[14px]
                           shadow-[0_10px_18px_rgba(0,0,0,0.18)] px-10 py-10"
              >
                {/* Title + icons */}
                <div className="flex items-start justify-between">
                  <h2 className="text-[22px] font-semibold text-[#BD9A6B] mt-3">
                    {rec.title}
                  </h2>

                  <div className="flex items-center gap-3 mt-2">
                    <button
                      onClick={onEdit}
                      className="text-[#BD9A6B] hover:brightness-90"
                      title="Edit"
                    >
                      <FaRegEdit size={20} />
                    </button>

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
                <p className="mt-3 text-[13px] leading-6 text-[#B79A6A] opacity-90 max-w-[560px]">
                  {rec.message}
                </p>

                {/* Field rows (aligned like screenshot) */}
                <div className="mt-8 space-y-4 text-[13px] text-[#BD9A6B]">
                  <div className="flex gap-3">
                    <span className="font-semibold w-[120px]">
                      STRESS LEVEL
                    </span>
                    <span>:</span>
                    <span className="text-[#B79A6A]">{rec.stressLevel}</span>
                  </div>

                  <div className="flex gap-3">
                    <span className="font-semibold w-[120px]">CATEGORY</span>
                    <span>:</span>
                    <span className="text-[#B79A6A]">{rec.category}</span>
                  </div>

                  <div className="flex gap-3">
                    <span className="font-semibold w-[120px]">DURATION</span>
                    <span>:</span>
                    <span className="text-[#B79A6A]">{rec.duration}</span>
                  </div>
                </div>

                {/* STEPS */}
                <div className="mt-8">
                  <p className="text-[13px] font-semibold text-[#BD9A6B]">
                    STEPS:
                  </p>

                  <ol className="mt-4 list-decimal pl-10 text-[13px] text-[#B79A6A] space-y-3">
                    {rec.steps?.length ? (
                      rec.steps.map((s, idx) => <li key={idx}>{s}</li>)
                    ) : (
                      <li>No steps provided.</li>
                    )}
                  </ol>
                </div>

                {/* SOURCE */}
                <div className="mt-8 text-[13px] text-[#BD9A6B]">
                  <div className="flex gap-3">
                    <span className="font-semibold w-[120px]">SOURCE</span>
                    <span>:</span>
                    <span className="text-[#B79A6A]">{rec.source}</span>
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
