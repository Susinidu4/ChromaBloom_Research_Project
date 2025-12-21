import { Router } from "express";
import {
  predictCognitiveProgress,
  createProgress,
  deleteProgress,
  getAllProgress,
  getProgressById,
  getProgressByUserId,
  updateProgress,
} from "../../controllers/Cognitive_Progress_Prediction/cognitiveProgressController.js";

const router = Router();

// ✅ PREDICT (calls python) - separate path
router.post("/predict", predictCognitiveProgress);

// ✅ STORE prediction
router.post("/", createProgress);

// VIEW ALL
router.get("/", getAllProgress);

// VIEW BY userId
router.get("/user/:userId", getProgressByUserId);

// VIEW BY id
router.get("/:id", getProgressById);

// UPDATE
router.put("/:id", updateProgress);

// DELETE
router.delete("/:id", deleteProgress);

export default router;
