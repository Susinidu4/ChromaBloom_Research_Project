import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { IoLogIn } from "react-icons/io5";
import { registerTherapistService } from "../../services/therapistService";
import ellipse1 from '../../assets/Therapists/ellipse_1.png';
import ellipse2 from '../../assets/Therapists/ellipse_2.png';
import doctor from '../../assets/Therapists/doctor.png';

// helper: file → base64 string
const fileToBase64 = (file) =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file); // this creates "data:image/...;base64,xxxx"
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);
  });

export const Therapists_register = () => {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    full_name: "",
    dob: "",
    gender: "",
    email: "",
    password: "",
    phone: "",
    address: "",
    specialization: "",
    start_date: "",
    licence_number: "",
    work_place: "",
    terms_and_conditions: false,
    privacy_policy: false,
  });

  const [profileBase64, setProfileBase64] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;

    setForm((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleProfilePictureChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const base64 = await fileToBase64(file);
      setProfileBase64(base64);
    } catch (error) {
      console.error("Base64 conversion error:", error);
      setErrorMsg("Failed to process profile picture");
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg("");
    setSuccessMsg("");
    setLoading(true);

    try {
      const payload = {
        ...form,
        profile_picture_base64: profileBase64 || undefined,
      };

      const data = await registerTherapistService(payload);
      // { message, therapist, token }

      // save token + therapist if you want auto-login
      localStorage.setItem("therapist_token", data.token);
      localStorage.setItem("therapist_info", JSON.stringify(data.therapist));

      setSuccessMsg("Registration successful!");
      // redirect to login or dashboard
      navigate("/therapists_login");
    } catch (error) {
      console.error("Therapist register error:", error);
      setErrorMsg(
        error.response?.data?.message ||
        "Registration failed. Please check your details."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col md:flex-row max-h-screen bg-[#386884] overflow-hidden relative font-sans">
      <Link
        to="/therapists_login"
        className="absolute top-6 left-6 z-50 text-[#C9A87C] hover:text-white transition-all bg-[#2C536A]/50 p-3 rounded-full border border-[#C9A87C]/30 hover:bg-[#2C536A] shadow-lg flex items-center justify-center group"
        title="Go to Login"
      >
        <IoLogIn size={28} className="transform group-hover:scale-110 transition-transform" />
      </Link>
      {/* Left side: Form portion */}
      <div className="flex-[1.2] flex items-center justify-center p-6 md:p-12 z-20 overflow-y-auto [&::-webkit-scrollbar]:hidden [scrollbar-width:none] [-ms-overflow-style:none]">
        <div className="w-full ml-15 mt-10 max-w-[95%] md:max-w-[650px] border border-[#BD9A6B] bg-[#5E7890]/80 backdrop-blur-md
                       shadow-[0_20px_40px_rgba(0,0,0,0.4)] rounded-[1.5rem] p-6 md:py-2 md:px-6 my-4 relative shadow-2xl overflow-y-auto [&::-webkit-scrollbar]:hidden [scrollbar-width:none] [-ms-overflow-style:none]">
          <div className="flex justify-end items-start mb-4">
            <h1 className="text-3xl font-extrabold text-[#C9A87C] tracking-tight uppercase opacity-80">
              Sign Up
            </h1>
          </div>

          {errorMsg && (
            <div className="mb-6 text-sm text-red-200 bg-red-900/40 border border-red-500/50 px-4 py-3 rounded-2xl animate-shake">
              {errorMsg}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Full Name */}
            <div className="flex flex-col md:flex-row md:items-center gap-4">
              <label className="md:w-32 text-sm font-bold text-[#C9A87C]/90">
                Full Name
              </label>
              <input
                type="text"
                name="full_name"
                required
                value={form.full_name}
                onChange={handleChange}
                className="flex-1 -ml-8 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none focus:ring-2 focus:ring-[#C9A87C]/30 transition-all shadow-sm"
              />
            </div>

            {/* DOB & Gender */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-3">
                <label className="w-28 md:w-32 text-sm font-bold text-[#C9A87C]/90">
                  Date of Birth
                </label>
                <div className="relative flex-1">
                  <style>
                    {`
                      input[type="date"]::-webkit-calendar-picker-indicator {
                        filter: invert(72%) sepia(17%) saturate(717%) hue-rotate(346deg) brightness(89%) contrast(87%);
                        cursor: pointer;
                      }
                    `}
                  </style>
                  <input
                    type="date"
                    name="dob"
                    value={form.dob}
                    onChange={handleChange}
                    className="w-full -ml-7 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none transition-all shadow-sm"
                  />

                </div>
              </div>

              <div className="flex items-center gap-3">
                <label className="w-20 text-sm font-bold text-[#C9A87C]/90">
                  Gender
                </label>
                <div className="relative flex-1">
                  <select
                    name="gender"
                    value={form.gender}
                    onChange={handleChange}
                    className="w-full border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none transition-all shadow-sm cursor-pointer appearance-none"
                  >
                    <option value="">Select</option>
                    <option value="female">Female</option>
                    <option value="male">Male</option>
                    <option value="other">Other</option>
                  </select>
                  <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none">
                    <svg className="w-5 h-5 text-[#C9A87C]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" /></svg>
                  </div>
                </div>
              </div>
            </div>

            {/* Email & Password */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-3">
                <label className="w-28 md:w-32 text-sm font-bold text-[#C9A87C]/90">
                  Email
                </label>
                <input
                  type="email"
                  name="email"
                  required
                  value={form.email}
                  onChange={handleChange}
                  className="flex-1 -ml-7 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
                />
              </div>

              <div className="flex items-center gap-3">
                <label className="w-20 text-sm font-bold text-[#C9A87C]/90">
                  Password
                </label>
                <input
                  type="password"
                  name="password"
                  required
                  value={form.password}
                  onChange={handleChange}
                  className="flex-1 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
                />
              </div>
            </div>

            {/* Phone Number */}
            <div className="flex flex-col md:flex-row md:items-center gap-3">
              <label className="md:w-32 text-sm font-bold text-[#C9A87C]/90">
                Phone No
              </label>
              <input
                type="text"
                name="phone"
                value={form.phone}
                onChange={handleChange}
                className="w-full -ml-7 md:w-2/3 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
              />
            </div>

            {/* Address */}
            <div className="flex flex-col md:flex-row md:items-center gap-3">
              <label className="md:w-32 text-sm font-bold text-[#C9A87C]/90">
                Address
              </label>
              <input
                type="text"
                name="address"
                value={form.address}
                onChange={handleChange}
                className="flex-1 -ml-7 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
              />
            </div>

            {/* Specialization & Start Date */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-3">
                <label className="w-28 md:w-32 text-sm font-bold text-[#C9A87C]/90">
                  Specialization
                </label>
                <input
                  type="text"
                  name="specialization"
                  value={form.specialization}
                  onChange={handleChange}
                  className="flex-1 -ml-7 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
                />
              </div>

              <div className="flex items-center gap-3">
                <label className="w-20 text-sm font-bold text-[#C9A87C]/90">
                  Start Date
                </label>
                <div className="relative flex-1">
                  <input
                    type="date"
                    name="start_date"
                    value={form.start_date}
                    onChange={handleChange}
                    className="w-full border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
                  />

                </div>
              </div>
            </div>

            {/* License No & Workplace */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="flex items-center gap-3">
                <label className="w-28 md:w-32 text-sm font-bold text-[#C9A87C]/90">
                  License No
                </label>
                <input
                  type="text"
                  name="licence_number"
                  value={form.licence_number}
                  onChange={handleChange}
                  className="flex-1 -ml-7 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
                />
              </div>

              <div className="flex items-center gap-3">
                <label className="w-20 text-sm font-bold text-[#C9A87C]/90">
                  Workplace
                </label>
                <input
                  type="text"
                  name="work_place"
                  value={form.work_place}
                  onChange={handleChange}
                  className="flex-1 border border-[#C9A87C] rounded-md px-4 py-1.5 text-sm text-[#386884] focus:outline-none shadow-sm"
                />
              </div>
            </div>

            {/* Profile Picture */}
            <div className="flex flex-col gap-1.5 mt-1">
              <label className="text-sm font-bold text-[#C9A87C]/90">
                Profile Picture (Optional)
              </label>
              <div className="flex items-center gap-3 ml-8">
                <span className="text-xs text-[#C9A87C]">Choose File : No File Choosen</span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleProfilePictureChange}
                  className="opacity-0 absolute w-40 cursor-pointer"
                />
              </div>
            </div>

            {/* Terms & Privacy */}
            <div className="space-y-2 mt-4">
              <label className="flex items-center text-sm font-bold text-[#C9A87C]/90 gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  name="terms_and_conditions"
                  checked={form.terms_and_conditions}
                  onChange={handleChange}
                  className="h-5 w-5 border-2 border-[#C9A87C] rounded bg-transparent text-[#C9A87C] focus:ring-[#C9A87C]"
                />
                <span>I agree to the Terms & Conditions</span>
              </label>

              <label className="flex items-center text-sm font-bold text-[#C9A87C]/90 gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  name="privacy_policy"
                  checked={form.privacy_policy}
                  onChange={handleChange}
                  className="h-5 w-5 border-2 border-[#C9A87C] rounded bg-transparent text-[#C9A87C] focus:ring-[#C9A87C]"
                />
                <span>I have read and accept the Privacy Policy</span>
              </label>
            </div>

            {/* Submit button */}
            <div className="flex justify-end mt-4">
              <button
                type="submit"
                disabled={loading}
                className="bg-[#C9A87C] hover:bg-[#b08e62] text-white font-bold px-10 py-2.5 rounded-[0.8rem] shadow-[0_6px_12px_rgba(201,168,124,0.3)] transform transition-all active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed text-base"
              >
                {loading ? "Processing..." : "Sign Up"}
              </button>
            </div>
          </form>
        </div>
      </div>


      {/* Right side: Image portion */}
      <div className="hidden md:flex flex-[0.8] h-screen bg-transparent overflow-hidden relative justify-center items-center z-20">


        {/* Doctor and Ruler */}
        <div className="absolute right-0 bottom-0 h-screen w-full flex items-end justify-end pointer-events-none">
          <div className="relative h-[100vh] flex items-end translate-x-12">
            <img
              src={doctor}
              alt="Doctor"
              className="h-full w-auto object-contain z-[40] drop-shadow-[-20px_20px_40px_rgba(0,0,0,0.15)]"
            />
            <img src={ellipse2} alt="" className="absolute bottom-0 left-0 w-full h-[100vh] z-[30]" />
            <img src={ellipse1} alt="" className="absolute bottom-0 -left-10 w-full h-[100vh] z-[20]" />
          </div>
        </div>
      </div>
    </div>
  );
};
