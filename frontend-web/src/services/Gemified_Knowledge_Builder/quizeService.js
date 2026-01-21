// src/services/quizeService.js
import axios from "axios";

const API_BASE = "http://localhost:5000";
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
  correct_img_url,   // optional (if sending URL instead of file)
  answers,
  correctImage,      // File (single)
  answerImages,      // File[] (multiple, in order)
}) => {
  const fd = new FormData();

  fd.append("question", question ?? "");
  fd.append("lesson_id", lesson_id ?? "");
  fd.append("name_tag", name_tag ?? "");
  fd.append("difficulty_level", difficulty_level ?? "");

  if (correct_answer !== undefined && correct_answer !== null) {
    fd.append("correct_answer", String(correct_answer));
  }

  // allow sending URL directly if not uploading correctImage
  if (correct_img_url !== undefined && correct_img_url !== null) {
    fd.append("correct_img_url", String(correct_img_url));
  }

  // Controller allows answers JSON string in form-data
  if (answers !== undefined) {
    fd.append("answers", JSON.stringify(normalizeAnswers(answers)));
  }

  // ✅ NEW: correct image field name
  if (correctImage) {
    fd.append("correctImage", correctImage);
  }

  // ✅ NEW: answer images field name
  if (Array.isArray(answerImages)) {
    answerImages.forEach((file) => {
      if (file) fd.append("answerImages", file);
    });
  }

  return fd;
};

export const QuizeService = {
  // CREATE
  // JSON: { question, lesson_id, name_tag, difficulty_level, correct_answer, correct_img_url?, answers: [...] }
  // multipart: add correctImage (File) and/or answerImages (File[])
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
      correct_answer:
        payload?.correct_answer !== undefined && payload?.correct_answer !== null
          ? Number(payload.correct_answer)
          : undefined,
    };

    const res = await axios.post(ENDPOINT, body, {
      headers: { "Content-Type": "application/json" },
    });
    return res.data;
  },

  // ✅ GET ALL (no lesson_id filter anymore)
  getAll: async () => {
    const res = await axios.get(ENDPOINT);
    return res.data; // { data: [] }
  },

  // ✅ GET BY LESSON ID (new helper for /lesson/:lessonId)
  getByLessonId: async (lessonId) => {
    const res = await axios.get(`${ENDPOINT}/lesson/${lessonId}`);
    return res.data; // { data: [] }
  },

  // GET BY ID
  getById: async (id) => {
    const res = await axios.get(`${ENDPOINT}/${id}`);
    return res.data; // { data }
  },

  // UPDATE
  // multipart: can replace correctImage and/or answerImages
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
      correct_answer:
        payload?.correct_answer !== undefined && payload?.correct_answer !== null
          ? Number(payload.correct_answer)
          : undefined,
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
