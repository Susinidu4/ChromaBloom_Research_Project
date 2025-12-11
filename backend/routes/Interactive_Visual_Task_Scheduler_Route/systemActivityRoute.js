import express from 'express';
import { createSystemActivity, getAllSystemActivities } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/systemActivityController.js';   
import upload from "../../middlewares/uploadImage.js";

const router = express.Router();

// Create a new system activity
// POST /chromabloom/systemActivities/createSystemActivity
router.post("/createSystemActivity", upload.single("image"), createSystemActivity);

// Display all system activities
// GET /chromabloom/systemActivities/getAllSystemActivities
router.get("/getAllSystemActivities", getAllSystemActivities);

export default router;