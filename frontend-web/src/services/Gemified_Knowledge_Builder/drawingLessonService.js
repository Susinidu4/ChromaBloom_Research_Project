import axios from "axios";

const API_BASE = "http://localhost:5000";
const BASE_URL = `${API_BASE}/chromabloom/drawing-lessons`;

export async function getAllDrawingLessons() {
  const res = await axios.get(BASE_URL);
  return res.data; // { success, data }
}

export async function getDrawingLessonById(id) {
  const res = await axios.get(`${BASE_URL}/${id}`);
  return res.data; // { success, data }
}

/**
 * payload:
 * {
 *  title, description, difficulty_level,
 *  tips: [{tip_number:1, tip:"..."}, ...],
 *  videoFile: File
 * }
 */
export async function createDrawingLesson(payload) {
  const form = new FormData();
  form.append("title", payload.title);
  form.append("description", payload.description);
  form.append("difficulty_level", payload.difficulty_level);

  // tips should be JSON string for multipart/form-data
  if (payload.tips) {
    form.append("tips", JSON.stringify(payload.tips));
  }

  /**
   * ✅ IMPORTANT FIX:
   * backend route uses: uploadVideo.single("file")
   * so FormData key MUST be "file"
   */
  if (payload.videoFile) {
    form.append("file", payload.videoFile);
  }

  const res = await axios.post(BASE_URL, form, {
    headers: { "Content-Type": "multipart/form-data" },
  });

  return res.data; // { success, data }
}

/**
 * payload can include videoFile optionally
 */
export async function updateDrawingLesson(id, payload) {
  const form = new FormData();

  if (payload.title) form.append("title", payload.title);
  if (payload.description) form.append("description", payload.description);
  if (payload.difficulty_level)
    form.append("difficulty_level", payload.difficulty_level);

  if (payload.tips) form.append("tips", JSON.stringify(payload.tips));

  // ✅ MUST match: uploadVideo.single("file")
  if (payload.videoFile) {
    form.append("file", payload.videoFile);
  }

  const res = await axios.put(`${BASE_URL}/${id}`, form, {
    headers: { "Content-Type": "multipart/form-data" },
  });

  return res.data; // { success, data }
}

export async function deleteDrawingLesson(id) {
  const res = await axios.delete(`${BASE_URL}/${id}`);
  return res.data;
}
