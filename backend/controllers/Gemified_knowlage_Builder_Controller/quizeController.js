// controllers/quize.controller.js
import Quize from "../../models/Gamified_Knowlage_Builder_Model/Quize.js"; // adjust path
import cloudinary from "../../config/cloudinary.js";

// Upload a single buffer to Cloudinary
const uploadImageToCloudinary = (fileBuffer, folder = "chromabloom/quizes") => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { resource_type: "image", folder },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );
    stream.end(fileBuffer);
  });
};

// ------------------------------
// CREATE QUIZ
// supports:
// - JSON only
// - OR multipart/form-data with "images" (multiple)
// images will map to answers[i].img_url in order
// ------------------------------
export const createQuize = async (req, res) => {
  try {
    const {
      question,
      lesson_id,
      name_tag,
      difficulty_level,
      correct_answer,
      // answers can come as JSON string when using form-data
      answers,
    } = req.body;

    if (!question || !lesson_id || !difficulty_level) {
      return res.status(400).json({ message: "question, lesson_id, difficulty_level are required" });
    }

    // Parse answers safely
    let parsedAnswers = [];
    if (typeof answers === "string") {
      try {
        parsedAnswers = JSON.parse(answers);
      } catch {
        return res.status(400).json({ message: "answers must be valid JSON" });
      }
    } else if (Array.isArray(answers)) {
      parsedAnswers = answers;
    }

    // Upload files if present (field: images)
    const files = req.files || [];
    if (files.length > 0) {
      // Ensure answers array size matches or initialize
      if (!Array.isArray(parsedAnswers)) parsedAnswers = [];
      // If answers array is shorter, expand it
      while (parsedAnswers.length < files.length) {
        parsedAnswers.push({});
      }

      // Upload in order and assign
      for (let i = 0; i < files.length; i++) {
        const uploadRes = await uploadImageToCloudinary(files[i].buffer);
        parsedAnswers[i] = {
          image_no: parsedAnswers[i]?.image_no ?? i + 1,
          img_url: uploadRes.secure_url,
        };
      }
    }

    const created = await Quize.create({
      question,
      lesson_id,
      name_tag,
      difficulty_level,
      correct_answer: Number(correct_answer),
      answers: parsedAnswers,
    });

    return res.status(201).json({ message: "Quiz created", data: created });
  } catch (err) {
    console.error("createQuize error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};

// ------------------------------
// GET ALL (optional filter by lesson_id)
// GET /quizes?lesson_id=PSL-0001
// ------------------------------
export const getAllQuizes = async (req, res) => {
  try {
    const { lesson_id } = req.query;

    const filter = {};
    if (lesson_id) filter.lesson_id = lesson_id;

    const list = await Quize.find(filter).sort({ _id: 1 });
    return res.status(200).json({ data: list });
  } catch (err) {
    console.error("getAllQuizes error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};

// ------------------------------
// GET ONE BY ID
// ------------------------------
export const getQuizeById = async (req, res) => {
  try {
    const { id } = req.params;

    const quiz = await Quize.findById(id);
    if (!quiz) return res.status(404).json({ message: "Quiz not found" });

    return res.status(200).json({ data: quiz });
  } catch (err) {
    console.error("getQuizeById error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};

// ------------------------------
// UPDATE QUIZ (partial update)
// supports optional new images upload (field: images)
// if images exist, it REPLACES answers in order
// ------------------------------
export const updateQuize = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      question,
      lesson_id,
      name_tag,
      difficulty_level,
      correct_answer,
      answers,
    } = req.body;

    const quiz = await Quize.findById(id);
    if (!quiz) return res.status(404).json({ message: "Quiz not found" });

    if (question !== undefined) quiz.question = question;
    if (lesson_id !== undefined) quiz.lesson_id = lesson_id;
    if (name_tag !== undefined) quiz.name_tag = name_tag;
    if (difficulty_level !== undefined) quiz.difficulty_level = difficulty_level;
    if (correct_answer !== undefined) quiz.correct_answer = Number(correct_answer);

    // Update answers from body (JSON or array)
    if (answers !== undefined) {
      let parsedAnswers = answers;
      if (typeof answers === "string") {
        try {
          parsedAnswers = JSON.parse(answers);
        } catch {
          return res.status(400).json({ message: "answers must be valid JSON" });
        }
      }
      if (Array.isArray(parsedAnswers)) quiz.answers = parsedAnswers;
    }

    // If new images uploaded: replace answers URLs in order
    const files = req.files || [];
    if (files.length > 0) {
      const newAnswers = [];
      for (let i = 0; i < files.length; i++) {
        const uploadRes = await uploadImageToCloudinary(files[i].buffer);
        newAnswers.push({
          image_no: i + 1,
          img_url: uploadRes.secure_url,
        });
      }
      quiz.answers = newAnswers;
    }

    const saved = await quiz.save();
    return res.status(200).json({ message: "Quiz updated", data: saved });
  } catch (err) {
    console.error("updateQuize error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};

// ------------------------------
// DELETE QUIZ
// ------------------------------
export const deleteQuize = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Quize.findByIdAndDelete(id);
    if (!deleted) return res.status(404).json({ message: "Quiz not found" });

    return res.status(200).json({ message: "Quiz deleted", data: deleted });
  } catch (err) {
    console.error("deleteQuize error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};
