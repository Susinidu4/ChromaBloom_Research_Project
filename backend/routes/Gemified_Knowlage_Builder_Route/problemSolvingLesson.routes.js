// routes/Gemified_Knowlage_Builder_Route/problemSolvingLesson.routes.js
import express from "express";
import multer from "multer";

import {
  createProblemSolvingLesson,
  getAllProblemSolvingLessons,
  getProblemSolvingLessonById,
  updateProblemSolvingLesson,
  deleteProblemSolvingLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/problemSolvingLesson.controller.js"; // adjust path if needed

const router = express.Router();

// Multer in-memory storage for image uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 20 * 1024 * 1024, // 20MB per image (adjust as needed)
  },
});

// Create lesson (with optional multiple images)
// Body: multipart/form-data
// Fields: title, content, difficultyLevel, correct_answer, tips (JSON string)
// Files: images (one or more image files)
router.post("/", upload.array("images", 5), createProblemSolvingLesson);

// Get all lessons
router.get("/", getAllProblemSolvingLessons);

// Get lesson by ID
router.get("/:id", getProblemSolvingLessonById);

// Update lesson (optionally replace images)
router.put("/:id", upload.array("images", 5), updateProblemSolvingLesson);

// Delete lesson
router.delete("/:id", deleteProblemSolvingLesson);

export default router;
