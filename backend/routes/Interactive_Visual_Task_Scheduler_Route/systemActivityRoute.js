import express from 'express';
import { createSystemActivity, getAllSystemActivities, getOrCreateStarterPlan, updateSystemActivityProgress, getRoutineRunProgress, closeCycleAndSendToML, closeCycleSendToMLAndCreateNextPlan } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/systemActivityController.js';   
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



//------------------------- cycle management routes -------------------------//

// Close cycle and send features to ML
// POST /chromabloom/systemActivities/closeCycleAndSendToML
router.post("/closeCycleAndSendToML", closeCycleAndSendToML);

// Close cycle, send to ML, and create next plan
// POST /chromabloom/systemActivities/closeCycleAndCreateNextPlan
router.post("/closeCycleAndCreateNextPlan", closeCycleSendToMLAndCreateNextPlan);


export default router;