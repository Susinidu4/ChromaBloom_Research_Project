import express from 'express';
import { createSystemActivity, getAllSystemActivities, getOrCreateStarterPlan, updateSystemActivityProgress, getRoutineRunProgress, closeCycleAndSendToML } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/systemActivityController.js';   
import upload from "../../middlewares/uploadImage.js";

const router = express.Router();

// Create a new system activity
// POST /chromabloom/systemActivities/createSystemActivity
router.post("/createSystemActivity", upload.single("image"), createSystemActivity);

// Display all system activities
// GET /chromabloom/systemActivities/getAllSystemActivities
router.get("/getAllSystemActivities", getAllSystemActivities);



//------------------------- special routes -------------------------//

// Get starter easy activities for a specific age group
// POST /chromabloom/systemActivities/getStarterEasyActivities
router.post("/getOrCreateStarterSystemActivity", getOrCreateStarterPlan);

// Update system activity progress for a routine run
// POST /chromabloom/systemActivities/updateSystemActivityProgress
router.post("/updateSystemActivityProgress", updateSystemActivityProgress);

// Get routine run progress by planId and activityId
// GET /chromabloom/systemActivities/getRoutineRunProgress/:planId/:activityId
router.get("/getRoutineRunProgress/:planId/:activityId", getRoutineRunProgress);



router.post("/closeCycleAndSendToML", closeCycleAndSendToML);




export default router;