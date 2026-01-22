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
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-3xl mx-auto bg-white shadow-lg rounded-lg p-6">
        <div className="flex items-center justify-between gap-4">
          <h1 className="text-2xl font-bold text-gray-800">
            Therapist Dashboard
          </h1>

          <button
            onClick={handleLogout}
            className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition"
          >
            Logout
          </button>
        </div>

        <p className="text-gray-500 mt-1">Welcome back 👋</p>

        <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-4">
          <InfoCard label="Therapist ID" value={therapist._id || therapist.therapist_id || "—"} />
          <InfoCard label="Full Name" value={therapist.full_name ||  "—"} />
          <InfoCard label="Email" value={therapist.email || "—"} />
          <InfoCard label="Phone" value={therapist.phone || therapist.mobile || "—"} />
          <InfoCard label="Specialization" value={therapist.specialization || "—"} />
          <InfoCard label="License Number" value={therapist.licence_number || therapist.license_no || "—"} />
          <InfoCard label="Hospital/Clinic" value={therapist.work_place || therapist.hospital || "—"} />
          <InfoCard label="Created At" value={therapist.createdAt ? new Date(therapist.createdAt).toLocaleString() : "—"} />
        </div>

        {/* Optional: show the full JSON for debugging */}
        {/* <pre className="mt-6 text-xs bg-gray-100 p-3 rounded">{JSON.stringify(therapist, null, 2)}</pre> */}
      </div>
      <TherapistChildrenList />
    </div>
  );
};

const InfoCard = ({ label, value }) => (
  <div className="border rounded-lg p-4 bg-gray-50">
    <p className="text-xs text-gray-500">{label}</p>
    <p className="text-sm font-semibold text-gray-800 mt-1 break-words">
      {value}
    </p>
  </div>
);
