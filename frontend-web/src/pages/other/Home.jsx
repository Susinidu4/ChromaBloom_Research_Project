import React, { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";

import logo1 from "../../assets/ChromaBloom1.png";
import logo2 from "../../assets/ChromaBloom2.png";

export const Home = () => {
  const navigate = useNavigate();
  const [type, setType] = useState("");
  const dropdownRef = useRef(null);
  const [shake, setShake] = useState(false);

  const handleChange = (e) => {
    const v = e.target.value;
    setType(v);

    if (v === "admin") navigate("/admin_login");
    if (v === "therapist") navigate("/therapists_login");
  };

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (!dropdownRef.current) return;

      const clickedOutside = !dropdownRef.current.contains(e.target);

      if (clickedOutside && type === "__open") {
        // trigger shake
        setShake(true);
        setTimeout(() => setShake(false), 350);

        // close dropdown
        setType("");
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [type]);

  return (
    <div className="min-h-screen w-full bg-[#386884] flex items-center justify-center">
      <div className="w-full h-screen flex flex-col items-center justify-center px-6">
        <div className="mb-2">
          <div className="flex flex-col items-center">
            {/* Logo Symbol (top image) */}
            <img
              src={logo1}
              alt="ChromaBloom Symbol"
              className="w-[200px] object-contain mb-4"
              draggable="false"
            />

            {/* Logo Text (bottom image) */}
            <img
              src={logo2}
              alt="ChromaBloom Text"
              className="w-[320px] object-contain"
              draggable="false"
            />
          </div>
        </div>

        {/* Dropdown */}
        <div
          ref={dropdownRef}
          className={`mt-10 w-full max-w-[360px] relative ${shake ? "animate-shake" : ""}`}
        >
          {/* Floating label */}
          <label className="absolute -top-2 left-4 px-2 text-xs font-semibold text-[#BD9A6B] bg-[#386884] z-10">
            Type
          </label>

          {/* Trigger */}
          <button
            type="button"
            onClick={() => setType(type === "__open" ? "" : "__open")}
            className="w-full flex items-center justify-between
               rounded-xl border border-[#BD9A6B]
               bg-transparent px-4 py-3
               text-[#BD9A6B] text-sm font-medium
               shadow-[0_3px_0_rgba(0,0,0,0.12)]"
          >
            <span className={type ? "opacity-100" : "opacity-70"}>
              {type === "admin"
                ? "Admin Login"
                : type === "therapist"
                  ? "Therapists Login"
                  : "Choose..."}
            </span>

            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <path
                d="M6 9l6 6 6-6"
                stroke="#BD9A6B"
                strokeWidth="2.2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </button>

          {/* Dropdown panel */}
          {type === "__open" && (
            <div
              className="absolute mt-2 w-full rounded-xl
                 border border-[#BD9A6B]
                 bg-[#386884]
                 shadow-[0_12px_30px_rgba(0,0,0,0.35)]
                 overflow-hidden z-20"
            >
              <button
                onClick={() => navigate("/admin_login")}
                className="w-full text-left px-4 py-3 text-[#E9DDCC]
                   hover:bg-[#ABD1DC] hover:text-[#386884]
                    transition-colors duration-200"
              >
                Admin Login
              </button>

              <button
                onClick={() => navigate("/therapists_login")}
                className="w-full text-left px-4 py-3 text-[#E9DDCC]
                   hover:bg-[#ABD1DC] hover:text-[#386884]
                    transition-colors duration-200"
              >
                Therapists Login
              </button>
            </div>
          )}
        </div>
      </div>
      <style>
        {`
          @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20% { transform: translateX(-6px); }
            40% { transform: translateX(6px); }
            60% { transform: translateX(-4px); }
            80% { transform: translateX(4px); }
          }

          .animate-shake {
            animation: shake 0.35s ease-in-out;
          }
        `}
      </style>
    </div>
  );
};
