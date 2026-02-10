import React from "react";
import { NavLink, useNavigate } from "react-router-dom";

// React Icons
import { FaUserEdit } from "react-icons/fa";
import { MdOutlineManageAccounts } from "react-icons/md";
import { HiOutlineClipboardList } from "react-icons/hi";
import { PiBooksLight } from "react-icons/pi";
import { MdOutlineHealthAndSafety } from "react-icons/md";

import { uploadAdminProfilePicture, getAdminById } from "../../services/Admin/adminService";

export default function Sidebar() {
  const [admin, setAdmin] = React.useState(null);
  const fileInputRef = React.useRef(null);
  const navigate = useNavigate();

  React.useEffect(() => {
    const fetchAdmin = async () => {
      const stored = localStorage.getItem("admin_profile");
      if (stored) {
        try {
          const parsed = JSON.parse(stored);
          setAdmin(parsed);

          // Fetch latest data to ensure profile picture is current
          if (parsed._id) {
            const freshData = await getAdminById(parsed._id);
            if (freshData) {
              setAdmin(freshData);
              localStorage.setItem("admin_profile", JSON.stringify(freshData));
            }
          }
        } catch (err) {
          console.error("Failed to parse or fetch admin_profile", err);
        }
      }
    };
    fetchAdmin();
  }, []);

  const handleEditClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const handleFileChange = async (e) => {
    const file = e.target.files[0];
    if (!file || !admin?._id) return;

    try {
      const response = await uploadAdminProfilePicture(admin._id, file);
      if (response?.admin) {
        setAdmin(response.admin);
        localStorage.setItem("admin_profile", JSON.stringify(response.admin));
        alert("Profile picture updated successfully!");
      }
    } catch (error) {
      console.error("Failed to upload profile picture", error);
      alert("Failed to upload profile picture");
    }
  };

  // Default placeholder if no picture
  const defaultImg = "https://cdn-icons-png.flaticon.com/512/3135/3135715.png";

  return (
    <aside className="w-[240px] h-full bg-[#386884] flex flex-col sticky top-0">
      {/* spacer for header */}
      <div className="h-16" />

      {/* ===== Profile Section ===== */}
      <div className="flex flex-col items-center mb-6">
        <div className="relative -mt-4">
          <img
            src={admin?.profile_picture || defaultImg}
            alt="admin profile"
            className="h-28 w-28 rounded-full bg-white object-cover border-4 border-[#386884]"
          />

          {/* Hidden File Input */}
          <input
            type="file"
            ref={fileInputRef}
            className="hidden"
            accept="image/*"
            onChange={handleFileChange}
          />

          {/* edit icon */}
          <button
            onClick={handleEditClick}
            className="absolute bottom-1 right-1 bg-[#D9D9D9] text-[#4E6C82] rounded-full p-2 shadow hover:bg-white transition cursor-pointer"
          >
            <FaUserEdit size={14} />
          </button>
        </div>

        <h2 className="mt-4 text-xl font-semibold text-[#DFC7A7] text-center px-4">
          {admin?.full_name || "Admin User"}
        </h2>
        <p className="text-sm opacity-90 text-[#DFC7A7]">Admin</p>
      </div>

      {/* ===== Contact Details ===== */}
      <div className="px-6 pb-6 text-sm text-[#DFC7A7]">
        <p className="font-semibold underline underline-offset-4 mb-3">
          Contact Details
        </p>

        <div className="space-y-2 opacity-90">
          <p className="truncate">
            <span className="font-medium">Mobile</span>
            <span className="ml-2">: {admin?.phone || "N/A"}</span>
          </p>
          <p className="truncate" title={admin?.email}>
            <span className="font-medium">Email</span>
            <span className="ml-2">: {admin?.email || "N/A"}</span>
          </p>

          <div className="flex gap-2">
            <button
              onClick={() => navigate("/admin_edite")}
              className="bg-[#F7EAD7] text-[#386884] px-4 py-2 rounded-full cursor-pointer hover:bg-[#e6d5c0] transition"
            >
              Edit Profile
            </button>
            <button className="bg-[#F7EAD7] text-[#386884] px-4 py-2 rounded-full cursor-pointer hover:bg-[#e6d5c0] transition">Logout</button>
          </div>
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
              label: "Wellness Module",
              icon: MdOutlineHealthAndSafety,

            },
            {
              to: "/wellness_module",
              label: "Learning Module",
              icon: PiBooksLight,
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
