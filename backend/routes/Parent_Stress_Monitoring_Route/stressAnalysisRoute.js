import express from 'express';
import { computeStressAndRecommendation, getStressScoreHistory } from '../../controllers/Parental_Stress_Monitoring_Controller/stressAnalysisController.js';

const router = express.Router();

router.get("/compute/:caregiverId", computeStressAndRecommendation);

// Get stress score history for a caregiver
// GET /chromabloom/stressAnalysis/history/:caregiverId
router.get("/history/:caregiverId", getStressScoreHistory);

export default router;