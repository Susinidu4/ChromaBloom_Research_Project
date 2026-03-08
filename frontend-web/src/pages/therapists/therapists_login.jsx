import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { FaHome } from "react-icons/fa";
import { loginTherapistService } from "../../services/therapistService";

import characters from "../../assets/LoginWeb.png";
import logi1 from "../../assets/ChromaBloom1.png";
import logi2 from "../../assets/ChromaBloom2.png";


export const TherapistsLogin = () => {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    email: "",
    password: "",
  });

  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const handleChange = (e) => {
    setForm((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg("");
    setSuccessMsg("");
    setLoading(true);

    try {
      const data = await loginTherapistService(form);
      localStorage.setItem("therapist_token", data.token);
      localStorage.setItem("therapist_info", JSON.stringify(data.therapist));
      setSuccessMsg("Login successful!");
      navigate("/therapists_dashboard");
    } catch (error) {
      console.error("Therapist login error:", error);
      setErrorMsg(
        error.response?.data?.message || "Login failed. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full bg-[#386884] relative overflow-x-hidden">
      {/* Background Areas - Adjusted for mobile */}
      <div className="absolute inset-y-0 left-0 w-full lg:w-[70%] bg-[#F3E8E8]" />

      {/* Home Button */}
      <button
        onClick={() => navigate("/")}
        className="absolute top-4 right-4 md:top-6 md:right-8 z-50 p-2.5 md:p-3 rounded-full bg-white/80 backdrop-blur-sm text-[#BD9A6B] shadow-lg hover:bg-[#BD9A6B] hover:text-white transition-all duration-300 group cursor-pointer"
        title="Go to Home"
      >
        <FaHome className="text-xl md:text-2xl group-hover:scale-110 transition-transform" />
      </button>

      {/* RIGHT blue area clipped into a curve - Hidden on mobile */}
      <div className="hidden lg:block absolute inset-y-0 -left-30 w-full pointer-events-none z-0">
        <svg viewBox="0 0 1440 1024" preserveAspectRatio="none" className="h-full w-full">
          <defs>
            <clipPath id="rightCurveClipTherapist">
              <path
                d="
                M 860 0
                C 760 160, 760 330, 820 480
                C 900 680, 900 780, 820 960
                C 760 1100, 780 1180, 860 1024
                L 1440 1024
                L 1440 0
                Z
                "
              />
            </clipPath>

            <filter id="softShadowTherapist" x="-20%" y="-20%" width="140%" height="140%">
              <feDropShadow
                dx="8"
                dy="0"
                stdDeviation="12"
                floodColor="#000000"
                floodOpacity="0.25"
              />
            </filter>
          </defs>

          <rect
            x="0"
            y="0"
            width="1440"
            height="1024"
            fill="#386884"
            clipPath="url(#rightCurveClipTherapist)"
          />

          <path
            d="
            M 835 0
            C 740 160, 740 340, 800 490
            C 880 690, 880 790, 800 970
            C 735 1110, 760 1185, 835 1024
            L 900 1024
            C 820 1180, 800 1100, 860 960
            C 940 780, 940 680, 860 480
            C 800 330, 800 160, 900 0
            Z
            "
            fill="#6993AB"
            filter="url(#softShadowTherapist)"
          />
        </svg>
      </div>


      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col lg:flex-row">
        {/* LEFT COLUMN */}
        <div className="w-full lg:w-[58%] flex flex-col min-h-[40vh] lg:min-h-screen">
          {/* brand */}
          <div className="px-6 md:px-10 pt-8">
            <div className="flex items-center gap-2">
              <img
                src={logi1}
                alt="ChromaBloom Mark"
                className="w-12 md:w-16 h-auto object-contain -mt-4 md:-mt-6"
                draggable="false"
              />
              <img
                src={logi2}
                alt="ChromaBloom Text"
                className="w-40 md:w-56 h-auto object-contain"
                draggable="false"
              />
            </div>

            <div className="-mt-1 ml-[24px] md:ml-[30px] text-[8px] md:text-[11px] tracking-[0.25em] text-[#BD9A6B]/80 font-bold">
              WHERE CARE MEETS INTELLIGENCE
            </div>
          </div>

          {/* illustration */}
          <div className="flex-1 flex items-center lg:items-end justify-center lg:justify-start px-10 pb-6 lg:pb-10 overflow-hidden">

            <img
              src={characters}
              alt="Doctor and Therapist"
              className="w-[280px] md:w-[380px] lg:ml-30 max-w-full object-contain drop-shadow-[0_12px_18px_rgba(0,0,0,0.25)] transform scale-110 lg:scale-100"
              draggable="false"
            />
          </div>
        </div>


        {/* RIGHT COLUMN */}
        <div className="w-full lg:w-[42%] flex items-center justify-center px-6 pb-12 lg:pb-0 bg-[#386884] lg:bg-transparent">
          <div className="w-full max-w-[420px]">
            <div
              className="rounded-3xl border border-[#BD9A6B] bg-[#5E7890]/80 backdrop-blur-md
                       shadow-[0_20px_40px_rgba(0,0,0,0.4)]
                       px-8 md:px-10 py-10 relative"
            >
              <h1 className="text-2xl md:text-3xl font-extrabold text-[#BD9A6B] tracking-wide drop-shadow-[0_3px_0_rgba(0,0,0,0.25)] text-center lg:text-left">
                THERAPIST LOGIN
              </h1>


              {errorMsg && (
                <div className="mt-4 bg-red-100/10 text-red-100 border border-red-400/50 px-3 py-2 rounded-lg text-sm text-center">
                  {errorMsg}
                </div>
              )}

              {successMsg && (
                <div className="mt-4 bg-green-100/10 text-green-100 border border-green-400/50 px-3 py-2 rounded-lg text-sm text-center">
                  {successMsg}
                </div>
              )}

              <form onSubmit={handleSubmit} className="mt-8 space-y-6">
                {/* Email */}
                <div>
                  <label className="block text-xs font-semibold text-[#BD9A6B]/90 mb-2 uppercase tracking-wider">
                    Email
                  </label>
                  <input
                    type="email"
                    name="email"
                    required
                    value={form.email}
                    onChange={handleChange}
                    className="w-full bg-white/10 text-white placeholder-white/30
                             border border-[#BD9A6B]/50 rounded-2xl
                             px-5 py-3.5 outline-none
                             focus:border-[#BD9A6B] focus:ring-4 focus:ring-[#BD9A6B]/20 transition-all"
                    placeholder="therapist@chromabloom.com"
                  />
                </div>

                {/* Password */}
                <div>
                  <label className="block text-xs font-semibold text-[#BD9A6B]/90 mb-2 uppercase tracking-wider">
                    Password
                  </label>
                  <input
                    type="password"
                    name="password"
                    required
                    value={form.password}
                    onChange={handleChange}
                    className="w-full bg-white/10 text-white placeholder-white/30
                             border border-[#BD9A6B]/50 rounded-2xl
                             px-5 py-3.5 outline-none
                             focus:border-[#BD9A6B] focus:ring-4 focus:ring-[#BD9A6B]/20 transition-all"
                    placeholder="••••••••"
                  />
                </div>

                {/* Submit */}
                <div className="pt-4">
                  <button
                    type="submit"
                    disabled={loading}
                    className="w-full py-4 rounded-2xl font-bold text-lg
                             bg-[#BD9A6B] text-white
                             shadow-[0_10px_25px_rgba(189,154,107,0.4)]
                             hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-60"
                  >
                    {loading ? "LOGGING IN..." : "LOG IN"}
                  </button>
                </div>
              </form>

              {/* Signup Link */}
              <div className="mt-8 text-center">
                <p className="text-sm text-white/80">
                  Don't have an account?{" "}
                  <button
                    onClick={() => navigate("/therapists_register")}
                    className="font-bold text-[#BD9A6B] hover:text-[#E9DDCC] 
                             underline transition-colors duration-300 ml-1"
                  >
                    Sign up here
                  </button>
                </p>
              </div>
            </div>

            <div className="h-8 lg:hidden" />
          </div>
        </div>
      </div>
    </div>
  );
};
