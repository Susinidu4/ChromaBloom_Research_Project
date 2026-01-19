// routes/Gemified_Knowlage_Builder_Route/problemSolvingLesson.routes.js
import express from "express";

import {
  createProblemSolvingLesson,
  getAllProblemSolvingLessons,
  getProblemSolvingLessonById,
  updateProblemSolvingLesson,
  deleteProblemSolvingLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/problemSolvingLessonController.js";

const router = express.Router();

// Create lesson
router.post("/", createProblemSolvingLesson);

// Get all lessons
router.get("/", getAllProblemSolvingLessons);

// Get lesson by ID (LP-0001)
router.get("/:id", getProblemSolvingLessonById);

// Update lesson
router.put("/:id", updateProblemSolvingLesson);

// Delete lesson
router.delete("/:id", deleteProblemSolvingLesson);

export default router;
