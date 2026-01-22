import express from "express";
import { createRecommendation } from "../../controllers/Parental_Stress_Monitoring_Controller/recommendationController.js";

const router = express.Router();

// Route to create a new recommendation
// POST /chromabloom/recommendation/createRecommendation
router.post("/createRecommendation", createRecommendation);

export default router;
