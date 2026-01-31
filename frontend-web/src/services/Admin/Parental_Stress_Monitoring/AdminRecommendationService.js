import axios from "axios";

const API_BASE = "http://localhost:5000/chromabloom/recommendations";

// -----------------------------
// CREATE new recommendation
// -----------------------------
export const createRecommendationService = async (payload) => {
  const res = await axios.post(`${API_BASE}/createRecommendation`, payload, {
    headers: {
      "Content-Type": "application/json",
    },
  });

  return res;
};

// -----------------------------
// GET all recommendations
// -----------------------------
export const getAllRecommendationsService = async () => {
  const res = await axios.get(`${API_BASE}/getAllRecommendations`);
  return res; // { success, count, data }
};

// -----------------------------
// GET recommendation by ID
// -----------------------------
export const getRecommendationByIdService = async (id) => {
  const res = await axios.get(`${API_BASE}/getRecommendationById/${id}`);
  return res;
};

// -----------------------------
// UPDATE recommendation
// -----------------------------
export const updateRecommendationService = async (id, payload) => {
  const res = await axios.put(`${API_BASE}/updateRecommendation/${id}`, payload, {
    headers: {
      "Content-Type": "application/json",
    },
  });
  return res;
};

// -----------------------------
// DELETE recommendation
// -----------------------------
export const deleteRecommendationByIdService = async (id) => {
  const res = await axios.delete(`${API_BASE}/deleteRecommendation/${id}`);
  return res;
};