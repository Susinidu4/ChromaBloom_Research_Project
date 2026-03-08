// src/services/problemSolvingLessonService.js
import axios from "axios";

// Put your backend base URL in .env (recommended)
// VITE_API_BASE_URL=http://localhost:5000
const API_BASE =  "http://localhost:5000";

// Your router is mounted like:
// app.use("/chromabloom/problem-solving-lessons", router)
const ENDPOINT = `${API_BASE}/chromabloom/problem-solving-lessons`;

// ---------- helpers ----------
const normalizeMiniTutorials = (miniTutorials) => {
  // Allow:
  // - array (recommended)
  // - stringified JSON array
  // - undefined/null
  if (miniTutorials === undefined || miniTutorials === null) return undefined;

  // If already an array -> ok
  if (Array.isArray(miniTutorials)) return miniTutorials;

  // If string -> try parse
  if (typeof miniTutorials === "string") {
    try {
      const parsed = JSON.parse(miniTutorials);
      return parsed;
    } catch {
      // Keep as string (backend will throw a nice error)
      return miniTutorials;
    }
  }

  // otherwise send as-is (backend will validate)
  return miniTutorials;
};

// ---------- API calls ----------
export const ProblemSolvingLessonService = {
  // CREATE
  // payload: { title, description, difficulty_level, miniTutorialsName, miniTutorials: [] }
  create: async (payload) => {
    const body = {
      ...payload,
      miniTutorials: normalizeMiniTutorials(payload?.miniTutorials),
    };

    const res = await axios.post(ENDPOINT, body, {
      headers: { "Content-Type": "application/json" },
    });
    return res.data; // { success, data }
  },

  // GET ALL
  getAll: async () => {
    const res = await axios.get(ENDPOINT);
    return res.data; // { success, data: [] }
  },

  // GET BY ID (LP-0001)
  getById: async (id) => {
    const res = await axios.get(`${ENDPOINT}/${id}`);
    return res.data; // { success, data }
  },

  // UPDATE
  // payload can be partial
  update: async (id, payload) => {
    const body = {
      ...payload,
      miniTutorials: normalizeMiniTutorials(payload?.miniTutorials),
    };

    const res = await axios.put(`${ENDPOINT}/${id}`, body, {
      headers: { "Content-Type": "application/json" },
    });
    return res.data; // { success, data }
  },

  // DELETE
  remove: async (id) => {
    const res = await axios.delete(`${ENDPOINT}/${id}`);
    return res.data; // { success, message }
  },
};

export default ProblemSolvingLessonService;
