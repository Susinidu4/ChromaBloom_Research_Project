import express from "express";
import { 
    createDigitalWellbeingLog,
    getDigitalWellbeingLogsByCaregiverId
} from "../../controllers/Parental_Stress_Monitoring_Controller/digitalWellbeingLogController.js";

const router = express.Router();



router.post("/create", createDigitalWellbeingLog);
router.get("/caregiver/:caregiverId", getDigitalWellbeingLogsByCaregiverId); //for cognitive progress prediction

export default router;
