// routes/Gamified_Knowlage_Builder_Route/completeDrawingLesson.routes.js
import express from "express";
import {
  createCompleteDrawingLesson,
  getAllCompleteDrawingLessons,
  getCompleteDrawingLessonById,
  getCompleteDrawingLessonsByUserId,
  updateCompleteDrawingLesson,
  deleteCompleteDrawingLesson,
  // ✅ optional extra endpoints you wrote
  getCompleteDrawingLessonsByLessonIdAndUserId,
  hasUserCompletedLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/completeDrawingLessonController.js"; 
// ✅ IMPORTANT: make sure this path matches your real file location/name

const router = express.Router();

/**
 * Base path example (in your main app):
 * app.use("/chromabloom/completed-drawing-lessons", router);
 */

// ✅ Create completed lesson
router.post("/", createCompleteDrawingLesson);

// ✅ Get all completed lessons
router.get("/", getAllCompleteDrawingLessons);

// ✅ (MUST be BEFORE "/:id") Get all completed lessons for a given user
router.get("/user/:userId", getCompleteDrawingLessonsByUserId);

// ✅ Extra: get completed lessons by lessonId + userId
router.get(
  "/lesson/:lessonId/user/:userId",
  getCompleteDrawingLessonsByLessonIdAndUserId
);

// ✅ Extra: check completion (returns one record or null)
router.get(
  "/has-completed/lesson/:lessonId/user/:userId",
  hasUserCompletedLesson
);

// ✅ Get completed lesson by record ID (Mongo _id)
router.get("/:id", getCompleteDrawingLessonById);

// ✅ Update completed lesson record
router.put("/:id", updateCompleteDrawingLesson);

// ✅ Delete completed lesson record
router.delete("/:id", deleteCompleteDrawingLesson);

export default router;
