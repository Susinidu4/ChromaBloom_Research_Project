import express from "express";
import axios from "axios";

import {
  createProgress,
  getAllProgress,
  getProgressById,
  getProgressByUserId,
  updateProgress,
  deleteProgress,
  predictCognitiveProgress,
} from "../../controllers/Cognitive_Progress_Prediction/cognitiveProgressController.js";

const router = express.Router();
/**
 * ✅ SAVE prediction (MongoDB)
 * POST /chromabloom/cognitiveProgress_2
 */
router.post("/", createProgress);

/**
 * ✅ PREDICT (Node -> Python)
 * POST /chromabloom/cognitiveProgress_2/predict-progress
 */
router.post("/predict-progress", predictCognitiveProgress);

/**
 * ✅ VIEW ALL
 * GET /chromabloom/cognitiveProgress_2
 */
router.get("/", getAllProgress);

/**
 * ✅ VIEW BY userId (childId)
 * GET /chromabloom/cognitiveProgress_2/user/:userId
 */
router.get("/user/:userId", getProgressByUserId);

/**
 * ✅ VIEW BY ID
 * GET /chromabloom/cognitiveProgress_2/:id
 */
router.get("/:id", getProgressById);

/**
 * ✅ UPDATE
 * PUT /chromabloom/cognitiveProgress_2/:id
 */
router.put("/:id", updateProgress);

/**
 * ✅ DELETE
 * DELETE /chromabloom/cognitiveProgress_2/:id
 */
router.delete("/:id", deleteProgress);

export default router;
