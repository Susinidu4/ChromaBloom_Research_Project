import express from "express";
import {
  createCompleteDrawingLesson,
  getAllCompleteDrawingLessons,
  getCompleteDrawingLessonById,
  getCompleteDrawingLessonsByUserId,
  updateCompleteDrawingLesson,
  deleteCompleteDrawingLesson,
  getCompleteDrawingLessonsByLessonIdAndUserId,
  hasUserCompletedLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/completeDrawingLessonController.js"; 

const router = express.Router();


//Create completed lesson
router.post("/", createCompleteDrawingLesson);

//Get all completed lessons
router.get("/", getAllCompleteDrawingLessons);

//(MUST be BEFORE "/:id") Get all completed lessons for a given user
router.get("/user/:userId", getCompleteDrawingLessonsByUserId);

//Extra: get completed lessons by lessonId + userId
router.get(
  "/lesson/:lessonId/user/:userId",
  getCompleteDrawingLessonsByLessonIdAndUserId
);

//check completion (returns one record or null)
router.get(
  "/has-completed/lesson/:lessonId/user/:userId",
  hasUserCompletedLesson
);

//Get completed lesson by record ID (Mongo _id)
router.get("/:id", getCompleteDrawingLessonById);

//Update completed lesson record
router.put("/:id", updateCompleteDrawingLesson);

//Delete completed lesson record
router.delete("/:id", deleteCompleteDrawingLesson);

export default router;
