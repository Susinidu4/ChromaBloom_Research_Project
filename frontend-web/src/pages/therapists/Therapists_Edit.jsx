import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import TherapistLayout from "./TherapistLayout";
import { getTherapistByIdService, updateTherapistService } from "../../services/therapistService";
import Swal from "sweetalert2";

export const Therapists_Edit = () => {
    const navigate = useNavigate();
    const [therapist, setTherapist] = useState(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);

    const [form, setForm] = useState({
        full_name: "",
        dob: "",
        gender: "",
        email: "",
        phone: "",
        address: "",
        specialization: "",
        start_date: "",
        licence_number: "",
        work_place: "",
    });

    useEffect(() => {
        const fetchTherapistData = async () => {
            const token = localStorage.getItem("therapist_token");
            const info = localStorage.getItem("therapist_info");

            if (!token || !info) {
                navigate("/therapists_login");
                return;
            }

            try {
                const storedInfo = JSON.parse(info);
                const data = await getTherapistByIdService(storedInfo._id || storedInfo.id, token);
                setTherapist(data);

                // Initialize form with fetched data
                setForm({
                    full_name: data.full_name || "",
                    dob: data.dob ? new Date(data.dob).toISOString().split('T')[0] : "",
                    gender: data.gender || "",
                    email: data.email || "",
                    phone: data.phone || "",
                    address: data.address || "",
                    specialization: data.specialization || "",
                    start_date: data.start_date || "",
                    licence_number: data.licence_number || "",
                    work_place: data.work_place || "",
                });
            } catch (err) {
                console.error("Error fetching therapist:", err);
                Swal.fire("Error", "Failed to fetch profile details", "error");
            } finally {
                setLoading(false);
            }
        };

        fetchTherapistData();
    }, [navigate]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setForm((prev) => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSaving(true);

        try {
            const token = localStorage.getItem("therapist_token");
            const res = await updateTherapistService(therapist._id, form, token);

            localStorage.setItem("therapist_info", JSON.stringify(res.therapist));

            await Swal.fire({
                icon: "success",
                title: "Profile Updated",
                text: "Your professional information has been successfully updated.",
                timer: 1500,
                showConfirmButton: false
            });

            navigate("/therapists_dashboard");
        } catch (err) {
            console.error("Update error:", err);
            Swal.fire("Error", "Failed to update profile", "error");
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <TherapistLayout>
                <div className="min-h-screen bg-[#FBF3F0] flex items-center justify-center">
                    <div className="animate-pulse text-[#1E3A5F] text-xl font-semibold">Preparing profile editor...</div>
                </div>
            </TherapistLayout>
        );
    }

    return (
        <TherapistLayout>
            <div className="min-h-screen bg-[#FBF3F0] font-sans py-12 px-6">
                <div className="max-w-4xl mx-auto">
                    {/* Header */}
                    <div className="flex items-center justify-between mb-8">
                        <div>
                            <h1 className="text-3xl font-extrabold text-[#1E3A5F]">Edit Professional Profile</h1>
                            <p className="text-[#3B6088] mt-1">Keep your professional details up to date for your clients.</p>
                        </div>
                        <button
                            onClick={() => navigate("/therapists_dashboard")}
                            className="px-6 py-2 rounded-full border-2 border-[#1E3A5F] text-[#1E3A5F] font-semibold hover:bg-[#1E3A5F] hover:text-white transition-all"
                        >
                            Cancel
                        </button>
                    </div>

                    <form onSubmit={handleSubmit} className="bg-white rounded-3xl shadow-xl overflow-hidden border border-[#E6D5C7]">
                        <div className="p-8 md:p-12 space-y-10">

                            {/* Personal Section */}
                            <section>
                                <div className="flex items-center gap-3 mb-6 border-b border-gray-100 pb-2">
                                    <div className="w-2 h-8 bg-[#BD9A6B] rounded-full"></div>
                                    <h2 className="text-xl font-bold text-[#1E3A5F]">Personal Information</h2>
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Full Name</label>
                                        <input
                                            type="text"
                                            name="full_name"
                                            value={form.full_name}
                                            onChange={handleChange}
                                            required
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Date of Birth</label>
                                        <input
                                            type="date"
                                            name="dob"
                                            value={form.dob}
                                            onChange={handleChange}
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Gender</label>
                                        <select
                                            name="gender"
                                            value={form.gender}
                                            onChange={handleChange}
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F] appearance-none cursor-pointer"
                                        >
                                            <option value="">Select Gender</option>
                                            <option value="male">Male</option>
                                            <option value="female">Female</option>
                                            <option value="other">Other</option>
                                        </select>
                                    </div>
                                </div>
                            </section>

                            {/* Professional Section */}
                            <section>
                                <div className="flex items-center gap-3 mb-6 border-b border-gray-100 pb-2">
                                    <div className="w-2 h-8 bg-[#BD9A6B] rounded-full"></div>
                                    <h2 className="text-xl font-bold text-[#1E3A5F]">Professional Details</h2>
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Specialization</label>
                                        <input
                                            type="text"
                                            name="specialization"
                                            value={form.specialization}
                                            onChange={handleChange}
                                            placeholder="e.g. Clinical Psychologist"
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Licence Number</label>
                                        <input
                                            type="text"
                                            name="licence_number"
                                            value={form.licence_number}
                                            onChange={handleChange}
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Years of Experience (Start Date)</label>
                                        <input
                                            type="date"
                                            name="start_date"
                                            value={form.start_date}
                                            onChange={handleChange}
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Place of Work</label>
                                        <input
                                            type="text"
                                            name="work_place"
                                            value={form.work_place}
                                            onChange={handleChange}
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                </div>
                            </section>

                            {/* Contact Section */}
                            <section>
                                <div className="flex items-center gap-3 mb-6 border-b border-gray-100 pb-2">
                                    <div className="w-2 h-8 bg-[#BD9A6B] rounded-full"></div>
                                    <h2 className="text-xl font-bold text-[#1E3A5F]">Contact Information</h2>
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Email Address</label>
                                        <input
                                            type="email"
                                            name="email"
                                            value={form.email}
                                            onChange={handleChange}
                                            required
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Phone Number</label>
                                        <input
                                            type="text"
                                            name="phone"
                                            value={form.phone}
                                            onChange={handleChange}
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F]"
                                        />
                                    </div>
                                    <div className="md:col-span-2">
                                        <label className="block text-sm font-semibold text-[#3B6088] mb-2 px-1">Full Address</label>
                                        <textarea
                                            name="address"
                                            value={form.address}
                                            onChange={handleChange}
                                            rows="3"
                                            className="w-full bg-[#FBF3F0] border-2 border-transparent focus:border-[#BD9A6B] rounded-2xl px-5 py-3.5 outline-none transition-all text-[#1E3A5F] resize-none"
                                        ></textarea>
                                    </div>
                                </div>
                            </section>

                        </div>

                        {/* Footer Actions */}
                        <div className="bg-[#1E3A5F]/5 p-8 flex justify-end gap-4 border-t border-gray-100">
                            <button
                                type="button"
                                onClick={() => navigate("/therapists_dashboard")}
                                className="px-8 py-3 rounded-2xl font-bold text-[#3B6088] hover:bg-white transition-all"
                            >
                                Discard Changes
                            </button>
                            <button
                                type="submit"
                                disabled={saving}
                                className="bg-[#BD9A6B] hover:bg-[#A6865A] text-white px-12 py-3.5 rounded-2xl font-bold shadow-lg shadow-[#BD9A6B]/20 transform active:scale-95 transition-all disabled:opacity-50"
                            >
                                {saving ? "Saving Changes..." : "Secure Update"}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </TherapistLayout>
    );
};
