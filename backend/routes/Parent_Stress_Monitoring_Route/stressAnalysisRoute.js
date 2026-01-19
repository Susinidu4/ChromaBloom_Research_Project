import express from 'express';
import { 
    computeStressAndRecommendation,
    getStressScoresByCaregiver
} from '../../controllers/Parental_Stress_Monitoring_Controller/stressAnalysisController.js';

const router = express.Router();

router.get("/compute/:caregiverId", computeStressAndRecommendation);
//get stress scores by caregiverId
router.get("/:caregiverId", getStressScoresByCaregiver);


export default router;