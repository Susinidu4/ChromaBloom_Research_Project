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
        <div className="w-full max-w-[90%] mt-[700px] overflow-y-auto bg-transparent border-[3px] border-[#C9A87C]/50 rounded-[3rem] p-10 md:p-16 my-8 relative shadow-[inset_0_0_50px_rgba(0,0,0,0.2)] [&::-webkit-scrollbar]:hidden [scrollbar-width:none] [-ms-overflow-style:none]">
          <div className="flex justify-between items-start mb-10">
            <div></div> {/* Spacer */}
            <h1 className="text-5xl font-bold text-[#C9A87C] tracking-widest uppercase">
              Sign Up
            </h1>
          </div>

          {errorMsg && (
            <div className="mb-6 text-sm text-red-200 bg-red-900/40 border border-red-500/50 px-4 py-3 rounded-2xl animate-shake">
              {errorMsg}
            </div>
          )}

          <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6 overflow-hidden">
            {/* Full Name */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Full Name
              </label>
              <input
                type="text"
                name="full_name"
                required
                value={form.full_name}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white placeholder-white/30 focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* DOB */}
            <div className="relative">
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Date of Birth
              </label>
              <input
                type="date"
                name="dob"
                value={form.dob}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg appearance-none"
              />
            </div>

            {/* Gender */}
            <div className="relative">
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Gender
              </label>
              <select
                name="gender"
                value={form.gender}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg cursor-pointer"
              >
                <option value="">Select</option>
                <option value="female" className="bg-[#2C536A]">Female</option>
                <option value="male" className="bg-[#2C536A]">Male</option>
                <option value="other" className="bg-[#2C536A]">Other</option>
              </select>
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Email
              </label>
              <input
                type="email"
                name="email"
                required
                value={form.email}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* Password */}
            <div>
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Password
              </label>
              <input
                type="password"
                name="password"
                required
                value={form.password}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* Phone */}
            <div className="md:col-span-1">
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Phone Number
              </label>
              <input
                type="text"
                name="phone"
                value={form.phone}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* Specialization */}
            <div className="hidden md:block"></div> {/* Spacer */}

            {/* Address */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Address
              </label>
              <input
                type="text"
                name="address"
                value={form.address}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* Specialization */}
            <div>
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Specialization
              </label>
              <input
                type="text"
                name="specialization"
                value={form.specialization}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* Start Date */}
            <div>
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Start Date
              </label>
              <input
                type="date"
                name="start_date"
                value={form.start_date}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg appearance-none"
              />
            </div>

            {/* License Number */}
            <div>
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                License Number
              </label>
              <input
                type="text"
                name="licence_number"
                value={form.licence_number}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* Workplace */}
            <div>
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Workplace
              </label>
              <input
                type="text"
                name="work_place"
                value={form.work_place}
                onChange={handleChange}
                className="w-full bg-[#2C536A] border-2 border-[#C9A87C] rounded-[1.5rem] px-6 py-4 text-white focus:outline-none focus:ring-4 focus:ring-[#C9A87C]/20 transition-all shadow-lg"
              />
            </div>

            {/* Profile Picture */}
            <div className="md:col-span-2 mt-2">
              <label className="block text-sm font-medium text-[#C9A87C] mb-2 ml-1">
                Profile Picture (Optional)
              </label>
              <div className="flex items-center gap-4">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleProfilePictureChange}
                  className="w-full text-xs text-[#C9A87C] file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-[#C9A87C]/20 file:text-[#C9A87C] hover:file:bg-[#C9A87C]/30 transition-all cursor-pointer"
                />
              </div>
            </div>

            {/* Terms & Privacy */}
            <div className="md:col-span-2 space-y-2 mt-4">
              <label className="flex items-center text-sm text-[#C9A87C] gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  name="terms_and_conditions"
                  checked={form.terms_and_conditions}
                  onChange={handleChange}
                  className="h-5 w-5 rounded border-[#C9A87C] bg-[#2C536A] text-[#C9A87C] focus:ring-[#C9A87C]"
                />
                <span className="group-hover:text-white transition-colors underline decoration-[#C9A87C]/30">I agree to the Terms & Conditions</span>
              </label>

              <label className="flex items-center text-sm text-[#C9A87C] gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  name="privacy_policy"
                  checked={form.privacy_policy}
                  onChange={handleChange}
                  className="h-5 w-5 rounded border-[#C9A87C] bg-[#2C536A] text-[#C9A87C] focus:ring-[#C9A87C]"
                />
                <span className="group-hover:text-white transition-colors underline decoration-[#C9A87C]/30">I have read and accept the Privacy Policy</span>
              </label>
            </div>

            {/* Submit button */}
            <div className="md:col-span-2 flex justify-end mt-4">
              <button
                type="submit"
                disabled={loading}
                className="bg-[#C9A87C] hover:bg-[#b08e62] text-white font-bold px-12 py-3 rounded-2xl shadow-xl transform transition-all active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed min-w-[160px]"
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
