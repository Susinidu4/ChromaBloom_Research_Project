import React, { useEffect, useState } from "react";
import { getChildrenByTherapistService } from "../../services/childService";

export const TherapistChildrenList = () => {
  const [children, setChildren] = useState([]);
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState("");

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

        // ✅ Therapist ID might be _id or therapist_id depending on your backend
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

  if (loading) {
    return (
      <div className="mt-6 bg-white p-4 rounded-lg shadow">
        <p className="text-sm text-gray-600">Loading children...</p>
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
    <div className="mt-6 bg-white p-6 rounded-lg shadow">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-bold text-gray-800">
          Assigned Children ({children.length})
        </h2>
      </div>

      {children.length === 0 ? (
        <p className="text-sm text-gray-600 mt-3">
          No children assigned to you yet.
        </p>
      ) : (
        <div className="overflow-x-auto mt-4">
          <table className="w-full text-sm border">
            <thead className="bg-gray-100">
              <tr>
                <th className="text-left p-3 border">Child ID</th>
                <th className="text-left p-3 border">Name</th>
                <th className="text-left p-3 border">Gender</th>
                <th className="text-left p-3 border">DOB</th>
                <th className="text-left p-3 border">Caregiver</th>
                <th className="text-left p-3 border">Down Syndrome Type</th>
              </tr>
            </thead>
            <tbody>
              {children.map((c) => (
                <tr key={c._id || c.child_id} className="hover:bg-gray-50">
                  <td className="p-3 border">{c._id || c.child_id || "—"}</td>
                  <td className="p-3 border">{c.childName || "—"}</td>
                  <td className="p-3 border">{c.gender || "—"}</td>
                  <td className="p-3 border">
                    {c.dateOfBirth
                      ? new Date(c.dateOfBirth).toLocaleDateString()
                      : "—"}
                  </td>
                  <td className="p-3 border">
                    {/* because you used populate("caregiver") */}
                    {c.caregiver?.fullName ||
                      c.caregiver?.name ||
                      c.caregiver?._id ||
                      "—"}
                  </td>
                  <td className="p-3 border">{c.downSyndromeType || "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};
