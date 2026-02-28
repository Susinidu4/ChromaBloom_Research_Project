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
      // { message, therapist, token }

      // Save token + therapist info (simple example)
      localStorage.setItem("therapist_token", data.token);
      localStorage.setItem("therapist_info", JSON.stringify(data.therapist));

      setSuccessMsg("Login successful!");
      // redirect to therapist dashboard (change route as you want)
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
    <div className="min-h-screen w-full bg-[#386884] relative overflow-hidden">
      {/* Left light area */}
      <div className="absolute inset-y-0 left-0 w-[70%] bg-[#F3E8E8]" />

      {/* Home Button */}
      <button
        onClick={() => navigate("/")}
        className="absolute top-6 right-8 z-50 p-3 rounded-full bg-gray-100 text-[#BD9A6B] shadow-lg hover:bg-[#A6865A] transition-all duration-300 group cursor-pointer"
        title="Go to Home"
      >
        <FaHome className="text-2xl group-hover:scale-110 transition-transform" />
      </button>

      {/* RIGHT blue area clipped into a curve */}
      <div className="absolute inset-y-0 -left-30 w-full pointer-events-none z-0">
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

          {/* Right panel fill */}
          <rect
            x="0"
            y="0"
            width="1440"
            height="1024"
            fill="#386884"
            clipPath="url(#rightCurveClipTherapist)"
          />

          {/* Light-blue strip */}
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
      <div className="relative z-10 min-h-screen flex">
        {/* LEFT COLUMN */}
        <div className="w-full lg:w-[58%] flex flex-col">
          {/* brand */}
          <div className="px-10 pt-8">
            <div className="flex items-center gap-2">
              <img
                src={logi1}
                alt="ChromaBloom Mark"
                className="w-16 h-auto object-contain -mt-6"
                draggable="false"
              />
              <img
                src={logi2}
                alt="ChromaBloom Text"
                className="w-56 h-auto object-contain"
                draggable="false"
              />
            </div>

            <div className="-mt-1 ml-[30px] text-[10px] md:text-[11px] tracking-[0.25em] text-[#BD9A6B]/80">
              WHERE CARE MEETS INTELLINTELLIGENCE
            </div>
          </div>

          {/* illustration */}
          <div className="flex-1 flex items-end justify-start px-10 pb-10">
            <img
              src={characters}
              alt="Doctor and Therapist"
              className="w-[380px] ml-30 max-w-full object-contain drop-shadow-[0_12px_18px_rgba(0,0,0,0.25)]"
              draggable="false"
            />
          </div>
        </div>

        {/* RIGHT COLUMN */}
        <div className="w-full lg:w-[42%] flex items-center justify-center px-6">
          <div className="w-full max-w-[420px]">
            <div
              className="rounded-2xl border border-[#BD9A6B] bg-[#5E7890]/60
                       shadow-[0_18px_35px_rgba(0,0,0,0.35)]
                       px-10 py-10 relative"
            >
              <h1 className="text-3xl font-extrabold text-[#BD9A6B] tracking-wide drop-shadow-[0_3px_0_rgba(0,0,0,0.25)]">
                LOGIN
              </h1>

              {/* Errors / Success (same states, UI only changed) */}
              {errorMsg && (
                <div className="mt-4 bg-[#ABD1DC] text-[#1E1E1E] border border-[#BD9A6B] px-3 py-2 rounded-lg text-sm">
                  {errorMsg}
                </div>
              )}

              {successMsg && (
                <div className="mt-4 bg-[#DFF3E6] text-[#1E1E1E] border border-[#BD9A6B] px-3 py-2 rounded-lg text-sm">
                  {successMsg}
                </div>
              )}

              <form onSubmit={handleSubmit} className="mt-8 space-y-6">
                {/* Email */}
                <div>
                  <label className="block text-xs font-semibold text-[#BD9A6B]/90 mb-2">
                    Email
                  </label>
                  <input
                    type="email"
                    name="email"
                    required
                    value={form.email}
                    onChange={handleChange}
                    className="w-full bg-transparent text-[#E9DDCC]
                             border border-[#BD9A6B] rounded-xl
                             px-4 py-3 outline-none
                             focus:ring-2 focus:ring-[#BD9A6B]/40"
                    placeholder=""
                  />
                </div>

                {/* Password */}
                <div>
                  <label className="block text-xs font-semibold text-[#BD9A6B]/90 mb-2">
                    Password
                  </label>
                  <input
                    type="password"
                    name="password"
                    required
                    value={form.password}
                    onChange={handleChange}
                    className="w-full bg-transparent text-[#E9DDCC]
                             border border-[#BD9A6B] rounded-xl
                             px-4 py-3 outline-none
                             focus:ring-2 focus:ring-[#BD9A6B]/40"
                    placeholder=""
                  />
                </div>

                {/* Submit */}
                <div className="pt-2 flex justify-center">
                  <button
                    type="submit"
                    disabled={loading}
                    className="px-14 py-3 rounded-xl font-semibold
                             bg-[#BD9A6B] text-white
                             shadow-[0_10px_20px_rgba(0,0,0,0.25)]
                             hover:brightness-95 disabled:opacity-60"
                  >
                    {loading ? "Logging in..." : "Log in"}
                  </button>
                </div>
              </form>

              {/* Register link (same route, UI only changed) */}
              <div className="mt-8 text-center text-xs text-[#BD9A6B]/80">
                Don&apos;t have an account?{" "}
                <Link to="/therapists_register" className="text-[#BD9A6B] hover:underline">
                  Signup
                </Link>
              </div>
            </div>

            <div className="h-8" />
          </div>
        </div>
      </div>
    </div>
  );

};
