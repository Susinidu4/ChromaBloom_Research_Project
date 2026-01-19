// src/services/quizeService.js
import axios from "axios";

const API_BASE = "http://localhost:5000";

// Your router mount example:
// app.use("/chromabloom/quizes", router)
const ENDPOINT = `${API_BASE}/chromabloom/quizes`;

// -------- helpers --------
const normalizeAnswers = (answers) => {
  // allow array, stringified JSON array, undefined/null
  if (answers === undefined || answers === null) return undefined;

  if (Array.isArray(answers)) return answers;

  if (typeof answers === "string") {
    try {
      return JSON.parse(answers);
    } catch {
      return answers;
    }
  }
  return answers;
};

const buildFormData = ({
  question,
  lesson_id,
  name_tag,
  difficulty_level,
  correct_answer,
  answers,
  images, // File[] in the same order as answers
}) => {
  const fd = new FormData();
  fd.append("question", question ?? "");
  fd.append("lesson_id", lesson_id ?? "");
  fd.append("name_tag", name_tag ?? "");
  fd.append("difficulty_level", difficulty_level ?? "");
  fd.append("correct_answer", String(correct_answer ?? ""));

  // Controller expects answers can be a JSON string in form-data
  if (answers !== undefined) fd.append("answers", JSON.stringify(answers));

  // Field name must be "images" (matches upload.array("images", 10))
  if (Array.isArray(images)) {
    images.forEach((file) => {
      if (file) fd.append("images", file);
    });
  }
  return fd;
};

export const QuizeService = {
  // CREATE
  // data can be:
  // 1) JSON: { question, lesson_id, name_tag, difficulty_level, correct_answer, answers: [{image_no, img_url?}] }
  // 2) multipart: provide images: File[] and answers as array (we stringify it)
  create: async (payload, { useMultipart = false } = {}) => {
    if (useMultipart) {
      const fd = buildFormData(payload);
      const res = await axios.post(ENDPOINT, fd, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      return res.data; // { message, data }
    }

    const body = {
      ...payload,
      answers: normalizeAnswers(payload?.answers),
    };

    const res = await axios.post(ENDPOINT, body, {
      headers: { "Content-Type": "application/json" },
    });
    return res.data;
  },

  // GET ALL (optional filter by lesson_id)
  getAll: async (lesson_id) => {
    const res = await axios.get(ENDPOINT, {
      params: lesson_id ? { lesson_id } : undefined,
    });
    return res.data; // { data: [] }
  },

  // GET BY ID
  getById: async (id) => {
    const res = await axios.get(`${ENDPOINT}/${id}`);
    return res.data; // { data }
  },

  // UPDATE (supports optional multipart to replace images)
  update: async (id, payload, { useMultipart = false } = {}) => {
    if (useMultipart) {
      const fd = buildFormData(payload);
      const res = await axios.put(`${ENDPOINT}/${id}`, fd, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      return res.data; // { message, data }
    }

    const body = {
      ...payload,
      answers: normalizeAnswers(payload?.answers),
    };

    const res = await axios.put(`${ENDPOINT}/${id}`, body, {
      headers: { "Content-Type": "application/json" },
    });
    return res.data;
  },

  // DELETE
  remove: async (id) => {
    const res = await axios.delete(`${ENDPOINT}/${id}`);
    return res.data; // { message, data }
  },
};

export default QuizeService;
