import express from "express";
import { createRecommendation, getAllRecommendations, getRecommendationById, updateRecommendation, deleteRecommendation } from "../../controllers/Parental_Stress_Monitoring_Controller/recommendationController.js";

const router = express.Router();

// Route to create a new recommendation
// POST /chromabloom/recommendation/createRecommendation
router.post("/createRecommendation", createRecommendation);

// Route to get all recommendations
// GET /chromabloom/recommendation/getAllRecommendations
router.get("/getAllRecommendations", getAllRecommendations);

// Route to get a recommendation by ID
// GET /chromabloom/recommendation/getRecommendationById/:id
router.get("/getRecommendationById/:id", getRecommendationById);

// Route to update a recommendation
// PATCH /chromabloom/recommendation/updateRecommendation/:id
router.patch("/updateRecommendation/:id", updateRecommendation);

// Route to delete a recommendation
// DELETE /chromabloom/recommendation/deleteRecommendation/:id
router.delete("/deleteRecommendation/:id", deleteRecommendation);

export default router;
