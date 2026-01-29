import axios from "axios";

const API_BASE = "http://localhost:5000/chromabloom/systemActivities";


// CREATE (with image upload)
export const createSystemActivityService = async (payload) => {
  // payload: {
  // title, description, age_group, development_area,
  // steps: [{step_number, instruction}], estimated_duration_minutes,
  // difficulty_level, imageFile
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

  // must be field name: "image" (because upload.single("image"))
  if (payload.imageFile) {
    fd.append("image", payload.imageFile);
  }

  const res = await axios.post(`${API_BASE}/createSystemActivity`, fd, {
    headers: { "Content-Type": "multipart/form-data" },
  });

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



