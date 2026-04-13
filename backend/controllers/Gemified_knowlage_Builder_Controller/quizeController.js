
import Quize from "../../models/Gamified_Knowlage_Builder_Model/Quize.js";
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


// CREATE QUIZ
export const createQuize = async (req, res) => {
  try {
    const {
      question,
      lesson_id,
      name_tag,
      difficulty_level,
      correct_answer,
      correct_img_url, // optional if sending URL directly
      answers, // optional JSON string/array (image_no only, etc.)
    } = req.body;

    if (!question || !lesson_id || !difficulty_level) {
      return res.status(400).json({
        message: "question, lesson_id, difficulty_level are required",
      });
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

    // Files from multer.fields()
    const filesMap = req.files || {};
    const correctFile = filesMap.correctImage?.[0];
    const answerFiles = filesMap.answerImages || [];

    // Upload correct image if provided
    let finalCorrectImgUrl = correct_img_url;
    if (correctFile) {
      const up = await uploadImageToCloudinary(correctFile.buffer);
      finalCorrectImgUrl = up.secure_url;
    }

    // Upload answer images if provided
    if (answerFiles.length > 0) {
      if (!Array.isArray(parsedAnswers)) parsedAnswers = [];

      // Expand answers to match files length
      while (parsedAnswers.length < answerFiles.length) parsedAnswers.push({});

      for (let i = 0; i < answerFiles.length; i++) {
        const up = await uploadImageToCloudinary(answerFiles[i].buffer);
        parsedAnswers[i] = {
          image_no: parsedAnswers[i]?.image_no ?? i + 1,
          img_url: up.secure_url,
        };
      }
    }

    const created = await Quize.create({
      question,
      lesson_id,
      name_tag,
      difficulty_level,
      correct_answer:
        correct_answer !== undefined ? Number(correct_answer) : undefined,
      correct_img_url: finalCorrectImgUrl,
      answers: parsedAnswers,
    });

    return res.status(201).json({ message: "Quiz created", data: created });
  } catch (err) {
    console.error("createQuize error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};


// GET ALL QUIZZES (NO FILTER)

export const getAllQuizes = async (req, res) => {
  try {
    const list = await Quize.find().sort({ _id: 1 });
    return res.status(200).json({ data: list });
  } catch (err) {
    console.error("getAllQuizes error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};


// GET ONE BY ID
// GET /quizes/:id

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


// GET QUIZ BY LESSON ID
// GET /quizes/lesson/:lessonId

export const getQuizeByLessonId = async (req, res) => {
  try {
    const { lessonId } = req.params;

    const list = await Quize.find({ lesson_id: lessonId }).sort({ _id: 1 });
    return res.status(200).json({ data: list });
  } catch (err) {
    console.error("getQuizeByLessonId error:", err);
    return res.status(500).json({ message: "Server error", error: err.message });
  }
};



// UPDATE QUIZ (partial update)

export const updateQuize = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      question,
      lesson_id,
      name_tag,
      difficulty_level,
      correct_answer,
      correct_img_url, // allow direct URL update
      answers,
    } = req.body;

    const quiz = await Quize.findById(id);
    if (!quiz) return res.status(404).json({ message: "Quiz not found" });

    if (question !== undefined) quiz.question = question;
    if (lesson_id !== undefined) quiz.lesson_id = lesson_id;
    if (name_tag !== undefined) quiz.name_tag = name_tag;
    if (difficulty_level !== undefined) quiz.difficulty_level = difficulty_level;
    if (correct_answer !== undefined)
      quiz.correct_answer = Number(correct_answer);
    if (correct_img_url !== undefined) quiz.correct_img_url = correct_img_url;

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

    // Files from multer.fields()
    const filesMap = req.files || {};
    const correctFile = filesMap.correctImage?.[0];
    const answerFiles = filesMap.answerImages || [];

    // Replace correct image if uploaded
    if (correctFile) {
      const up = await uploadImageToCloudinary(correctFile.buffer);
      quiz.correct_img_url = up.secure_url;
    }

    // Replace answers if new images uploaded
    if (answerFiles.length > 0) {
      const newAnswers = [];
      for (let i = 0; i < answerFiles.length; i++) {
        const up = await uploadImageToCloudinary(answerFiles[i].buffer);
        newAnswers.push({
          image_no: i + 1,
          img_url: up.secure_url,
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


// DELETE QUIZ
// DELETE /quizes/:id

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
