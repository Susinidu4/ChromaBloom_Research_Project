import express from "express";
import {
  createCompleteProblemSolvingSession,
  updateCompleteProblemSolvingSession,
  deleteCompleteProblemSolvingSession,
  getCompleteProblemSolvingSessionById,
  getByChildAndLesson,
  getCompleteProblemSolvingSessionByUserId,
} from "../../controllers/Gemified_knowlage_Builder_Controller/completeProblemSolvingLessonController.js";

const router = express.Router();

// Create
router.post("/", createCompleteProblemSolvingSession);

// Get by child + lesson
router.get("/by-child-lesson/:childId/:lessonId", getByChildAndLesson);

// Get by id
router.get("/:id", getCompleteProblemSolvingSessionById);

// Get by user ID
router.get("/user/:userId", getCompleteProblemSolvingSessionByUserId);

// Update
router.put("/:id", updateCompleteProblemSolvingSession);

// Delete
router.delete("/:id", deleteCompleteProblemSolvingSession);

export default router;
