import React, { useEffect, useMemo, useState } from "react";
import Swal from "sweetalert2";

import { HiPlus } from "react-icons/hi";
import { FiSearch } from "react-icons/fi";
import { MdDelete } from "react-icons/md";
import { HiDotsHorizontal } from "react-icons/hi";
import { useNavigate } from "react-router-dom";

import AdminLayout from "../Admin_Management/AdminLayout";

import {
  getAllSystemActivitiesService,
  deleteSystemActivityByIdService,
} from "../../../services/Admin/Interactive_Visual_Task_Scheduler/adminRoutineService.js";

export default function RoutineList() {
  const navigate = useNavigate();

  // for search input
  const [search, setSearch] = useState("");

  // all routines fetched from backend
  const [rows, setRows] = useState([]);

  // loading state while fetching data
  const [loading, setLoading] = useState(true);

  // what user is selecting right now (not applied yet)
  const [pendingDifficulty, setPendingDifficulty] = useState("");
  const [pendingDevArea, setPendingDevArea] = useState("");
  const [pendingAgeGroup, setPendingAgeGroup] = useState("");

  // what is actually applied to the table after clicking Filter
  const [appliedDifficulty, setAppliedDifficulty] = useState("");
  const [appliedDevArea, setAppliedDevArea] = useState("");
  const [appliedAgeGroup, setAppliedAgeGroup] = useState("");

  // common alert for errors
  const alertError = (msg) =>
    Swal.fire({
      icon: "error",
      title: "Error",
      text: msg || "Something went wrong",
      confirmButtonColor: "#BD9A6B",
    });

  // common alert for success messages
  const alertSuccess = (msg) =>
    Swal.fire({
      icon: "success",
      title: "Success",
      text: msg || "Done",
      confirmButtonColor: "#BD9A6B",
    });

  useEffect(() => {
    const fetchActivities = async () => {
      try {
        setLoading(true);

        // fetch all routines from backend
        const res = await getAllSystemActivitiesService();

        const mapped = (res.data || []).map((a) => ({
          id: a._id,
          title: a.title || "Untitled",
          age: a.age_group || "",
          difficulty: a.difficulty_level || "",
          dev: a.development_area || "",
          duration: a.estimated_duration_minutes || 0,
        }));

        setRows(mapped);
      } catch (e) {
        const msg =
          e?.response?.data?.message || e?.message || "Failed to load routines";
        alertError(msg);
      } finally {
        setLoading(false);
      }
    };

    fetchActivities();
  }, []);

  // filter + search logic, useMemo to avoid unnecessary recalculations
  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();

    return rows.filter((r) => {
      const matchSearch = !q || r.title.toLowerCase().includes(q);
      const matchDiff =
        !appliedDifficulty || r.difficulty === appliedDifficulty;
      const matchDev = !appliedDevArea || r.dev === appliedDevArea;
      const matchAge = !appliedAgeGroup || String(r.age) === appliedAgeGroup;

      return matchSearch && matchDiff && matchDev && matchAge;
    });
  }, [rows, search, appliedDifficulty, appliedDevArea, appliedAgeGroup]);

  // Navigate to create page
  const onAddNew = () => navigate("/routine_create");

  // Delete routine with confirmation
  const onDelete = async (id) => {
    const result = await Swal.fire({
      title: "Delete routine?",
      text: "This action cannot be undone.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, delete",
      cancelButtonText: "Cancel",
      confirmButtonColor: "#6B3B30",
      cancelButtonColor: "#BD9A6B",
    });

    if (!result.isConfirmed) return;

    try {
      await deleteSystemActivityByIdService(id);
      setRows((prev) => prev.filter((r) => r.id !== id));

      alertSuccess("Routine deleted successfully.");
    } catch (e) {
      const msg = e?.response?.data?.message || e?.message || "Delete failed";
      alertError(msg);
    }
  };

  // Navigate to detail page
  const onMore = (id) => navigate(`/routine_detail/${id}`);

  // Apply filters to the table
  const onFilter = () => {
    setAppliedDifficulty(pendingDifficulty);
    setAppliedDevArea(pendingDevArea);
    setAppliedAgeGroup(pendingAgeGroup);
  };

  // Clear filters and reset pending/applied states
  const onClearFilter = () => {
    setPendingDifficulty("");
    setPendingDevArea("");
    setPendingAgeGroup("");
    setAppliedDifficulty("");
    setAppliedDevArea("");
    setAppliedAgeGroup("");
  };

  return (
    <AdminLayout>
      <div className="w-full min-h-screen bg-[#F3E8E8]">
        {/* responsive padding */}
        <div className="px-4 sm:px-6 lg:px-10 py-6 sm:py-8 lg:py-10">
          {/* Top Row */}
          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
            <h1 className="text-[20px] sm:text-[22px] font-bold text-[#BD9A6B] underline underline-offset-4">
              Routine List
            </h1>

            {/* Add New button */}
            <button
              onClick={onAddNew}
              className="flex items-center justify-center gap-2 rounded-[10px] bg-[#BD9A6B] px-4 py-2 text-white
                       shadow-[0_10px_16px_rgba(0,0,0,0.20)] hover:brightness-95 active:translate-y-[1px]
                       w-full sm:w-auto"
            >
              <span className="grid h-8 w-8 place-items-center rounded-md">
                <HiPlus size={20} />
              </span>
              <span className="text-sm font-semibold">Add New</span>
            </button>
          </div>

          {/* Filters row (wrap + stack on mobile) */}
          <div className="mt-6 flex flex-col lg:flex-row lg:items-center lg:justify-end gap-3">
            <div className="flex flex-col sm:flex-row gap-3 w-full lg:w-auto">
              <SelectBox
                value={pendingDifficulty}
                onChange={setPendingDifficulty}
                placeholder="Difficulty Level"
                options={["easy", "medium", "hard"]}
              />

              <SelectBox
                value={pendingDevArea}
                onChange={setPendingDevArea}
                placeholder="Development Area"
                options={[
                  "social",
                  "motor",
                  "cognitive",
                  "language",
                  "emotional",
                  "self-care",
                ]}
              />

              <SelectBox
                value={pendingAgeGroup}
                onChange={setPendingAgeGroup}
                placeholder="Age Group"
                options={["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]}
              />
            </div>

            <div className="flex gap-3 w-full sm:w-auto">
              {/* Filter button */}
              <button
                onClick={onFilter}
                className="flex-1 sm:flex-none rounded-[10px] bg-[#B79A6A] px-8 py-2 text-sm font-semibold text-white
                         shadow-[0_10px_16px_rgba(0,0,0,0.20)] hover:brightness-95 active:translate-y-[1px]"
              >
                Filter
              </button>

              {/* Filter clear button */}
              <button
                onClick={onClearFilter}
                className="flex-1 sm:flex-none rounded-[10px] px-8 py-2 text-sm font-semibold text-[#BD9A6B]
                         shadow-[0_10px_16px_rgba(0,0,0,0.20)] border border-[#BD9A6B]
                         hover:bg-[#BD9A6B]/10 hover:shadow-[0_12px_20px_rgba(0,0,0,0.22)]
                         active:translate-y-[1px] transition-all duration-200"
              >
                Clear
              </button>
            </div>
          </div>

          {/* Search */}
          <div className="mt-4">
            <div className="relative w-full sm:w-[320px]">
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full bg-[#D9D9D9]/50 rounded-full py-2 pl-5 pr-10 outline-none text-sm text-[#7A6357]"
                placeholder="Search by Title"
              />
              <FiSearch
                className="absolute right-4 top-1/2 -translate-y-1/2 text-[#7A6357]"
                size={16}
              />
            </div>
          </div>

          {/* Table container */}
          <div className="bg-[#EFE6E3] rounded-[14px] px-4 sm:px-6 lg:px-10 py-4 shadow-[0_12px_22px_rgba(0,0,0,0.12)] mt-6">
            {/* horizontal scroll for small screens */}
            <div className="overflow-x-auto">
              <div className="min-w-[820px]">
                {/* Header */}
                <div className="grid grid-cols-[1.6fr_0.7fr_1fr_1.2fr_1.2fr_56px_56px] gap-3 px-2 pb-3 text-[13px] font-bold text-[#BD9A6B]">
                  <div>Title</div>
                  <div className="text-center">Age Group</div>
                  <div className="text-center">Difficulty Level</div>
                  <div className="text-center">Development Area</div>
                  <div className="text-center">Est. Duration (min)</div>
                  <div />
                  <div />
                </div>

                <div className="h-[1px] bg-[#D9C7BF]" />

                {/* Body scroll */}
                <div className="max-h-[360px] overflow-y-auto pr-2 custom-scroll">
                  {loading && (
                    <div className="py-10 text-center text-[#BD9A6B]">
                      Loading...
                    </div>
                  )}

                  {!loading &&
                    filtered.map((r) => (
                      <div key={r.id} className="px-1 py-2">

                        {/* Body */}
                        <div className="grid grid-cols-[1.6fr_0.7fr_1fr_1.2fr_1.2fr_56px_56px] gap-1 text-[13px] text-[#BD9A6B]">
                          <div className="truncate">{r.title}</div>
                          <div className="text-center">{r.age}</div>
                          <div className="text-center">{r.difficulty}</div>
                          <div className="text-center truncate">{r.dev}</div>
                          <div className="text-center">{r.duration}</div>

                          <div className="flex justify-center">
                            {/* Delete button */}
                            <button
                              onClick={() => onDelete(r.id)}
                              className="h-8 w-8 rounded-[10px] bg-[#6B3B30] text-white
                                     shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                     hover:brightness-110 active:scale-[0.99]"
                              title="Delete"
                            >
                              <MdDelete size={18} />
                            </button>
                          </div>

                          <div className="flex justify-center">
                            {/* More button */}
                            <button
                              onClick={() => onMore(r.id)}
                              className="h-8 w-8 rounded-[10px] bg-[#BD9A6B] text-white
                                     shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                     hover:brightness-95 active:scale-[0.99]"
                              title="More"
                            >
                              <HiDotsHorizontal size={18} />
                            </button>
                          </div>
                        </div>

                        <div className="mt-3 h-[1px] bg-[#D9C7BF]" />
                      </div>
                    ))}

                  {!loading && filtered.length === 0 && (
                    <div className="py-16 text-center text-[#BD9A6B]">
                      No routines found.
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* scrollbar style */}
            <style>{`
            .custom-scroll::-webkit-scrollbar { width: 10px; }
            .custom-scroll::-webkit-scrollbar-track { background: transparent; }
            .custom-scroll::-webkit-scrollbar-thumb {
              background: rgba(183, 154, 106, 0.85);
              border-radius: 999px;
            }
            .custom-scroll { scrollbar-color: rgba(183, 154, 106, 0.85) transparent; scrollbar-width: thin; }
          `}</style>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}

// Reusable select box component
function SelectBox({ value, onChange, placeholder, options }) {
  return (
    <div className="relative w-full sm:w-[200px]">
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full appearance-none rounded-[10px] border border-[#BD9A6B] bg-[#EFE6E3]
                   px-5 py-2 pr-10 text-sm text-[#BD9A6B] outline-none"
      >
        <option value="">{placeholder}</option>
        {options.map((op) => (
          <option key={op} value={op}>
            {op}
          </option>
        ))}
      </select>

      <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-[#B0896E]">
        ▾
      </span>
    </div>
  );
}
