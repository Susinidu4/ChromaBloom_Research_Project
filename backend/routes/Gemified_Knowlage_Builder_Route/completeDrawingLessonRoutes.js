// routes/Gemified_Knowlage_Builder_Route/completeDrawingLesson.routes.js
import express from "express";
import {
  createCompleteDrawingLesson,
  getAllCompleteDrawingLessons,
  getCompleteDrawingLessonById,
  getCompleteDrawingLessonsByUserId,
  updateCompleteDrawingLesson,
  deleteCompleteDrawingLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/completeDrawingLessonController.js"; 

const router = express.Router();

// Create completed lesson
router.post("/", createCompleteDrawingLesson);

// Get all completed lessons
router.get("/", getAllCompleteDrawingLessons);

// Get completed lesson by record ID (CLD-000x)
router.get("/:id", getCompleteDrawingLessonById);

// Get all completed lessons for a given user
router.get("/user/:userId", getCompleteDrawingLessonsByUserId);

// Update completed lesson record
router.put("/:id", updateCompleteDrawingLesson);

// Delete completed lesson record
router.delete("/:id", deleteCompleteDrawingLesson);

export default router;
