import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { TherapistChildrenList } from "./TherapistChildrenList";

export const Therapists_dashboard = () => {
  const navigate = useNavigate();
  const [therapist, setTherapist] = useState(null);

  useEffect(() => {
    const token = localStorage.getItem("therapist_token");
    const info = localStorage.getItem("therapist_info");

    // If not logged in, redirect to login
    if (!token || !info) {
      navigate("/therapists_login");
      return;
    }

    try {
      setTherapist(JSON.parse(info));
    } catch (e) {
      // corrupted storage -> force logout
      localStorage.removeItem("therapist_token");
      localStorage.removeItem("therapist_info");
      navigate("/therapists_login");
    }
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem("therapist_token");
    localStorage.removeItem("therapist_info");
    navigate("/therapists_login");
  };

  if (!therapist) return null;

  return (
    <div className="min-h-screen bg-[#FBF3F0] font-sans">
      <div className="max-w-[1400px] mx-auto px-6 md:px-12 pb-12 pt-6">
        {/* Cover Image */}
        <div
          className="h-64 w-full bg-cover bg-center relative rounded-xl shadow-sm overflow-hidden"
          style={{
            backgroundImage: "url('https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=2301&auto=format&fit=crop')", // Placeholder office/desk image
          }}
        >
          <div className="absolute inset-0 bg-blue-900/30"></div> {/* Overlay to match the blueish tint */}
          <button
            onClick={handleLogout}
            className="absolute top-4 right-4 bg-white/20 backdrop-blur-md text-white px-4 py-2 rounded-full hover:bg-white/30 transition text-sm font-medium"
          >
            Logout
          </button>
        </div>

        {/* Profile Header Section */}
        <div className="relative flex flex-col items-start gap-6 mb-12">

          {/* Avatar - Negative Margin to overlap */}
          <div className="flex-shrink-0 ml-10 -mt-20 z-10">
            <div className="w-48 h-48 rounded-full border-4 border-[#FBF3F0] overflow-hidden bg-gray-200 shadow-lg">
              <img
                src="https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671142.jpg"
                alt="Profile"
                className="w-full h-full object-cover"
              />
            </div>
          </div>

          {/* Info Section - Below avatar, left aligned */}
          <div className="w-full flex flex-col md:flex-row justify-between items-start gap-8 text-[#1E3A5F]">

            {/* Left Column: Personal Info (Left Aligned) */}
            <div className="flex flex-col gap-1 text-left">
              <h1 className="text-3xl md:text-4xl font-extrabold text-[#1E3A5F]">
                {therapist.full_name || "Dr. Therapist Name"}
              </h1>
              <h2 className="text-xl font-semibold text-[#3B6088] mb-2">
                {therapist.specialization || "Specialization"}
              </h2>

              <div className="text-md font-medium text-[#3B6088]/80 space-y-1">
                <p>
                  <span className="font-semibold text-[#1E3A5F]">SLMC/REG/</span>
                  {therapist.licence_number || therapist.license_no || "12345"}
                </p>
                <p>
                  <span className="font-semibold text-[#1E3A5F]">Experience : </span>
                  9 years
                </p>
                <p>
                  <span className="font-semibold text-[#1E3A5F]">Age : </span>
                  40 years
                </p>
              </div>
            </div>

            {/* Right Column: Contact Details */}
            <div className="flex gap-6 items-start mr-[400px] mt-[30px]">
              {/* Vertical Divider */}
              <div className="hidden md:block w-px h-36 bg-[#1E3A5F]/20"></div>

              <div className="space-y-3 pt-2 text-left">
                <h3 className="text-lg font-bold text-[#1E3A5F] border-b border-[#1E3A5F]/20 inline-block pb-1 mb-2">
                  Contact Details
                </h3>

                <div className="grid grid-cols-[80px_1fr] gap-x-2 gap-y-2 text-[#3B6088]">
                  <span className="font-bold text-[#1E3A5F]">Email</span>
                  <span>: {therapist.email || "—"}</span>

                  <span className="font-bold text-[#1E3A5F]">Mobile</span>
                  <span>: {therapist.phone || therapist.mobile || "—"}</span>

                  <span className="font-bold text-[#1E3A5F]">Address</span>
                  <span>: {therapist.work_place || therapist.hospital || "No. 2, Chatham Street, Colombo"}</span>
                </div>
              </div>

              {/* Edit Icon Button */}
              <button className="hidden md:block p-2 text-gray-400 hover:text-gray-600">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
                </svg>
              </button>
            </div>
          </div>
        </div>

        {/* Children List Component */}
        <TherapistChildrenList />

      </div>
    </div>
  );
};
