// src/pages/CreateAdmin.jsx
import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { createAdmin } from "../../services/Admin/adminService";

const CreateAdmin = () => {
  const navigate = useNavigate();

  const [full_name, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccessMsg("");

    if (!full_name || !email || !password) {
      setError("full_name, email and password are required.");
      return;
    }

    try {
      setLoading(true);

      const data = await createAdmin({ full_name, email, password });

      setSuccessMsg(data?.message || "Admin created successfully!");

      // go back to login after success
      setTimeout(() => navigate("/admin_login"), 800);
    } catch (err) {
      const msg =
        err?.response?.data?.message ||
        err?.message ||
        "Create admin failed. Please try again.";
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-md bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
        <h1 className="text-2xl font-bold text-gray-800">Create Admin</h1>
        <p className="text-gray-500 mt-1">Add a new admin account.</p>

        {error && (
          <div className="mt-4 bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded">
            {error}
          </div>
        )}

        {successMsg && (
          <div className="mt-4 bg-green-50 border border-green-200 text-green-700 px-3 py-2 rounded">
            {successMsg}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Full name</label>
            <input
              className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 outline-none focus:ring-2 focus:ring-gray-200"
              type="text"
              value={full_name}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="John Doe"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Email</label>
            <input
              className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 outline-none focus:ring-2 focus:ring-gray-200"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@email.com"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Password</label>
            <input
              className="mt-1 w-full border border-gray-300 rounded-lg px-3 py-2 outline-none focus:ring-2 focus:ring-gray-200"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
            />
          </div>

          <button
            disabled={loading}
            className="w-full bg-gray-900 text-white rounded-lg py-2 font-semibold hover:bg-gray-800 disabled:opacity-60"
            type="submit"
          >
            {loading ? "Creating..." : "Create Admin"}
          </button>
        </form>

        <div className="mt-4 text-sm text-gray-600">
          Already have an account?{" "}
          <Link className="text-gray-900 font-semibold underline" to="/admin_login">
            Go to Login
          </Link>
        </div>
      </div>
    </div>
  );
};

export default CreateAdmin;
