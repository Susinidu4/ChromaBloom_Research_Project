import express from 'express';

import { computeStressAndRecommendation, getStressScoreHistory, getStressScoresByCaregiver } from '../../controllers/Parental_Stress_Monitoring_Controller/stressAnalysisController.js';


const router = express.Router();

router.get("/compute/:caregiverId", computeStressAndRecommendation);
//get stress scores by caregiverId
router.get("/:caregiverId", getStressScoresByCaregiver);


// Get stress score history for a caregiver
// GET /chromabloom/stressAnalysis/history/:caregiverId
router.get("/history/:caregiverId", getStressScoreHistory);

export default router;