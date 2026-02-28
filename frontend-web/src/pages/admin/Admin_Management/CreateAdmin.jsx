// src/pages/CreateAdmin.jsx
import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { FaChevronCircleLeft } from "react-icons/fa";
import { createAdmin } from "../../../services/Admin/adminService";
import AdminLayout from "./AdminLayout";

const CreateAdmin = () => {
  const navigate = useNavigate();

  const [full_name, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccessMsg("");

    if (!full_name || !email || !password) {
      setError("full_name, email and password are required.");
      return;
    }

    try {
      setLoading(true);

      const data = await createAdmin({ full_name, email, password });

      setSuccessMsg(data?.message || "Admin created successfully!");

      // go back to login after success
      setTimeout(() => navigate("/admin_login"), 800);
    } catch (err) {
      const msg =
        err?.response?.data?.message ||
        err?.message ||
        "Create admin failed. Please try again.";
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AdminLayout>
      <div className="min-h-screen bg-[#F3E8E8] flex flex-col p-8 ml-0">
        <div className="max-w-2xl w-full mx-auto pt-6">
          {/* Back Button */}
          <button
            onClick={() => navigate(-1)}
            className="mb-4 text-[#BD9A6B] hover:text-[#a38054] transition-colors shadow-sm rounded-full bg-[#F3E8E8] p-1 inline-flex items-center justify-center shadow-[0_4px_6px_rgba(0,0,0,0.1)] active:scale-95"
            title="Go Back"
          >
            <FaChevronCircleLeft size={36} />
          </button>

          {/* Form Container */}
          <div className="border border-[#BD9A6B] rounded-2xl p-8 md:p-10 relative bg-white/40 backdrop-blur-sm shadow-lg">
            <div className="mb-8 text-center">
              <h1 className="text-2xl font-bold text-[#BD9A6B] tracking-wide uppercase">
                Create New Admin
              </h1>
              <div className="w-16 h-1 bg-[#BD9A6B] mx-auto mt-2 rounded-full opacity-60"></div>
            </div>

            {/* Success/Error Messages */}
            {error && (
              <div className="mb-4 text-red-600 bg-red-100 p-3 rounded-lg text-sm animate-pulse">
                {error}
              </div>
            )}
            {successMsg && (
              <div className="mb-4 text-green-600 bg-green-100 p-3 rounded-lg text-sm">
                {successMsg}
              </div>
            )}

            <form onSubmit={handleSubmit} className="flex flex-col gap-6">
              {/* Full Name */}
              <div className="flex flex-col gap-1.5">
                <label className="text-[#BD9A6B] font-bold text-lg ml-1">
                  Full Name
                </label>
                <input
                  type="text"
                  value={full_name}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="Enter full name"
                  className="w-full bg-[#F3E8E8]/50 border border-[#BD9A6B]/40 rounded-xl px-4 py-2.5 outline-none text-[#7A6357] text-base focus:ring-2 focus:ring-[#BD9A6B]/30 transition-all shadow-sm"
                />
              </div>

              {/* Email */}
              <div className="flex flex-col gap-1.5">
                <label className="text-[#BD9A6B] font-bold text-lg ml-1">
                  Email Address
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@chromabloom.com"
                  className="w-full bg-[#F3E8E8]/50 border border-[#BD9A6B]/40 rounded-xl px-4 py-2.5 outline-none text-[#7A6357] text-base focus:ring-2 focus:ring-[#BD9A6B]/30 transition-all shadow-sm"
                />
              </div>

              {/* Password */}
              <div className="flex flex-col gap-1.5">
                <label className="text-[#BD9A6B] font-bold text-lg ml-1">
                  Temporary Password
                </label>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  className="w-full bg-[#F3E8E8]/50 border border-[#BD9A6B]/40 rounded-xl px-4 py-2.5 outline-none text-[#7A6357] text-base focus:ring-2 focus:ring-[#BD9A6B]/30 transition-all shadow-sm"
                />
              </div>

              {/* Submit Button */}
              <div className="flex justify-end mt-2">
                <button
                  type="submit"
                  disabled={loading}
                  className="bg-[#BD9A6B] text-white font-bold text-base py-2.5 px-10 rounded-xl shadow-md hover:brightness-105 active:scale-95 transition-all disabled:opacity-70 disabled:cursor-not-allowed tracking-wide"
                >
                  {loading ? "Registering..." : "Create Account"}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
};

export default CreateAdmin;
