import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { registerTherapistService } from "../../services/therapistService";

// helper: file → base64 string
const fileToBase64 = (file) =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file); // this creates "data:image/...;base64,xxxx"
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);
  });

export const Therapists_register = () => {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    full_name: "",
    dob: "",
    gender: "",
    email: "",
    password: "",
    phone: "",
    address: "",
    specialization: "",
    start_date: "",
    licence_number: "",
    work_place: "",
    terms_and_conditions: false,
    privacy_policy: false,
  });

  const [profileBase64, setProfileBase64] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  const [successMsg, setSuccessMsg] = useState("");

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;

    setForm((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleProfilePictureChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const base64 = await fileToBase64(file);
      setProfileBase64(base64);
    } catch (error) {
      console.error("Base64 conversion error:", error);
      setErrorMsg("Failed to process profile picture");
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg("");
    setSuccessMsg("");
    setLoading(true);

    try {
      const payload = {
        ...form,
        profile_picture_base64: profileBase64 || undefined,
      };

      const data = await registerTherapistService(payload);
      // { message, therapist, token }

      // save token + therapist if you want auto-login
      localStorage.setItem("therapist_token", data.token);
      localStorage.setItem("therapist_info", JSON.stringify(data.therapist));

      setSuccessMsg("Registration successful!");
      // redirect to login or dashboard
      navigate("/therapists_login");
    } catch (error) {
      console.error("Therapist register error:", error);
      setErrorMsg(
        error.response?.data?.message ||
          "Registration failed. Please check your details."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50 px-4">
      <div className="w-full max-w-2xl bg-white shadow-lg rounded-lg p-8">
        <h1 className="text-2xl font-bold text-gray-800 mb-6 text-center">
          Therapist Registration
        </h1>

        {errorMsg && (
          <div className="mb-4 text-sm text-red-600 bg-red-50 px-3 py-2 rounded">
            {errorMsg}
          </div>
        )}

        {successMsg && (
          <div className="mb-4 text-sm text-green-600 bg-green-50 px-3 py-2 rounded">
            {successMsg}
          </div>
        )}

        <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Full Name */}
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Full Name *
            </label>
            <input
              type="text"
              name="full_name"
              required
              value={form.full_name}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Dr. Jane Doe"
            />
          </div>

          {/* DOB */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Date of Birth
            </label>
            <input
              type="date"
              name="dob"
              value={form.dob}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          {/* Gender */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Gender
            </label>
            <select
              name="gender"
              value={form.gender}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Select</option>
              <option value="female">Female</option>
              <option value="male">Male</option>
              <option value="other">Other</option>
            </select>
          </div>

          {/* Email */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Email *
            </label>
            <input
              type="email"
              name="email"
              required
              value={form.email}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="therapist@example.com"
            />
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Password *
            </label>
            <input
              type="password"
              name="password"
              required
              value={form.password}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="••••••••"
            />
          </div>

          {/* Phone */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Phone
            </label>
            <input
              type="text"
              name="phone"
              value={form.phone}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="+94..."
            />
          </div>

          {/* Address */}
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Address
            </label>
            <input
              type="text"
              name="address"
              value={form.address}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Clinic or home address"
            />
          </div>

          {/* Specialization */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Specialization
            </label>
            <input
              type="text"
              name="specialization"
              value={form.specialization}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="e.g. Speech Therapist"
            />
          </div>

          {/* Start Date */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Start Date
            </label>
            <input
              type="date"
              name="start_date"
              value={form.start_date}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          {/* Licence Number */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Licence Number
            </label>
            <input
              type="text"
              name="licence_number"
              value={form.licence_number}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Registration/licence ID"
            />
          </div>

          {/* Work Place */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Workplace
            </label>
            <input
              type="text"
              name="work_place"
              value={form.work_place}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Hospital / Center / Private practice"
            />
          </div>

          {/* Profile Picture */}
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Profile Picture (optional)
            </label>
            <input
              type="file"
              accept="image/*"
              onChange={handleProfilePictureChange}
              className="w-full text-sm"
            />
            {profileBase64 && (
              <p className="mt-1 text-xs text-green-600">
                Image ready to upload ✔
              </p>
            )}
          </div>

          {/* Terms & Privacy */}
          <div className="md:col-span-2 space-y-2 mt-2">
            <label className="flex items-center text-sm text-gray-700 gap-2">
              <input
                type="checkbox"
                name="terms_and_conditions"
                checked={form.terms_and_conditions}
                onChange={handleChange}
                className="h-4 w-4"
              />
              <span>
                I agree to the{" "}
                <span className="text-blue-600 underline cursor-pointer">
                  Terms & Conditions
                </span>
              </span>
            </label>

            <label className="flex items-center text-sm text-gray-700 gap-2">
              <input
                type="checkbox"
                name="privacy_policy"
                checked={form.privacy_policy}
                onChange={handleChange}
                className="h-4 w-4"
              />
              <span>
                I have read and accept the{" "}
                <span className="text-blue-600 underline cursor-pointer">
                  Privacy Policy
                </span>
              </span>
            </label>
          </div>

          {/* Submit button */}
          <div className="md:col-span-2 mt-2">
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-green-600 text-white font-medium py-2 rounded-md hover:bg-green-700 transition disabled:opacity-60 disabled:cursor-not-allowed"
            >
              {loading ? "Registering..." : "Register"}
            </button>
          </div>
        </form>

        <p className="mt-4 text-center text-sm text-gray-600">
          Already have an account?{" "}
          <Link
            to="/therapists_login"
            className="text-blue-600 hover:underline font-medium"
          >
            Login here
          </Link>
        </p>
      </div>
    </div>
  );
};
