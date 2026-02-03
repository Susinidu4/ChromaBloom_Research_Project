import React from "react";
import { Outlet } from "react-router-dom";

import Header from "../../components/Header";
import Sidebar from "../../components/SideBar";
import Footer from "../../components/Footer";

export default function AdminLayout({ children }) {
  return (
    <div className="min-h-screen flex flex-col bg-[#F3E8E8]">
        
      {/* Header (stays on top) */}
      <div className="sticky top-0 z-50">
        <Header />
      </div>

      {/* Body: Sidebar + Content */}
      <div className="flex flex-1">

        {/* Sidebar */}
        <div className="w-[240px] shrink-0">
          <Sidebar />
        </div>

        {/* Page content area */}
        <main className="flex-1 bg-[#F3E8E8] min-h-0 overflow-auto">
          {children ?? <Outlet />}
        </main>

      </div>

      {/* Footer (always at bottom) */}
      <Footer />

    </div>
  );
}
