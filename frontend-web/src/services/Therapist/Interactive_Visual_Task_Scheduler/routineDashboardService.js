import axios from "axios";

const baseURL = "http://localhost:5000/chromabloom/systemActivities";

const http = axios.create({ baseURL });

// Optional: token auth
http.interceptors.request.use((config) => {
  const token = localStorage.getItem("token"); // adjust if your key is different
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

/**
 * GET /dashboard/:caregiverId?childId=&planId=
 */
export async function getRoutineDashboardService({ caregiverId, childId, planId } = {}) {
  if (!caregiverId) throw new Error("caregiverId is required");

  const params = {};
  if (childId) params.childId = childId;
  if (planId) params.planId = planId;

  const { data } = await http.get(`/dashboard/${caregiverId}`, { params });
  return data; // { success, data, message }
}