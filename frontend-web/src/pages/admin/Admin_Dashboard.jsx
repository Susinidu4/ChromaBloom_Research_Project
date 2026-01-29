import React, { useMemo, useState } from "react";
import { HiDotsHorizontal } from "react-icons/hi";
import AdminLayout from "./AdminLayout";

import { IoSearchSharp } from "react-icons/io5";

export const Admin_Dashboard = () => {
  const [activeTab, setActiveTab] = useState("patients");
  const [search, setSearch] = useState("");

  // Dummy data (replace with API later)
  const patients = useMemo(
    () => [
      {
        id: "p-0001",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0002",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0003",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0004",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0005",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0006",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0007",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0008",
        childName: "nima Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0008",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0008",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "p-0008",
        childName: "Adhil Thisakya",
        age: 11,
        gender: "Male",
        parentName: "Stephani De Alwis",
        createdDate: "2/1/2025",
        status: "Active",
      },
    ],
    []
  );

  const therapists = useMemo(
    () => [
      {
        id: "t-0001",
        name: "Kavindu Perera",
        email: "kavindu@gmail.com",
        mobile: "0771234567",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "t-0002",
        name: "Nimali Silva",
        email: "nimali@gmail.com",
        mobile: "0779876543",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "t-0003",
        name: "Chamath Fernando",
        email: "chamath@gmail.com",
        mobile: "0712223333",
        createdDate: "2/1/2025",
        status: "Active",
      },
      {
        id: "t-0004",
        name: "Dilsha Jayasinghe",
        email: "dilsha@gmail.com",
        mobile: "0765551111",
        createdDate: "2/1/2025",
        status: "Active",
      },
    ],
    []
  );

  const data = activeTab === "patients" ? patients : therapists;

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return data;

    return data.filter((row) => JSON.stringify(row).toLowerCase().includes(q));
  }, [data, search]);

  const handleDisable = (id) => {
    alert(`Disable clicked: ${id} (connect API later)`);
  };

  const handleMore = (id) => {
    alert(`More clicked: ${id} (open menu/modal later)`);
  };

  return (
    <AdminLayout>
      <div className="w-full h-full bg-[#F3E8E8]">
        {/* Outer canvas like screenshot */}
        <div className="px-10 py-10 pt-20">
          
            {/* Search top-right */}
            <div className="absolute right-10 top-25">
              <div className="relative w-[280px] max-w-[70vw]">
                <input
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="w-full bg-[#D9D9D9]/50 rounded-full py-1.5 pl-5 pr-10 outline-none text-[#7A6357]"
                  placeholder=""
                />
                <span className="absolute right-4 top-1/2 -translate-y-1/2 text-[#7A6357]">
                  <IoSearchSharp />
                </span>
              </div>
            </div>

            {/* Tabs */}
            <div className="pt-8">
              <div className="inline-flex items-end">
                <button
                  onClick={() => setActiveTab("patients")}
                  className={[
                    "px-8 py-3 font-semibold rounded-t-[8px] shadow-[0_8px_14px_rgba(0,0,0,0.18)]",
                    activeTab === "patients"
                      ? "bg-[#BD9A6B] text-white"
                      : "bg-[#DFC7A7] text-white/90",
                  ].join(" ")}
                >
                  Patient List
                </button>

                <button
                  onClick={() => setActiveTab("therapists")}
                  className={[
                    "px-8 py-3 font-semibold rounded-t-[8px] shadow-[0_8px_14px_rgba(0,0,0,0.18)] ",
                    activeTab === "therapists"
                      ? "bg-[#BD9A6B] text-white"
                      : "bg-[#DFC7A7] text-white/90",
                  ].join(" ")}
                >
                  Therapist List
                </button>
              </div>

              {/* Table container */}
              <div className="border border-[#BD9A6B]/70 rounded-b-[10px] rounded-tr-[10px] mt-0 bg-transparent">
                {/* Header row */}
                <div className="px-8 pt-6 pb-3 text-[#BD9A6B] text-[13px] font-bold">
                  {activeTab === "patients" ? (
                    <div className="grid grid-cols-[2fr_1fr_1fr_2fr_1.3fr_1.2fr_48px] gap-3">
                      <div>Child Name</div>
                      <div className="text-center">Age (years)</div>
                      <div className="text-center">Gender</div>
                      <div className="text-center">Parent Name</div>
                      <div className="text-center">Created Date</div>
                      <div className="text-center" />
                      <div className="text-center" />
                    </div>
                  ) : (
                    <div className="grid grid-cols-[2fr_2fr_1.5fr_1.3fr_1.2fr_48px] gap-3">
                      <div>Name</div>
                      <div className="text-center">Email</div>
                      <div className="text-center">Mobile</div>
                      <div className="text-center">Created Date</div>
                      <div className="text-center" />
                      <div className="text-center" />
                    </div>
                  )}
                </div>

                <div className="h-[1px] bg-[#D9C7BF]" />

                {/* Scrollable body */}
                <div className="max-h-[440px] overflow-auto px-8 py-2 custom-scroll">
                  {filtered.map((row) => (
                    <div key={row.id} className="py-1">
                      {activeTab === "patients" ? (
                        <div className="grid grid-cols-[2fr_1fr_1fr_2fr_1.3fr_1.2fr_48px] gap-3 text-[13px] text-[#BD9A6B]">
                          <div className="truncate">{row.childName}</div>
                          <div className="text-center">{row.age}</div>
                          <div className="text-center">{row.gender}</div>
                          <div className="text-center truncate">
                            {row.parentName}
                          </div>
                          <div className="text-center">{row.createdDate}</div>

                          {/* Disable button */}
                          <div className="flex justify-center">
                            <button
                              onClick={() => handleDisable(row.id)}
                              className="bg-[#711A0C] text-white px-5 py-1.5 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99]"
                            >
                              Disable
                            </button>
                          </div>

                          {/* More button */}
                          <div className="flex justify-center">
                            <button
                              onClick={() => handleMore(row.id)}
                              className="h-6 w-8 rounded-[10px] bg-[#BD9A6B] text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:brightness-95 active:scale-[0.99]"
                              title="More"
                            >
                              <HiDotsHorizontal size={18} />
                            </button>
                          </div>
                        </div>
                      ) : (
                        <div className="grid grid-cols-[2fr_2fr_1.5fr_1.3fr_1.2fr_48px] gap-3 text-[13px] text-[#B0896E]">
                          <div className="truncate">{row.name}</div>
                          <div className="text-center truncate">{row.email}</div>
                          <div className="text-center">{row.mobile}</div>
                          <div className="text-center">{row.createdDate}</div>

                          {/* Disable button */}
                          <div className="flex justify-center">
                            <button
                              onClick={() => handleDisable(row.id)}
                              className="bg-[#711A0C] text-white px-6 py-2 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99]"
                            >
                              Disable
                            </button>
                          </div>

                          {/* More button */}
                          <div className="flex justify-center">
                            <button
                              onClick={() => handleMore(row.id)}
                              className="h-9 w-9 rounded-[10px] bg-[#BD9A6B] text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:brightness-95 active:scale-[0.99]"
                              title="More"
                            >
                              <HiDotsHorizontal size={18} />
                            </button>
                          </div>
                        </div>
                      )}

                      <div className="mt-2 h-[1px] bg-[#D9C7BF]" />
                    </div>
                  ))}

                  {filtered.length === 0 && (
                    <div className="py-16 text-center text-[#9C8577]">
                      No records found.
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Local styles for scrollbar like screenshot */}
            <style>{`
              .custom-scroll::-webkit-scrollbar {
                width: 10px;
              }
              .custom-scroll::-webkit-scrollbar-track {
                background: transparent;
              }
              .custom-scroll::-webkit-scrollbar-thumb {
                background: rgba(183, 154, 106, 0.85);
                border-radius: 999px;
              }
              .custom-scroll {
                scrollbar-color: rgba(183, 154, 106, 0.85) transparent;
                scrollbar-width: thin;
              }
            `}</style>
          </div>
        </div>
    
    </AdminLayout>
  );
};

export default Admin_Dashboard;
