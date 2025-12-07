// routes/Gemified_Knowlage_Builder_Route/completeProblemSolvingLesson.routes.js
import express from "express";
import {
  createCompleteProblemSolvingLesson,
  getAllCompleteProblemSolvingLessons,
  getCompleteProblemSolvingLessonById,
  getCompleteProblemSolvingLessonsByUserId,
  updateCompleteProblemSolvingLesson,
  deleteCompleteProblemSolvingLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/completeProblemSolvingLesson.controller.js"; // adjust path

const router = express.Router();

// Create completed lesson
router.post("/", createCompleteProblemSolvingLesson);

// Get all completed lessons
router.get("/", getAllCompleteProblemSolvingLessons);

// Get all completed lessons for a given user
router.get("/user/:userId", getCompleteProblemSolvingLessonsByUserId);

// Get completed lesson by record ID (CLP-000x)
router.get("/:id", getCompleteProblemSolvingLessonById);

// Update completed lesson record
router.put("/:id", updateCompleteProblemSolvingLesson);

// Delete completed lesson record
router.delete("/:id", deleteCompleteProblemSolvingLesson);

export default router;
