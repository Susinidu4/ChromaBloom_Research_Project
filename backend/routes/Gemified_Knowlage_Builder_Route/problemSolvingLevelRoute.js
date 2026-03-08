import express from "express";
import {
    createProblemSolvingLevel,
    getProblemSolvingLevelByUserId,
    getAllProblemSolvingLevels,
    updateProblemSolvingLevel,
    updateProblemSolvingLevelByUserId
} from "../../controllers/Gemified_knowlage_Builder_Controller/problemSolvingLevelController.js";

const router = express.Router();

// Create a new Problem Solving Level
router.post("/", createProblemSolvingLevel);

// Get all Problem Solving Levels
router.get("/", getAllProblemSolvingLevels);

// Get Problem Solving Level by User ID
router.get("/user/:userId", getProblemSolvingLevelByUserId);

// Update Problem Solving Level by Entry ID
router.put("/:id", updateProblemSolvingLevel);

// Update Problem Solving Level by User ID
router.put("/user/:userId", updateProblemSolvingLevelByUserId);

export default router;
