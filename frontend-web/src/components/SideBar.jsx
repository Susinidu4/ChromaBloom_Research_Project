import React from "react";
import { NavLink } from "react-router-dom";

// React Icons
import { FaUserEdit } from "react-icons/fa";
import { MdOutlineManageAccounts } from "react-icons/md";
import { HiOutlineClipboardList } from "react-icons/hi";
import { PiBooksLight } from "react-icons/pi";
import { MdOutlineHealthAndSafety } from "react-icons/md";

export default function Sidebar() {
  return (
    <aside className="w-[240px] h-full bg-[#386884] flex flex-col sticky top-0">
      {/* spacer for header */}
      <div className="h-16" />

      {/* ===== Profile Section ===== */}
      <div className="flex flex-col items-center mb-6">
        <div className="relative -mt-4">
          <img src="#" alt="image" className="h-28 w-28 rounded-full bg-white" />

          {/* edit icon */}
          <button className="absolute bottom-1 right-1 bg-[#D9D9D9] text-[#4E6C82] rounded-full p-2 shadow">
            <FaUserEdit size={14} />
          </button>
        </div>

        <h2 className="mt-4 text-xl font-semibold text-[#DFC7A7]">
          Stephani Silva
        </h2>
        <p className="text-sm opacity-90 text-[#DFC7A7]">Admin</p>
      </div>

      {/* ===== Contact Details ===== */}
      <div className="px-6 pb-6 text-sm text-[#DFC7A7]">
        <p className="font-semibold underline underline-offset-4 mb-3">
          Contact Details
        </p>

        <div className="space-y-2 opacity-90">
          <p>
            <span className="font-medium">Mobile</span>
            <span className="ml-2">: 0778989890</span>
          </p>
          <p>
            <span className="font-medium">Email</span>
            <span className="ml-2">: abc@gmail.com</span>
          </p>
        </div>
      </div>

      {/* ===== Navigation ===== */}
      <div className="flex-1">
        {/* ✅ CLICKABLE Section title -> /admin_dashboard */}
        <NavLink
          to="/admin_dashboard"
          className={({ isActive }) =>
            [
              "flex items-center gap-2 px-6 py-3 font-semibold transition-colors duration-200 text-[#DFC7A7]",
              // "bg-[#F3E8D9] text-[#386884]",
              isActive ? "bg-[#F7EAD7] text-[#386884]"
                    : "bg-[#386884] text-[#DFC7A7]",
                  "hover:bg-[#2F566D]",
            ].join(" ")
          }
        >
          <MdOutlineManageAccounts size={18} />
          User Management
        </NavLink>

        <nav className="flex flex-col text-[#DFC7A7]">
          {[
            {
              to: "/routine_list",
              label: "Routine Module",
              icon: HiOutlineClipboardList,
            },
            {
              to: "/stress_recommendation_list",
              label: "Learning Module",
              icon: PiBooksLight,
            },
            {
              to: "/wellness_module",
              label: "Wellness Module",
              icon: MdOutlineHealthAndSafety,
            },
          ].map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) =>
                [
                  "flex items-center gap-3 px-6 py-3 text-sm font-medium border-t border-white/10",
                  "transition-colors duration-200",
                  // ✅ active = bg F7EAD7
                  isActive
                    ? "bg-[#F7EAD7] text-[#386884]"
                    : "bg-[#386884] text-[#DFC7A7]",
                  "hover:bg-[#2F566D]",
                ].join(" ")
              }
            >
              <Icon size={18} className="shrink-0" />
              {label}
            </NavLink>
          ))}
        </nav>
      </div>
    </aside>
  );
}
