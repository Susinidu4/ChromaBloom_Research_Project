import React from "react";

import logoMark from "../assets/Chromabloom1.png";
import logoText from "../assets/Chromabloom2.png";

export default function Header() {
  return (
    <header className="w-full bg-[#386884] shadow-[0_12px_20px_rgba(0,0,0,0.35)]">
      <div className="h-16 flex items-center px-12">
        <div className="flex items-center">
          {/* left small icon */}
          <img
            src={logoMark}
            alt="ChromaBloom Mark"
            className="h-10 w-auto object-contain"
          />

          {/* ChromaBloom text as image */}
          <img
            src={logoText}
            alt="ChromaBloom"
            className="h-6 w-auto object-contain -translate-y-[-12px]"
          />
        </div>
      </div>

      {/* bottom divider line (like your UI) */}
      <div className="h-[1px] bg-[#386884]" />
    </header>
  );
}
