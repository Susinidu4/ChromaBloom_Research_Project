// routes/quize.routes.js
import express from "express";
import upload from "../../middlewares/uploadImage.js";
import {
  createQuize,
  getAllQuizes,
  getQuizeById,
  updateQuize,
  deleteQuize,
  getQuizeByLessonId,
} from "../../controllers/Gemified_knowlage_Builder_Controller/quizeController.js";

const router = express.Router();

/**
 * multer fields:
 * - correctImage: single file
 * - answerImages: multiple files (answers)
 */
const quizUpload = upload.fields([
  { name: "correctImage", maxCount: 1 },
  { name: "answerImages", maxCount: 10 },
]);

// Create quiz (JSON or multipart)
router.post("/", quizUpload, createQuize);

// Get all quizzes (no lesson filter)
router.get("/", getAllQuizes);

// ✅ IMPORTANT: keep this BEFORE "/:id"
router.get("/lesson/:lessonId", getQuizeByLessonId);

// Get one
router.get("/:id", getQuizeById);

// Update quiz
router.put("/:id", quizUpload, updateQuize);

// Delete quiz
router.delete("/:id", deleteQuize);

export default router;
