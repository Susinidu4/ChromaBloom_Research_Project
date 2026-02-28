import React, { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import { FiSearch } from "react-icons/fi";
import { MdDelete } from "react-icons/md";
import { HiDotsHorizontal } from "react-icons/hi";
import AdminLayout from "../Admin_Management/AdminLayout";

import {
  getAllRecommendationsService,
  deleteRecommendationByIdService,
} from "../../../services/Admin/Parental_Stress_Monitoring/AdminRecommendationService";

const LEVELS = ["All", "Low", "Medium", "High", "Critical"];
const FILTER_BY = ["Stress Level", "Category"];

export default function StressSupportRecommendationList() {
  const navigate = useNavigate();

  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [query, setQuery] = useState("");
  const [filterBy, setFilterBy] = useState("Stress Level");
  const [filterValue, setFilterValue] = useState("All");

  useEffect(() => {
    if (!error) return;

    Swal.fire({
      icon: "error",
      title: "Failed",
      text: error,
      confirmButtonColor: "#BD9A6B",
    });
  }, [error]);


  // ✅ fetch from backend
  useEffect(() => {
    let alive = true;

    const fetchAll = async () => {
      try {
        setLoading(true);
        setError("");

        const res = await getAllRecommendationsService();

        // backend: { success, count, data }
        const list = res?.data?.data ?? [];

        // ✅ normalize for UI
        const mapped = list.map((r) => ({
          id: r.recommendationId || r._id, // prefer your REC-xxxx id
          title: r.title || "Untitled",
          level: r.level || "Low", // Low/Medium/High/Critical
          category: r.category || "rest",
        }));

        if (alive) setRows(mapped);
      } catch (e) {
        if (alive)
          setError(
            e?.response?.data?.message || e.message || "Failed to fetch",
          );
      } finally {
        if (alive) setLoading(false);
      }
    };

    fetchAll();
    return () => {
      alive = false;
    };
  }, []);

  const categories = useMemo(() => {
    const s = new Set(rows.map((r) => r.category).filter(Boolean));
    return ["All", ...Array.from(s)];
  }, [rows]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();

    return rows.filter((r) => {
      const matchesSearch =
        !q ||
        (r.title || "").toLowerCase().includes(q) ||
        (r.id || "").toLowerCase().includes(q);

      let matchesFilter = true;

      if (filterBy === "Stress Level" && filterValue !== "All") {
        matchesFilter = r.level === filterValue;
      }

      if (filterBy === "Category" && filterValue !== "All") {
        matchesFilter = r.category === filterValue;
      }

      return matchesSearch && matchesFilter;
    });
  }, [rows, query, filterBy, filterValue]);

  async function onDelete(id) {
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
      await deleteRecommendationByIdService(id);

      setRows((prev) => prev.filter((x) => x.id !== id));

      await Swal.fire({
        icon: "success",
        title: "Deleted",
        text: "Recommendation deleted successfully.",
        confirmButtonColor: "#BD9A6B",
      });
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
  }

  const filterOptions = filterBy === "Stress Level" ? LEVELS : categories;

  return (
    <AdminLayout>
      <div className="min-h-screen bg-[#F3E8E8] px-10 py-8 text-[#BD9A6B]">
        {/* Header row */}
        <div className="flex items-center justify-between">
          <h2 className="text-[22px] font-bold text-[#BD9A6B] underline underline-offset-4">
            Stress Support Recommendation List
          </h2>

          <button
            onClick={() => navigate("/Stress_recommendation_create")}
            className="flex items-center gap-3 rounded-xl bg-[#BD9A6B] px-6 py-2.5 text-white shadow-[0_10px_18px_rgba(0,0,0,0.12)] active:scale-[0.99] mt-5"
          >
            <span className="text-xl leading-none">+</span>
            <span className="text-sm font-semibold">Add New</span>
          </button>
        </div>

        {/* Toolbar */}
        <div className="mt-8 flex items-center justify-between gap-6">
          {/* Search */}
          <div className="relative w-[320px] max-w-full">
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="w-full bg-[#D9D9D9]/50 rounded-full h-8 pl-4 pr-10 outline-none text-sm text-[#7A6357]"
              placeholder="Search by Title"
              aria-label="Search"
            />
            <FiSearch className="absolute right-3 top-1/2 -translate-y-1/2 text-base text-[#6F5E4C]" />
          </div>

          {/* Filter */}
          <div className="flex items-center gap-3">
            <span className="text-sm font-semibold text-[#BD9A6B]">
              Filter By :
            </span>

            <select
              className="h-9 rounded-xl border border-[#BD9A6B] px-3 text-sm outline-none"
              value={filterBy}
              onChange={(e) => {
                setFilterBy(e.target.value);
                setFilterValue("All");
              }}
            >
              {FILTER_BY.map((x) => (
                <option key={x} value={x}>
                  {x}
                </option>
              ))}
            </select>

            <select
              className="h-9 min-w-[160px] rounded-xl border border-[#BD9A6B] px-3 text-sm outline-none"
              value={filterValue}
              onChange={(e) => setFilterValue(e.target.value)}
            >
              {filterOptions.map((x) => (
                <option key={x} value={x}>
                  {x}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* ✅ Card wrapper for table + scroll */}
        <div className="bg-[#EFE6E3] rounded-[14px] px-10 py-1 shadow-[0_12px_22px_rgba(0,0,0,0.12)] mt-10 pb-6">
          {/* table header */}
          <div className="grid grid-cols-[1.4fr_0.55fr_0.8fr_0.35fr] border-b border-[#D9C8C8] px-5 py-3 text-sm font-bold text-[#B79C74]">
            <div>Title</div>
            <div>Stress Level</div>
            <div>Category</div>
            <div />
          </div>

          {/* scroll body */}
          <div
            className="h-[360px] overflow-auto px-3 pb-3 pr-2 ssr-scroll"
            style={{
              scrollbarWidth: "thin",
              scrollbarColor: "#B79C74 #E8DCDC",
            }}
          >
            <style>{`
              .ssr-scroll::-webkit-scrollbar{width:10px;}
              .ssr-scroll::-webkit-scrollbar-track{background:#E8DCDC;border-radius:10px;}
              .ssr-scroll::-webkit-scrollbar-thumb{background:#B79C74;border-radius:10px;}
            `}</style>

            {loading && (
              <div className="px-3 py-6 text-sm text-[#8B7A68]">
                Loading recommendations...
              </div>
            )}



            {!loading &&
              filtered.map((r) => (
                <div
                  key={r.id}
                  className="grid grid-cols-[1.4fr_0.55fr_0.8fr_0.35fr] items-center border-b border-[#E1D3D3] px-2 py-3 text-sm"
                >
                  <div className="text-[#9A7E66]">{r.title}</div>
                  <div className="text-[#9A7E66]">{r.level}</div>
                  <div className="text-[#9A7E66]">{r.category}</div>

                  <div className="flex justify-end gap-3">
                    <button
                      title="Delete"
                      disabled={loading}
                      onClick={() => onDelete(r.id)}
                      className="grid h-9 w-9 place-items-center rounded-full text-[22px] text-[#5B2B22] hover:bg-[#c7c2c2] active:scale-[0.96]"
                    >
                      <MdDelete size={30} />
                    </button>

                    <button
                      title="More"
                      onClick={() =>
                        navigate(`/stress_recommendation_detail/${r.id}`)
                      }
                      className="grid h-9 w-9 place-items-center rounded-full bg-[#BD9A6B] text-lg text-white shadow hover:opacity-95 active:scale-[0.96]"
                    >
                      <HiDotsHorizontal size={24} />
                    </button>
                  </div>
                </div>
              ))}

            {!loading && filtered.length === 0 && (
              <div className="px-3 py-6 text-sm text-[#8B7A68]">
                No recommendations found.
              </div>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
