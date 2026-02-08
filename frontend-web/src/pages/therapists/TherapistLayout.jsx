import { Outlet } from "react-router-dom";

import Header from "../../components/Header";
import Sidebar from "../../components/SideBar";
import Footer from "../../components/Footer";

export default function TherapistLayout({ children }) {
  return (
    <div className="min-h-screen bg-[#F3E8E8]">
      {/* Header stays on top */}
      <div className="sticky top-0 z-50">
        <Header />
      </div>

      {/* Body + Footer scroll together */}
      <div className="flex flex-col min-h-[calc(100vh-64px)]">
        {/* Main content */}
        <main className="flex-1">
          {children ?? <Outlet />}
        </main>

        {/* Footer (after body) */}
        <Footer />
      </div>
    </div>
  );
}
