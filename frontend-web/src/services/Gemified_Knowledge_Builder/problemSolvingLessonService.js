import axios from "axios";

const API_BASE = "http://localhost:5000";
const BASE_URL = `${API_BASE}/chromabloom/problem-solving-lessons`;

const buildLessonFormData = ({
  title,
  content,
  difficultyLevel,
  correct_answer,
  tips,
  images,
  catergory,
}) => {
  const fd = new FormData();
  fd.append("title", title);
  if (content) fd.append("content", content);
  fd.append("difficultyLevel", difficultyLevel);
  fd.append("correct_answer", correct_answer);

  if (tips && Array.isArray(tips)) fd.append("tips", JSON.stringify(tips));
  if (catergory) fd.append("catergory", catergory);

  if (images && images.length) {
    images.forEach((file) => fd.append("images", file));
  }

  return fd;
};

export const problemSolvingLessonService = {
  async getAll() {
    const res = await axios.get(BASE_URL);
    return res.data;
  },
  async getById(id) {
    const res = await axios.get(`${BASE_URL}/${id}`);
    return res.data;
  },
  async create(payload) {
    const fd = buildLessonFormData(payload);
    const res = await axios.post(BASE_URL, fd, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return res.data;
  },
  async update(id, payload) {
    const fd = buildLessonFormData(payload);
    const res = await axios.put(`${BASE_URL}/${id}`, fd, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return res.data;
  },
  async remove(id) {
    const res = await axios.delete(`${BASE_URL}/${id}`);
    return res.data;
  },
};
