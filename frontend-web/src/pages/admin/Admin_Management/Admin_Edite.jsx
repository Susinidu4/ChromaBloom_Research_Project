import React, { useState, useEffect } from "react";
import AdminLayout from "./AdminLayout";
import { FaChevronCircleLeft } from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import { getAdminById, updateAdmin } from "../../../services/Admin/adminService";

export const Admin_Edite = () => {
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        full_name: "",
        email: "",
        phone: "",
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    const [adminId, setAdminId] = useState(null);

    useEffect(() => {
        // 1. Get ID from localStorage (since we don't have it in URL params in side bar link)
        // better approach: side bar passed it? No, side bar just navigated.
        // Let's use the stored profile ID.
        const stored = localStorage.getItem("admin_profile");
        if (stored) {
            try {
                const parsed = JSON.parse(stored);
                if (parsed._id) {
                    setAdminId(parsed._id);
                    fetchAdminData(parsed._id);
                }
            } catch (err) {
                console.error("Failed to parse admin_profile", err);
            }
        }
    }, []);

    const fetchAdminData = async (id) => {
        try {
            const data = await getAdminById(id);
            if (data) {
                setFormData({
                    full_name: data.full_name || "",
                    email: data.email || "",
                    phone: data.phone || "",
                });
            }
        } catch (err) {
            console.error("Failed to fetch admin data", err);
        }
    }

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError("");
        setSuccess("");
        setLoading(true);

        try {
            if (!adminId) throw new Error("Admin ID not found");

            const res = await updateAdmin(adminId, formData);

            // Update local storage if needed, or just let sidebar re-fetch
            if (res.admin) {
                localStorage.setItem("admin_profile", JSON.stringify(res.admin));
            }

            setSuccess("Profile updated successfully!");
            setTimeout(() => setSuccess(""), 3000);
        } catch (err) {
            setError(err.response?.data?.message || "Failed to update profile");
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
                    >
                        <FaChevronCircleLeft size={36} />
                    </button>

                    {/* Form Container */}
                    <div className="border border-[#BD9A6B] rounded-2xl p-8 md:p-10 relative bg-white/40 backdrop-blur-sm shadow-lg">
                        <div className="mb-8 text-center">
                            <h1 className="text-2xl font-bold text-[#BD9A6B] tracking-wide uppercase">
                                Edit Admin Profile
                            </h1>
                            <div className="w-16 h-1 bg-[#BD9A6B] mx-auto mt-2 rounded-full opacity-60"></div>
                        </div>

                        {/* Success/Error Messages */}
                        {error && <div className="mb-4 text-red-600 bg-red-100 p-3 rounded-lg text-sm">{error}</div>}
                        {success && <div className="mb-4 text-green-600 bg-green-100 p-3 rounded-lg text-sm">{success}</div>}

                        <form onSubmit={handleSubmit} className="flex flex-col gap-6">
                            {/* Full Name */}
                            <div className="flex flex-col gap-1.5">
                                <label className="text-[#BD9A6B] font-bold text-lg ml-1">
                                    Full Name
                                </label>
                                <input
                                    type="text"
                                    name="full_name"
                                    value={formData.full_name}
                                    onChange={handleChange}
                                    className="w-full bg-[#F3E8E8]/50 border border-[#BD9A6B]/40 rounded-xl px-4 py-2.5 outline-none text-[#7A6357] text-base focus:ring-2 focus:ring-[#BD9A6B]/30 shadow-sm"
                                />
                            </div>

                            {/* Email */}
                            <div className="flex flex-col gap-1.5">
                                <label className="text-[#BD9A6B] font-bold text-lg ml-1">
                                    Email
                                </label>
                                <input
                                    type="email"
                                    name="email"
                                    value={formData.email}
                                    onChange={handleChange}
                                    className="w-full bg-[#F3E8E8]/50 border border-[#BD9A6B]/40 rounded-xl px-4 py-2.5 outline-none text-[#7A6357] text-base focus:ring-2 focus:ring-[#BD9A6B]/30 shadow-sm"
                                />
                            </div>

                            {/* Phone */}
                            <div className="flex flex-col gap-1.5">
                                <label className="text-[#BD9A6B] font-bold text-lg ml-1">
                                    Mobile Number
                                </label>
                                <input
                                    type="text"
                                    name="phone"
                                    value={formData.phone}
                                    onChange={handleChange}
                                    className="w-full bg-[#F3E8E8]/50 border border-[#BD9A6B]/40 rounded-xl px-4 py-2.5 outline-none text-[#7A6357] text-base focus:ring-2 focus:ring-[#BD9A6B]/30 shadow-sm"
                                />
                            </div>

                            {/* Submit Button */}
                            <div className="flex justify-end mt-2">
                                <button
                                    type="submit"
                                    disabled={loading}
                                    className="bg-[#BD9A6B] text-white font-bold py-2.5 px-8 rounded-xl shadow-md hover:brightness-105 active:scale-95 transition-all disabled:opacity-70 text-base"
                                >
                                    {loading ? "Updating..." : "Update Admin"}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
};

