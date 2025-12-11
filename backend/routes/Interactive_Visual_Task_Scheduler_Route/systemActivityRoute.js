import express from 'express';
import { createSystemActivity } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/systemActivityController.js';   
import upload from "../../middlewares/uploadImage.js";

const router = express.Router();

// Create a new system activity
// POST /chromabloom/systemActivities/createSystemActivity
router.post("/createSystemActivity", upload.single("image"), createSystemActivity);

export default router;