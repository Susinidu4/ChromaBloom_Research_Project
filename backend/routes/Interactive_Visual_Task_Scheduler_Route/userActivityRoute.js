import express from 'express';
import { createUserActivity, deleteUserActivity, updateUserActivity, getUserActivitiesByDate, getAllUserActivities, getAllActivities } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/userActivityController.js';
import upload from '../../middlewares/uploadImage.js';

const router = express.Router();

// Create a new user activity
// POST /chromabloom/userActivities/createUserActivity
router.post("/createUserActivity", upload.single("media_image"), createUserActivity);

// Display all activities
// GET /chromabloom/userActivities/allUserActivity
router.get("/allUserActivity", getAllActivities);

// Display all user activities for a caregiver
// GET /chromabloom/userActivities/allUserActivity/:caregiverId
router.get("/allUserActivity/:caregiverId", getAllUserActivities);

// Delete a user activity by ID
// POST /chromabloom/userActivities/getByDate
router.post("/getByDate", getUserActivitiesByDate);

// Delete User Activity by ID
// DELETE /chromabloom/userActivities/deleteUserActivity/:activityId
router.delete("/deleteUserActivity/:activityId", deleteUserActivity);

// Update User Activity by ID
// PUT /chromabloom/userActivities/updateUserActivity/:activityId
router.put("/updateUserActivity/:activityId", updateUserActivity);

export default router;