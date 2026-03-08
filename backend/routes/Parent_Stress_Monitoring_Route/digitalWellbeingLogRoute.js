import express from "express";
import { 
    createDigitalWellbeingLog,
    getDigitalWellbeingLogsByCaregiverId
} from "../../controllers/Parental_Stress_Monitoring_Controller/digitalWellbeingLogController.js";

const router = express.Router();

// Route to create a new digital wellbeing log
// POST /chromabloom/digitalWellbeingLog/create
router.post("/create", createDigitalWellbeingLog);

// Route to get digital wellbeing logs for a caregiver
// GET /chromabloom/digitalWellbeingLog/caregiver/:caregiverId
router.get("/caregiver/:caregiverId", getDigitalWellbeingLogsByCaregiverId); //for cognitive progress prediction

export default router;
