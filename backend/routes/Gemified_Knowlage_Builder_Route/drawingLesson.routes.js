// routes/Interactive_Visual_Task_Scheduler_Route/drawingLesson.routes.js
import express from "express";
import multer from "multer";

import {
  createDrawingLesson,
  getAllDrawingLessons,
  getDrawingLessonById,
  updateDrawingLesson,
  deleteDrawingLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/drawingLesson.controller.js"; // adjust path as needed

const router = express.Router();

// Multer in-memory storage for video uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 200 * 1024 * 1024, // 200MB, adjust as needed
  },
});

// Create lesson (with video upload)
// Body: multipart/form-data
// Fields: title, description, difficulty_level, tips (JSON string), video (file)
router.post("/", upload.single("video"), createDrawingLesson);

// Get all lessons
router.get("/", getAllDrawingLessons);

// Get lesson by ID
router.get("/:id", getDrawingLessonById);

// Update lesson (optional video upload)
router.put("/:id", upload.single("video"), updateDrawingLesson);

// Delete lesson
router.delete("/:id", deleteDrawingLesson);

export default router;
