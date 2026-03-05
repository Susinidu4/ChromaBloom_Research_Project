// src/services/therapistService.js
import axios from "axios";

// 👇 Change this to match your backend base path
const API_BASE_URL = "http://localhost:5000/chromabloom/therapists";

export const registerTherapistService = async (data) => {
  const res = await axios.post(`${API_BASE_URL}/register`, data, {
    headers: {
      "Content-Type": "application/json",
    },
  });
  return res.data; // { message, therapist, token }
};

export const loginTherapistService = async (data) => {
  const res = await axios.post(`${API_BASE_URL}/login`, data, {
    headers: {
      "Content-Type": "application/json",
    },
  });
  return res.data; // { message, therapist, token }
};

// optional: get all therapists (for admin)
export const getAllTherapistsService = async (token) => {
  const res = await axios.get(API_BASE_URL, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  return res.data;
};

// optional: get therapist by id
export const getTherapistByIdService = async (id, token) => {
  const res = await axios.get(`${API_BASE_URL}/${id}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  return res.data;
};

// Update therapist account status
export const updateTherapistAccountStatus = async (id, status, token) => {
  const res = await axios.patch(`${API_BASE_URL}/${id}/status`, { status }, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  return res.data;
};

// Update therapist profile (can include profile_picture_base64)
export const updateTherapistService = async (id, data, token) => {
  const res = await axios.patch(`${API_BASE_URL}/${id}`, data, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  return res.data;
};
