import express from "express";
import {
    createDrawingLevel,
    updateDrawingLevel,
    getDrawingLevelByUserId,
    updateDrawingLevelByUserId,
} from "../../controllers/Gemified_knowlage_Builder_Controller/drawingLevelController.js";

const router = express.Router();

// Route to create a new drawing level
router.post("/create", createDrawingLevel);

// Route to update an existing drawing level by its _id
router.put("/update/:id", updateDrawingLevel);

// Route to get drawing level(s) for a specific user ID
router.get("/user/:userId", getDrawingLevelByUserId);

// Route to update a drawing level by user ID
router.put("/user/update/:userId", updateDrawingLevelByUserId);

export default router;
