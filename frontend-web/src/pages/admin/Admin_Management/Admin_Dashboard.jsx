<<<<<<< HEAD
import React, { useMemo, useState, useEffect } from "react";
import { HiDotsHorizontal } from "react-icons/hi";
import { Link } from "react-router-dom";
import AdminLayout from "./AdminLayout";
import { IoSearchSharp } from "react-icons/io5";
import { getAdmins, updateAccountStatus, deleteAdmin } from "../../../services/Admin/adminService";
import { FaTrash } from "react-icons/fa";
import { getAllChildrenService, updateChildStatusService } from "../../../services/childService";
import { getAllTherapistsService, updateTherapistAccountStatus } from "../../../services/therapistService";
import Swal from "sweetalert2";



export const Admin_Dashboard = () => {
  const [activeTab, setActiveTab] = useState("patients"); // patients | therapists | admins
  const [search, setSearch] = useState("");
  const [adminList, setAdminList] = useState([]);
  const [patientList, setPatientList] = useState([]);
  const [therapistList, setTherapistList] = useState([]);
  const [showCreateMenu, setShowCreateMenu] = useState(false);

  // Fetch Data based on active tab
  useEffect(() => {
    const fetchData = async () => {
      try {
        if (activeTab === "admins") {
          const data = await getAdmins();
          setAdminList(data);
        } else if (activeTab === "patients") {
          // Pass token if required, for now calling without
          const data = await getAllChildrenService();
          // Transform data to match table structure if needed
          // Backend returns array of children
          setPatientList(data);
          console.log(data);
        } else if (activeTab === "therapists") {
          const data = await getAllTherapistsService();
          setTherapistList(data);
        }
      } catch (err) {
        console.error(`Failed to fetch ${activeTab}`, err);
      }
    };
    fetchData();
  }, [activeTab]);

  const therapists = useMemo(
    () => [
      // Dummy data removed
    ],
    []
  );

  const calculateAge = (birthDate) => {
    if (!birthDate) return "N/A";
    const birth = new Date(birthDate);
    const now = new Date();
    let age = now.getFullYear() - birth.getFullYear();
    const m = now.getMonth() - birth.getMonth();
    if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) {
      age--;
    }
    return age;
  }

  const data = activeTab === "patients" ? patientList : activeTab === "therapists" ? therapistList : adminList;

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return data;

    return data.filter((row) => JSON.stringify(row).toLowerCase().includes(q));
  }, [data, search]);

  const handleChildStatusToggle = async (childId, currentStatus) => {
    const newStatus = currentStatus === "active" ? "inactive" : "active";

    const result = await Swal.fire({
      title: `Mark as ${newStatus}?`,
      text: `This will ${newStatus === 'inactive' ? 'disable' : 'enable'} the child account.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#d33",
      confirmButtonText: "Yes, update it!"
    });

    if (result.isConfirmed) {
      try {
        await updateChildStatusService(childId, newStatus);
        setPatientList(prev => prev.map(p => p._id === childId ? { ...p, account_status: newStatus } : p));
        Swal.fire("Updated!", `Child status has been updated to ${newStatus}.`, "success");
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to update status", "error");
      }
    }
  };

  const handleMore = (id) => {
    alert(`More clicked: ${id} (open menu/modal later)`);
  };

  const handleTherapistStatusToggle = async (therapistId, currentStatus) => {
    const newStatus = currentStatus === "active" ? "inactive" : "active";

    const result = await Swal.fire({
      title: `Mark as ${newStatus}?`,
      text: `This will ${newStatus === 'inactive' ? 'disable' : 'enable'} the therapist account.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#d33",
      confirmButtonText: "Yes, update it!"
    });

    if (result.isConfirmed) {
      try {
        await updateTherapistAccountStatus(therapistId, newStatus);
        setTherapistList(prev => prev.map(t => t._id === therapistId ? { ...t, account_status: newStatus } : t));
        Swal.fire("Updated!", `Therapist status has been updated to ${newStatus}.`, "success");
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to update status", "error");
      }
    }
  }

  const handleAdminStatusToggle = async (adminId, currentStatus) => {
    const newStatus = currentStatus === "active" ? "inactive" : "active";

    const result = await Swal.fire({
      title: `Mark as ${newStatus}?`,
      text: `This will ${newStatus === 'inactive' ? 'disable' : 'enable'} the admin account.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#d33",
      confirmButtonText: "Yes, update it!"
    });

    if (result.isConfirmed) {
      try {
        await updateAccountStatus(adminId, newStatus);
        setAdminList(prev => prev.map(a => a._id === adminId ? { ...a, account_status: newStatus } : a));
        Swal.fire("Updated!", `Admin status has been updated to ${newStatus}.`, "success");
      } catch (err) {
        Swal.fire("Error", "Failed to update status", "error");
      }
    }
  }

  const handleDeleteAdmin = async (adminId) => {
    const result = await Swal.fire({
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#BD9A6B",
      confirmButtonText: "Yes, delete it!"
    });

    if (result.isConfirmed) {
      try {
        await deleteAdmin(adminId);
        setAdminList(prev => prev.filter(a => a._id !== adminId));
        Swal.fire("Deleted!", "Admin has been deleted.", "success");
      } catch (err) {
        Swal.fire("Error", "Failed to delete admin", "error");
      }
    }
  };

  return (
    <AdminLayout>
      <div className="w-full h-full bg-[#F3E8E8]">
        {/* Outer canvas like screenshot */}
        <div className="px-10 py-10 pt-20">

          {/* Search and Action Button */}
          <div className="absolute right-10 top-25 flex flex-col items-end gap-3 z-30">
            <div className="relative w-[280px] max-w-[70vw]">
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full bg-[#D9D9D9]/50 rounded-full py-1.5 pl-5 pr-10 outline-none text-[#7A6357] shadow-inner"
                placeholder="Search..."
              />
              <span className="absolute right-4 top-1/2 -translate-y-1/2 text-[#7A6357]">
                <IoSearchSharp />
              </span>
            </div>

            {/* Create Button */}
            {activeTab === "admins" && (
              <Link
                to="/create_admin"
                className="bg-[#BD9A6B] text-white px-6 py-2 rounded-[10px] text-sm font-bold shadow-[0_4px_10px_rgba(0,0,0,0.15)] hover:bg-[#a6865a] active:scale-95 transition-all flex items-center gap-2"
              >
                <span>+ Create New</span>
              </Link>
            )}
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

              <button
                onClick={() => setActiveTab("admins")}
                className={[
                  "px-8 py-3 font-semibold rounded-t-[8px] shadow-[0_8px_14px_rgba(0,0,0,0.18)] ",
                  activeTab === "admins"
                    ? "bg-[#BD9A6B] text-white"
                    : "bg-[#DFC7A7] text-white/90",
                ].join(" ")}
              >
                Admin List
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
                    <div className="text-center">Status</div>
                    <div className="text-center" />
                    <div className="text-center" />
                  </div>
                ) : activeTab === "therapists" ? (
                  <div className="grid grid-cols-[2fr_2fr_1.5fr_1.3fr_1.2fr_48px] gap-3">
                    <div>Name</div>
                    <div className="text-center">Email</div>
                    <div className="text-center">Mobile</div>
                    <div className="text-center">Status</div>
                    <div className="text-center" />
                    <div className="text-center" />
                  </div>
                ) : (
                  // Admin Header
                  <div className="grid grid-cols-[2fr_2fr_1.5fr_1fr_1.2fr] gap-3">
                    <div>Name</div>
                    <div className="text-center">Email</div>
                    <div className="text-center">Mobile</div>
                    <div className="text-center">Status</div>
                    <div className="text-center" />
                  </div>
                )}
              </div>

              <div className="h-[1px] bg-[#D9C7BF]" />

              {/* Scrollable body */}
              <div className="max-h-[440px] overflow-auto px-8 py-2 custom-scroll">
                {filtered.map((row) => (
                  <div key={row.id || row._id} className="py-1">
                    {activeTab === "patients" ? (
                      <div className="grid grid-cols-[2fr_1fr_1fr_2fr_1.3fr_1.2fr_48px] gap-3 text-[13px] text-[#BD9A6B]">
                        <div className="truncate">{row.childName}</div>
                        <div className="text-center">{calculateAge(row.dateOfBirth)}</div>
                        <div className="text-center">{row.gender}</div>
                        <div className="text-center truncate">
                          {row.caregiver?.full_name || "N/A"}
                        </div>
                        <div className="text-center uppercase text-sm font-bold">{row.account_status || "active"}</div>

                        {/* Status Toggle button */}
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleChildStatusToggle(row._id, row.account_status || "active")}
                            className={`${(row.account_status || 'active') === 'active' ? 'bg-[#711A0C]' : 'bg-[#2E7D32]'} text-white px-5 py-1.5 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99] transition-colors`}
                          >
                            {(row.account_status || 'active') === 'active' ? 'Disable' : 'Enable'}
                          </button>
                        </div>

                        {/* More button */}
                        <div className="flex justify-center">
                          <Link to={`/child_info/${row._id}`}>
                            <button className="h-9 w-9 rounded-[10px] bg-[#BD9A6B] text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:brightness-95 active:scale-[0.99]"
                            >
                              <HiDotsHorizontal size={18} />
                            </button>
                          </Link>
                        </div>
                      </div>
                    ) : activeTab === "therapists" ? (
                      <div className="grid grid-cols-[2fr_2fr_1.5fr_1.3fr_1.2fr_48px] gap-3 text-[13px] text-[#B0896E]">
                        <div className="truncate">{row.full_name}</div>
                        <div className="text-center truncate">{row.email}</div>
                        <div className="text-center">{row.phone}</div>
                        <div className="text-center uppercase text-sm font-bold">{row.account_status || "active"}</div>

                        {/* Disable button */}
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleTherapistStatusToggle(row._id, row.account_status || "active")}
                            className="bg-[#711A0C] text-white px-6 py-2 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99]"
                          >
                            {(row.account_status || "active") === 'active' ? 'Disable' : 'Enable'}
                          </button>
                        </div>

                        {/* More button */}
                        <div className="flex justify-center">
                          <Link to={`/therapist_info/${row._id}`}>
                            <button className="h-9 w-9 rounded-[10px] bg-[#BD9A6B] text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:brightness-95 active:scale-[0.99]">
                              <HiDotsHorizontal size={18} />
                            </button>
                          </Link>
                        </div>
                      </div>
                    ) : (
                      // Admin Row
                      <div className="grid grid-cols-[2fr_2fr_1.5fr_1fr_1.2fr] gap-3 text-[13px] text-[#B0896E]">
                        <div className="truncate">{row.full_name}</div>
                        <div className="text-center truncate">{row.email}</div>
                        <div className="text-center">{row.phone || "N/A"}</div>
                        <div className="text-center uppercase text-sm font-bold">{row.account_status}</div>

                        {/* Toggle Status button */}
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleAdminStatusToggle(row._id, row.account_status)}
                            className={`${row.account_status === 'active' ? 'bg-[#711A0C]' : 'bg-[#2E7D32]'} text-white px-5 py-1.5 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99] transition-colors`}
                          >
                            {row.account_status === 'active' ? 'Disable' : 'Enable'}
                          </button>
                        </div>

                        {/* Delete button */}
                        {/* <div className="flex justify-center">
                          <button
                            onClick={() => handleDeleteAdmin(row._id)}
                            className="h-9 w-9 rounded-[10px] bg-red-600 text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:bg-red-700 active:scale-[0.99]"
                            title="Delete Admin"
                          >
                            <FaTrash size={16} />
                          </button>
                        </div> */}

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
=======
import React, { useMemo, useState, useEffect } from "react";
import { HiDotsHorizontal } from "react-icons/hi";
import { Link } from "react-router-dom";
import AdminLayout from "./AdminLayout";
import { IoSearchSharp } from "react-icons/io5";
import { getAdmins, updateAccountStatus, deleteAdmin } from "../../../services/Admin/adminService";
import { FaTrash } from "react-icons/fa";
import { getAllChildrenService, updateChildStatusService } from "../../../services/childService";
import { getAllTherapistsService, updateTherapistAccountStatus } from "../../../services/therapistService";
import Swal from "sweetalert2";



export const Admin_Dashboard = () => {
  const [activeTab, setActiveTab] = useState("patients"); // patients | therapists | admins
  const [search, setSearch] = useState("");
  const [adminList, setAdminList] = useState([]);
  const [patientList, setPatientList] = useState([]);
  const [therapistList, setTherapistList] = useState([]);
  const [showCreateMenu, setShowCreateMenu] = useState(false);

  // Fetch Data based on active tab
  useEffect(() => {
    const fetchData = async () => {
      try {
        if (activeTab === "admins") {
          const data = await getAdmins();
          setAdminList(data);
        } else if (activeTab === "patients") {
          // Pass token if required, for now calling without
          const data = await getAllChildrenService();
          // Transform data to match table structure if needed
          // Backend returns array of children
          setPatientList(data);
          console.log(data);
        } else if (activeTab === "therapists") {
          const data = await getAllTherapistsService();
          setTherapistList(data);
        }
      } catch (err) {
        console.error(`Failed to fetch ${activeTab}`, err);
      }
    };
    fetchData();
  }, [activeTab]);

  const therapists = useMemo(
    () => [
      // Dummy data removed
    ],
    []
  );

  const calculateAge = (birthDate) => {
    if (!birthDate) return "N/A";
    const birth = new Date(birthDate);
    const now = new Date();
    let age = now.getFullYear() - birth.getFullYear();
    const m = now.getMonth() - birth.getMonth();
    if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) {
      age--;
    }
    return age;
  }

  const data = activeTab === "patients" ? patientList : activeTab === "therapists" ? therapistList : adminList;

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return data;

    return data.filter((row) => JSON.stringify(row).toLowerCase().includes(q));
  }, [data, search]);

  const handleChildStatusToggle = async (childId, currentStatus) => {
    const newStatus = currentStatus === "active" ? "inactive" : "active";

    const result = await Swal.fire({
      title: `Mark as ${newStatus}?`,
      text: `This will ${newStatus === 'inactive' ? 'disable' : 'enable'} the child account.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#d33",
      confirmButtonText: "Yes, update it!"
    });

    if (result.isConfirmed) {
      try {
        await updateChildStatusService(childId, newStatus);
        setPatientList(prev => prev.map(p => p._id === childId ? { ...p, account_status: newStatus } : p));
        Swal.fire("Updated!", `Child status has been updated to ${newStatus}.`, "success");
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to update status", "error");
      }
    }
  };

  const handleMore = (id) => {
    alert(`More clicked: ${id} (open menu/modal later)`);
  };

  const handleTherapistStatusToggle = async (therapistId, currentStatus) => {
    const newStatus = currentStatus === "active" ? "inactive" : "active";

    const result = await Swal.fire({
      title: `Mark as ${newStatus}?`,
      text: `This will ${newStatus === 'inactive' ? 'disable' : 'enable'} the therapist account.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#d33",
      confirmButtonText: "Yes, update it!"
    });

    if (result.isConfirmed) {
      try {
        await updateTherapistAccountStatus(therapistId, newStatus);
        setTherapistList(prev => prev.map(t => t._id === therapistId ? { ...t, account_status: newStatus } : t));
        Swal.fire("Updated!", `Therapist status has been updated to ${newStatus}.`, "success");
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "Failed to update status", "error");
      }
    }
  }

  const handleAdminStatusToggle = async (adminId, currentStatus) => {
    const newStatus = currentStatus === "active" ? "inactive" : "active";

    const result = await Swal.fire({
      title: `Mark as ${newStatus}?`,
      text: `This will ${newStatus === 'inactive' ? 'disable' : 'enable'} the admin account.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#BD9A6B",
      cancelButtonColor: "#d33",
      confirmButtonText: "Yes, update it!"
    });

    if (result.isConfirmed) {
      try {
        await updateAccountStatus(adminId, newStatus);
        setAdminList(prev => prev.map(a => a._id === adminId ? { ...a, account_status: newStatus } : a));
        Swal.fire("Updated!", `Admin status has been updated to ${newStatus}.`, "success");
      } catch (err) {
        Swal.fire("Error", "Failed to update status", "error");
      }
    }
  }

  const handleDeleteAdmin = async (adminId) => {
    const result = await Swal.fire({
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#BD9A6B",
      confirmButtonText: "Yes, delete it!"
    });

    if (result.isConfirmed) {
      try {
        await deleteAdmin(adminId);
        setAdminList(prev => prev.filter(a => a._id !== adminId));
        Swal.fire("Deleted!", "Admin has been deleted.", "success");
      } catch (err) {
        Swal.fire("Error", "Failed to delete admin", "error");
      }
    }
  };

  return (
    <AdminLayout>
      <div className="w-full h-full bg-[#F3E8E8]">
        {/* Outer canvas like screenshot */}
        <div className="px-10 py-10 pt-20">

          {/* Search and Action Button */}
          <div className="absolute right-10 top-25 flex flex-col items-end gap-3 z-30">
            <div className="relative w-[280px] max-w-[70vw]">
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full bg-[#D9D9D9]/50 rounded-full py-1.5 pl-5 pr-10 outline-none text-[#7A6357] shadow-inner"
                placeholder="Search..."
              />
              <span className="absolute right-4 top-1/2 -translate-y-1/2 text-[#7A6357]">
                <IoSearchSharp />
              </span>
            </div>

            {/* Create Button with Dropdown */}
            <div className="relative">
              <button
                onClick={() => setShowCreateMenu(!showCreateMenu)}
                className="bg-[#BD9A6B] text-white px-6 py-2 rounded-[10px] text-sm font-bold shadow-[0_4px_10px_rgba(0,0,0,0.15)] hover:bg-[#a6865a] active:scale-95 transition-all flex items-center gap-2"
              >
                <span>+ Create New</span>
              </button>

              {showCreateMenu && (
                <>
                  <div
                    className="fixed inset-0 z-40"
                    onClick={() => setShowCreateMenu(false)}
                  />
                  <div className="absolute right-0 mt-2 w-52 bg-white rounded-xl shadow-2xl border border-[#BD9A6B]/20 py-2 z-50 overflow-hidden transform transition-all">
                    <Link
                      to="/create_admin"
                      className="block px-4 py-3 text-[#7A6357] hover:bg-[#BD9A6B] hover:text-white transition-colors text-sm font-semibold"
                      onClick={() => setShowCreateMenu(false)}
                    >
                      Admin Account
                    </Link>
                    <div className="mx-2 h-[1px] bg-[#F3E8E8]" />
                    <Link
                      to="/therapists_register"
                      className="block px-4 py-3 text-[#7A6357] hover:bg-[#BD9A6B] hover:text-white transition-colors text-sm font-semibold"
                      onClick={() => setShowCreateMenu(false)}
                    >
                      Therapist Account
                    </Link>
                  </div>
                </>
              )}
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

              <button
                onClick={() => setActiveTab("admins")}
                className={[
                  "px-8 py-3 font-semibold rounded-t-[8px] shadow-[0_8px_14px_rgba(0,0,0,0.18)] ",
                  activeTab === "admins"
                    ? "bg-[#BD9A6B] text-white"
                    : "bg-[#DFC7A7] text-white/90",
                ].join(" ")}
              >
                Admin List
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
                    <div className="text-center">Status</div>
                    <div className="text-center" />
                    <div className="text-center" />
                  </div>
                ) : activeTab === "therapists" ? (
                  <div className="grid grid-cols-[2fr_2fr_1.5fr_1.3fr_1.2fr_48px] gap-3">
                    <div>Name</div>
                    <div className="text-center">Email</div>
                    <div className="text-center">Mobile</div>
                    <div className="text-center">Status</div>
                    <div className="text-center" />
                    <div className="text-center" />
                  </div>
                ) : (
                  // Admin Header
                  <div className="grid grid-cols-[2fr_2fr_1.5fr_1fr_1.2fr_48px_48px] gap-3">
                    <div>Name</div>
                    <div className="text-center">Email</div>
                    <div className="text-center">Mobile</div>
                    <div className="text-center">Status</div>
                    <div className="text-center" />
                    <div className="text-center" />
                    <div className="text-center" />
                  </div>
                )}
              </div>

              <div className="h-[1px] bg-[#D9C7BF]" />

              {/* Scrollable body */}
              <div className="max-h-[440px] overflow-auto px-8 py-2 custom-scroll">
                {filtered.map((row) => (
                  <div key={row.id || row._id} className="py-1">
                    {activeTab === "patients" ? (
                      <div className="grid grid-cols-[2fr_1fr_1fr_2fr_1.3fr_1.2fr_48px] gap-3 text-[13px] text-[#BD9A6B]">
                        <div className="truncate">{row.childName}</div>
                        <div className="text-center">{calculateAge(row.dateOfBirth)}</div>
                        <div className="text-center">{row.gender}</div>
                        <div className="text-center truncate">
                          {row.caregiver?.full_name || "N/A"}
                        </div>
                        <div className="text-center uppercase text-sm font-bold">{row.account_status || "active"}</div>

                        {/* Status Toggle button */}
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleChildStatusToggle(row._id, row.account_status || "active")}
                            className={`${(row.account_status || 'active') === 'active' ? 'bg-[#711A0C]' : 'bg-[#2E7D32]'} text-white px-5 py-1.5 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99] transition-colors`}
                          >
                            {(row.account_status || 'active') === 'active' ? 'Disable' : 'Enable'}
                          </button>
                        </div>

                        {/* More button */}
                        <div className="flex justify-center">
                          <Link to={`/child_info/${row._id}`}>
                            <button className="h-9 w-9 rounded-[10px] bg-[#BD9A6B] text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:brightness-95 active:scale-[0.99]"
                            >
                              <HiDotsHorizontal size={18} />
                            </button>
                          </Link>
                        </div>
                      </div>
                    ) : activeTab === "therapists" ? (
                      <div className="grid grid-cols-[2fr_2fr_1.5fr_1.3fr_1.2fr_48px] gap-3 text-[13px] text-[#B0896E]">
                        <div className="truncate">{row.full_name}</div>
                        <div className="text-center truncate">{row.email}</div>
                        <div className="text-center">{row.phone}</div>
                        <div className="text-center uppercase text-sm font-bold">{row.account_status || "active"}</div>

                        {/* Disable button */}
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleTherapistStatusToggle(row._id, row.account_status || "active")}
                            className="bg-[#711A0C] text-white px-6 py-2 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99]"
                          >
                            {(row.account_status || "active") === 'active' ? 'Disable' : 'Enable'}
                          </button>
                        </div>

                        {/* More button */}
                        <div className="flex justify-center">
                          <Link to={`/therapist_info/${row._id}`}>
                            <button className="h-9 w-9 rounded-[10px] bg-[#BD9A6B] text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:brightness-95 active:scale-[0.99]">
                              <HiDotsHorizontal size={18} />
                            </button>
                          </Link>
                        </div>
                      </div>
                    ) : (
                      // Admin Row
                      <div className="grid grid-cols-[2fr_2fr_1.5fr_1fr_1.2fr_48px_48px] gap-3 text-[13px] text-[#B0896E]">
                        <div className="truncate">{row.full_name}</div>
                        <div className="text-center truncate">{row.email}</div>
                        <div className="text-center">{row.phone || "N/A"}</div>
                        <div className="text-center uppercase text-sm font-bold">{row.account_status}</div>

                        {/* Toggle Status button */}
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleAdminStatusToggle(row._id, row.account_status)}
                            className={`${row.account_status === 'active' ? 'bg-[#711A0C]' : 'bg-[#2E7D32]'} text-white px-5 py-1.5 rounded-[8px]
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] hover:brightness-95 active:scale-[0.99] transition-colors`}
                          >
                            {row.account_status === 'active' ? 'Disable' : 'Enable'}
                          </button>
                        </div>

                        {/* Delete button */}
                        {/* <div className="flex justify-center">
                          <button
                            onClick={() => handleDeleteAdmin(row._id)}
                            className="h-9 w-9 rounded-[10px] bg-red-600 text-white
                                         shadow-[0_6px_10px_rgba(0,0,0,0.18)] grid place-items-center
                                         hover:bg-red-700 active:scale-[0.99]"
                            title="Delete Admin"
                          >
                            <FaTrash size={16} />
                          </button>
                        </div> */}

                        {/* More button */}
                        <div className="flex justify-center">
                          <button
                            onClick={() => handleMore(row._id)}
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
>>>>>>> origin/Interactive-Visual-Task-Scheduler
