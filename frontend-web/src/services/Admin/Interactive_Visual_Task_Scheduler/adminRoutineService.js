import axios from "axios";

const API_BASE = "http://localhost:5000/chromabloom/systemActivities";


// CREATE (with video upload)
export const createSystemActivityService = async (payload) => {
  // payload: {
  // title, description, age_group, development_area,
  // steps: [{step_number, instruction}], estimated_duration_minutes,
  // difficulty_level, videoFile
  // }

  const fd = new FormData();
  fd.append("title", payload.title);
  fd.append("description", payload.description);
  fd.append("age_group", payload.age_group);
  fd.append("development_area", payload.development_area);
  fd.append("estimated_duration_minutes", String(payload.estimated_duration_minutes));
  fd.append("difficulty_level", payload.difficulty_level);

  // important: send steps as JSON string (backend supports it)
  fd.append("steps", JSON.stringify(payload.steps));

  // must be field name: "video" (because upload.single("video"))
  if (payload.videoFile) {
    fd.append("video", payload.videoFile);
  }

  const res = await axios.post(`${API_BASE}/createSystemActivity`, fd);

  return res.data; // { message, data }
};

// GET ALL SYSTEM ACTIVITIES
export const getAllSystemActivitiesService = async () => {
  const res = await axios.get(`${API_BASE}/getAllSystemActivities`);
  // backend returns { message, count, data }
  return res.data;
};

// GET SYSTEM ACTIVITY BY ID
export const getSystemActivityByIdService = async (id) => {
  const res = await axios.get(`${API_BASE}/getSystemActivityById/${id}`);
  return res.data; // { message, data: {} }
};

// Update (PATCH based on your backend route)
export const updateSystemActivityService = async (id, payload) => {
  const fd = new FormData();

  fd.append("title", payload.title);
  fd.append("description", payload.description);
  fd.append("age_group", payload.age_group);
  fd.append("development_area", payload.development_area);
  fd.append("difficulty_level", payload.difficulty_level);
  fd.append("estimated_duration_minutes", String(payload.estimated_duration_minutes));

  // steps as JSON string
  fd.append("steps", JSON.stringify(payload.steps));

  // video field name must match upload.single("video")
  if (payload.videoFile) fd.append("video", payload.videoFile);

  const res = await axios.patch(`${API_BASE}/updateSystemActivity/${id}`, fd);
  return res.data;
};

// DELETE SYSTEM ACTIVITY BY ID
export const deleteSystemActivityByIdService = async (id) => {
  const res = await axios.delete(`${API_BASE}/deleteSystemActivity/${id}`);
  return res.data;
};




