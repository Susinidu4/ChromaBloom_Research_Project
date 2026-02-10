import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { getChildrenByTherapistService } from "../../services/childService";

export const TherapistChildrenList = () => {
  const [children, setChildren] = useState([]);
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const loadChildren = async () => {
      try {
        setLoading(true);
        setErrorMsg("");

        const token = localStorage.getItem("therapist_token");
        const therapistInfoStr = localStorage.getItem("therapist_info");

        if (!token || !therapistInfoStr) {
          setErrorMsg("You are not logged in. Please login again.");
          return;
        }

        const therapistInfo = JSON.parse(therapistInfoStr);
        const therapistId = therapistInfo._id || therapistInfo.therapist_id;

        if (!therapistId) {
          setErrorMsg("Therapist ID not found. Please login again.");
          return;
        }

        const data = await getChildrenByTherapistService(therapistId, token);
        setChildren(Array.isArray(data) ? data : []);
      } catch (err) {
        console.error("Fetch children error:", err);
        setErrorMsg(err.response?.data?.message || "Failed to load children.");
      } finally {
        setLoading(false);
      }
    };

    loadChildren();
  }, []);

  const calculateAge = (dob) => {
    if (!dob) return "—";
    const birthDate = new Date(dob);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  if (loading) {
    return (
      <div className="mt-6 p-4 text-center">
        <p className="text-sm text-[#8c7462]">Loading patient list...</p>
      </div>
    );
  }

  if (errorMsg) {
    return (
      <div className="mt-6 bg-red-50 p-4 rounded-lg border border-red-200">
        <p className="text-sm text-red-700">{errorMsg}</p>
      </div>
    );
  }

  return (
    <div className="mt-8 relative">
      {/* Tab Header */}
      <div className="absolute -top-10 left-0">
        <div className="bg-[#C19A6B] text-white px-8 py-2 rounded-t-xl font-bold text-lg shadow-sm inline-block">
          Patient List
        </div>
      </div>

      {/* Table Container */}
      <div className="bg-[#FBF3F0] border-2 border-[#EADBD4] rounded-xl rounded-tl-none p-1 shadow-sm overflow-hidden min-h-[400px]">
        {children.length === 0 ? (
          <p className="text-sm text-gray-600 mt-6 text-center">
            No children assigned to you yet.
          </p>
        ) : (
          <div className="overflow-x-auto custom-scrollbar h-full">
            {/* Note: The image shows a specific striped/colored table style */}
            <table className="w-full text-sm border-collapse">
              <thead className="bg-[#F0EAE8] text-[#C19A6B] font-bold text-xs uppercase tracking-wider sticky top-0 z-10">
                <tr>
                  <th className="text-left p-4">Child Name</th>
                  <th className="text-left p-4">Age (years)</th>
                  <th className="text-left p-4">Gender</th>
                  <th className="text-left p-4">DS Type</th>
                  <th className="text-left p-4">DS Confirmed by</th>
                  <th className="text-left p-4">Parent Name</th>
                  <th className="p-4"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#EADBD4]">
                {children.map((c, idx) => (
                  <tr
                    key={c._id || c.child_id}
                    className="hover:bg-[#f3e9e5] transition-colors text-[#5A483C] font-medium"
                  >
                    <td className="p-4">{c.childName || "—"}</td>
                    <td className="p-4 text-center md:text-left">
                      {calculateAge(c.dateOfBirth)}
                    </td>
                    <td className="p-4">{c.gender || "—"}</td>
                    <td className="p-4 text-[#C19A6B]">
                      {c.downSyndromeType || "Trisomy 21"}
                    </td>
                    <td className="p-4 text-[#8c7462]">Genetic test</td>
                    <td className="p-4">
                      {c.caregiver?.full_name || c.caregiver?.name || "—"}
                    </td>
                    <td className="p-4 text-right">
                      <button
                        onClick={() =>
                          navigate(`/child_parent_detail/${c._id || c.child_id}`)
                        }
                        className="bg-[#C19A6B] hover:bg-[#a67c52] text-white text-xs px-4 py-2 rounded shadow-sm transition-colors whitespace-nowrap"
                      >
                        More Details
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Custom Styles for Scrollbar (Injected here for simplicity, or move to global css) */}
      <style>{`
        .custom-scrollbar::-webkit-scrollbar {
          width: 8px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: #F0EAE8;
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background: #C19A6B;
          border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background: #a67c52;
        }
      `}</style>
    </div>
  );
};
