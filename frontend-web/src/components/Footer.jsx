import React from "react";

import logoMark from "../assets/Chromabloom1.png";
import logoText from "../assets/Chromabloom2.png";

export default function Footer() {
  return (
    <footer className="w-full bg-[#386884] rounded-tr-[28px]">
      {/* Rounded container */}
      <div className="rounded-t-[28px] px-6 pt-10">

        {/* Logo area */}
        <div className="flex flex-col items-center justify-center">
          {/* Rotated logo mark */}
          <img
            src={logoMark}
            alt="ChromaBloom mark"
            className="h-18 w-auto object-contain mb-2"
          />

          {/* Logo text */}
          <img
            src={logoText}
            alt="ChromaBloom"
            className="h-8 w-auto object-contain"
          />
        </div>

        {/* Divider line */}
        <div className="mt-6 h-[1px] w-full bg-[#DFC7A7]/70" />

        {/* Copyright */}
        <p className="py-4 text-center text-xs text-[#DFC7A7]">
          Copyright © 2026 BrainyBunch Team. All rights reserved.
        </p>
      </div>
    </footer>
  );
}
