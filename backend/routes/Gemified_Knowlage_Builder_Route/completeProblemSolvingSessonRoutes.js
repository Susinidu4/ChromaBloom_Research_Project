import express from "express";
import {
  createCompleteProblemSolvingSession,
  deleteCompleteProblemSolvingSession,
  getAllCompleteProblemSolvingSessions,
  getCompleteProblemSolvingSessionsByUserId,
} from "../../controllers/Gemified_knowlage_Builder_Controller/completeProblemSolvingLessonController.js";

const router = express.Router();

// CREATE
router.post("/", createCompleteProblemSolvingSession);

// VIEW ALL
router.get("/", getAllCompleteProblemSolvingSessions);

// VIEW BY USER ID
router.get("/user/:user_id", getCompleteProblemSolvingSessionsByUserId);

// DELETE BY ID (CLP-0001)
router.delete("/:id", deleteCompleteProblemSolvingSession);

export default router;
