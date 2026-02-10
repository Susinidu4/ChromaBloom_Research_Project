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
                <div className="max-w-4xl w-full mx-auto pt-10">
                    {/* Back Button */}
                    <button
                        onClick={() => navigate(-1)}
                        className="mb-6 text-[#BD9A6B] hover:text-[#a38054] transition-colors shadow-sm rounded-full bg-[#F3E8E8] p-1 inline-flex items-center justify-center shadow-[0_4px_6px_rgba(0,0,0,0.1)] active:scale-95"
                    >
                        <FaChevronCircleLeft size={42} />
                    </button>

                    {/* Form Container */}
                    <div className="border border-[#BD9A6B] rounded-xl p-10 md:p-14 relative bg-transparent">
                        {/* Success/Error Messages */}
                        {error && <div className="mb-4 text-red-600 bg-red-100 p-3 rounded">{error}</div>}
                        {success && <div className="mb-4 text-green-600 bg-green-100 p-3 rounded">{success}</div>}

                        <form onSubmit={handleSubmit} className="flex flex-col gap-8">
                            {/* Full Name */}
                            <div className="flex flex-col gap-2">
                                <label className="text-[#BD9A6B] font-bold text-xl ml-1">
                                    Full Name
                                </label>
                                <input
                                    type="text"
                                    name="full_name"
                                    value={formData.full_name}
                                    onChange={handleChange}
                                    className="w-full bg-[#F3E8E8] border border-[#BD9A6B] rounded-xl px-4 py-3 outline-none text-[#7A6357] text-lg focus:ring-2 focus:ring-[#BD9A6B]/50 shadow-sm"
                                />
                            </div>

                            {/* Email */}
                            <div className="flex flex-col gap-2">
                                <label className="text-[#BD9A6B] font-bold text-xl ml-1">
                                    Email
                                </label>
                                <input
                                    type="email"
                                    name="email"
                                    value={formData.email}
                                    onChange={handleChange}
                                    className="w-full bg-[#F3E8E8] border border-[#BD9A6B] rounded-xl px-4 py-3 outline-none text-[#7A6357] text-lg focus:ring-2 focus:ring-[#BD9A6B]/50 shadow-sm"
                                />
                            </div>

                            {/* Phone (using Password style from image but mapped to Phone as per user code) */}
                            <div className="flex flex-col gap-2">
                                <label className="text-[#BD9A6B] font-bold text-xl ml-1">
                                    Mobile Number
                                </label>
                                <input
                                    type="text"
                                    name="phone"
                                    value={formData.phone}
                                    onChange={handleChange}
                                    className="w-full bg-[#F3E8E8] border border-[#BD9A6B] rounded-xl px-4 py-3 outline-none text-[#7A6357] text-lg focus:ring-2 focus:ring-[#BD9A6B]/50 shadow-sm"
                                />
                            </div>

                            {/* Submit Button */}
                            <div className="flex justify-end mt-4">
                                <button
                                    type="submit"
                                    disabled={loading}
                                    className="bg-[#BD9A6B] text-white font-bold py-3 px-10 rounded-xl shadow-[0_4px_10px_rgba(189,154,107,0.5)] hover:brightness-105 active:scale-95 transition-all disabled:opacity-70"
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

