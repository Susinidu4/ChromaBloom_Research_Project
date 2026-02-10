// src/services/admin.service.js
import axios from "axios";

const API_BASE = "http://localhost:5000";
const ADMIN_BASE = `${API_BASE}/chromabloom/admins`;

const api = axios.create({
  baseURL: API_BASE,
  headers: { "Content-Type": "application/json" },
});

// LOGIN (you need a backend route for this: POST /chromabloom/admins/login)
export const adminLogin = async ({ email, password }) => {
  const res = await api.post(`${ADMIN_BASE}/login`, { email, password });
  return res.data; // expected: { token, admin } (recommended)
};

// CREATE ADMIN (POST /chromabloom/admins)
export const createAdmin = async ({ full_name, email, password }) => {
  const res = await api.post(`${ADMIN_BASE}`, { full_name, email, password });
  return res.data;
};

// optional helper
export const getAdmins = async () => {
  const res = await api.get(`${ADMIN_BASE}`);
  return res.data;
};

// GET ADMIN BY ID (GET /chromabloom/admins/:id)
export const getAdminById = async (id) => {
  const res = await api.get(`${ADMIN_BASE}/${id}`);
  return res.data;
};

// UPDATE ACCOUNT STATUS (PATCH /chromabloom/admins/:id/status)
export const updateAccountStatus = async (id, status) => {
  const res = await api.patch(`${ADMIN_BASE}/${id}/status`, { status });
  return res.data;
};

// UPLOAD PROFILE PICTURE (PATCH /chromabloom/admins/:id/profile-picture)
export const uploadAdminProfilePicture = async (id, file) => {
  const formData = new FormData();
  formData.append("profile_picture", file);

  const res = await api.patch(`${ADMIN_BASE}/${id}/profile-picture`, formData, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
  return res.data;
};
