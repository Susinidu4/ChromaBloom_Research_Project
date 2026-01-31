// src/services/childService.js
import axios from "axios";

// ✅ Change base URL to match your backend route
// Example: http://localhost:5000/chromabloom/children
const API_BASE_URL = "http://localhost:5000/chromabloom/children";

// CREATE / REGISTER CHILD
export const createChildService = async (data, token) => {
  const res = await axios.post(`${API_BASE_URL}`, data, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  return res.data; // { message, child }
};

// GET ALL CHILDREN
export const getAllChildrenService = async (token) => {
  const res = await axios.get(`${API_BASE_URL}`, {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  return res.data; // [children]
};

// GET CHILD BY ID (c-0001)
export const getChildByIdService = async (id, token) => {
  const res = await axios.get(`${API_BASE_URL}/${id}`, {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  return res.data; // child
};

// GET CHILDREN BY CAREGIVER ID (p-0001)
export const getChildrenByCaregiverService = async (caregiverId, token) => {
  const res = await axios.get(`${API_BASE_URL}/caregiver/${caregiverId}`, {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  return res.data; // [children]
};

// GET CHILDREN BY THERAPIST ID (t-0001)
export const getChildrenByTherapistService = async (therapistId, token) => {
  const res = await axios.get(`${API_BASE_URL}/therapist/${therapistId}`, {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  return res.data; // [children]
};

// UPDATE CHILD
export const updateChildService = async (id, data, token) => {
  const res = await axios.put(`${API_BASE_URL}/${id}`, data, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  return res.data; // { message, child }
};

// DELETE CHILD
export const deleteChildService = async (id, token) => {
  const res = await axios.delete(`${API_BASE_URL}/${id}`, {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  return res.data; // { message }
};
