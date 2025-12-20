// src/pages/AdminLogin.jsx
import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { adminLogin } from "../../services/Admin/adminService";

const AdminLogin = () => {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (!email || !password) {
      setError("Email and password are required.");
      return;
    }

    try {
      setLoading(true);

      const data = await adminLogin({ email, password });

      // recommended: store token if backend returns it
      if (data?.token) localStorage.setItem("admin_token", data.token);
      if (data?.admin) localStorage.setItem("admin_profile", JSON.stringify(data.admin));

      // ✅ redirect after success
      navigate("/admin_dashboard");
    } catch (err) {
      const msg =
        err?.response?.data?.message ||
        err?.message ||
        "Login failed. Please try again.";
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-md bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
        <h1 className="text-2xl font-bold text-gray-800">Admin Login</h1>
        <p className="text-gray-500 mt-1">Sign in to access the admin dashboard.</p>

        {error && (
          <div className="mt-4 bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
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
            {loading ? "Signing in..." : "Login"}
          </button>
        </form>

        <div className="mt-4 text-sm text-gray-600">
          Don&apos;t have an admin?{" "}
          <Link className="text-gray-900 font-semibold underline" to="/create_admin">
            Create Admin
          </Link>
        </div>
      </div>
    </div>
  );
};

export default AdminLogin;
