import express from "express";
import { createDigitalWellbeingLog } from "../../controllers/Parental_Stress_Monitoring_Controller/digitalWellbeingLogController.js";

const router = express.Router();



router.post("/create", createDigitalWellbeingLog);

export default router;
