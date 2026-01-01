import express from 'express';
import { computeStressAndRecommendation } from '../../controllers/Parental_Stress_Monitoring_Controller/stressAnalysisController.js';

const router = express.Router();

router.get("/compute/:caregiverId", computeStressAndRecommendation);

export default router;