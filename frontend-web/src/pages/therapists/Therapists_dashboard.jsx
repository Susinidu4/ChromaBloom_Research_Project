import React, { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { TherapistChildrenList } from "./TherapistChildrenList";
import TherapistLayout from "../therapists/TherapistLayout";
import { getTherapistByIdService, updateTherapistService } from "../../services/therapistService";
import Swal from "sweetalert2";

export const Therapists_dashboard = () => {
  const navigate = useNavigate();
  const fileInputRef = useRef(null);
  const [therapist, setTherapist] = useState(null);
  const [loading, setLoading] = useState(true);
  const [updatingPhoto, setUpdatingPhoto] = useState(false);

  useEffect(() => {
    const fetchTherapistData = async () => {
      const token = localStorage.getItem("therapist_token");
      const info = localStorage.getItem("therapist_info");

      // If not logged in, redirect to login
      if (!token || !info) {
        navigate("/therapists_login");
        return;
      }

      try {
        const storedInfo = JSON.parse(info);
        // Fetch fresh data from backend to ensure we have the latest
        const freshData = await getTherapistByIdService(storedInfo._id || storedInfo.id, token);
        setTherapist(freshData);
      } catch (e) {
        console.error("Error fetching therapist data:", e);
        // If fetch fails, try to use stored info as fallback if it exists
        try {
          setTherapist(JSON.parse(info));
        } catch (parseError) {
          // corrupted storage -> force logout
          localStorage.removeItem("therapist_token");
          localStorage.removeItem("therapist_info");
          navigate("/therapists_login");
        }
      } finally {
        setLoading(false);
      }
    };

    fetchTherapistData();
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem("therapist_token");
    localStorage.removeItem("therapist_info");
    navigate("/therapists_login");
  };

  const handleCameraClick = () => {
    fileInputRef.current.click();
  };

  const handleFileChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith("image/")) {
      Swal.fire("Error", "Please select an image file", "error");
      return;
    }

    // Validate size (e.g., 2MB)
    if (file.size > 2 * 1024 * 1024) {
      Swal.fire("Error", "Image size should be less than 2MB", "error");
      return;
    }

    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onloadend = async () => {
      const base64String = reader.result;

      try {
        setUpdatingPhoto(true);
        const token = localStorage.getItem("therapist_token");
        const res = await updateTherapistService(therapist._id, { profile_picture_base64: base64String }, token);

        // Update local state and storage
        setTherapist(res.therapist);
        localStorage.setItem("therapist_info", JSON.stringify(res.therapist));

        Swal.fire({
          icon: "success",
          title: "Success",
          text: "Profile picture updated successfully!",
          timer: 2000,
          showConfirmButton: false
        });
      } catch (err) {
        console.error("Profile update error:", err);
        Swal.fire("Error", "Failed to update profile picture", "error");
      } finally {
        setUpdatingPhoto(false);
      }
    };
  };

  const calculateAge = (dob) => {
    if (!dob) return "N/A";
    const birthDate = new Date(dob);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  const calculateExperience = (startDate) => {
    if (!startDate) return "N/A";
    const start = new Date(startDate);
    const today = new Date();
    let years = today.getFullYear() - start.getFullYear();
    const m = today.getMonth() - start.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < start.getDate())) {
      years--;
    }
    return years > 0 ? `${years} years` : "Less than a year";
  };

  if (loading) {
    return (
      <TherapistLayout>
        <div className="min-h-screen bg-[#FBF3F0] flex items-center justify-center">
          <div className="animate-pulse text-[#1E3A5F] text-xl font-semibold">Loading Dashboard...</div>
        </div>
      </TherapistLayout>
    );
  }

  if (!therapist) return null;

  return (
    <TherapistLayout>
      <div className="bg-[#FBF3F0] font-sans">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 pb-12 pt-6">
          {/* Cover Image */}
          <div
            className="h-64 w-full bg-cover bg-center relative rounded-xl shadow-sm overflow-hidden"
            style={{
              backgroundImage:
                "url('https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=2301&auto=format&fit=crop')", // Placeholder office/desk image
            }}
          >
            <div className="absolute inset-0 bg-blue-900/30"></div>{" "}
            {/* Overlay to match the blueish tint */}
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
            <div className="flex-shrink-0 ml-10 -mt-20 z-10 relative">
              <div className="w-48 h-48 rounded-full border-4 border-[#FBF3F0] overflow-hidden bg-gray-200 shadow-lg relative">
                {updatingPhoto && (
                  <div className="absolute inset-0 bg-black/40 flex items-center justify-center z-10">
                    <div className="w-8 h-8 border-4 border-white border-t-transparent rounded-full animate-spin"></div>
                  </div>
                )}
                <img
                  src={therapist.profile_picture || "https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671142.jpg"}
                  alt="Profile"
                  className="w-full h-full object-cover"
                />
              </div>

              {/* Profile Image Edit Icon */}
              <button
                onClick={handleCameraClick}
                disabled={updatingPhoto}
                className="absolute bottom-2 right-2 bg-white p-2.5 rounded-full shadow-md hover:bg-gray-100 transition-all border border-gray-200 group"
                title="Update Profile Picture"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="#1E3A5F"
                  strokeWidth="2.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className="group-hover:scale-110 transition-transform"
                >
                  <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path>
                  <circle cx="12" cy="13" r="4"></circle>
                </svg>
              </button>

              {/* Hidden File Input */}
              <input
                type="file"
                ref={fileInputRef}
                onChange={handleFileChange}
                accept="image/*"
                className="hidden"
              />
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
                    <span className="font-semibold text-[#1E3A5F]">
                      SLMC/REG/
                    </span>
                    {therapist.licence_number ||
                      therapist.license_no ||
                      "N/A"}
                  </p>
                  <p>
                    <span className="font-semibold text-[#1E3A5F]">
                      Experience :{" "}
                    </span>
                    {calculateExperience(therapist.start_date)}
                  </p>
                  <p>
                    <span className="font-semibold text-[#1E3A5F]">Age : </span>
                    {calculateAge(therapist.dob)} years
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
                    <span>
                      :{" "}
                      {therapist.address || therapist.work_place ||
                        therapist.hospital ||
                        "No. 2, Chatham Street, Colombo"}
                    </span>
                  </div>
                </div>

                {/* Edit Icon Button */}
                <button
                  onClick={() => navigate("/therapists_edit")}
                  className="hidden md:block p-2 text-gray-400 hover:text-[#BD9A6B] transition-colors"
                  title="Edit Professional Profile"
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
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
    </TherapistLayout>
  );
};

