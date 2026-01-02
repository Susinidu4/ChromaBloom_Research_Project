import express from "express";
import { createRecommendation } from "../../controllers/Parental_Stress_Monitoring_Controller/recommendationController.js";

const router = express.Router();

router.post("/createRecommendation", createRecommendation);

export default router;
