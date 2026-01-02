import express from "express";
import upload from "../../middlewares/uploadImage.js"; 
import { predictDrawing, drawingModelHealth } from "../../controllers/Gemified_knowlage_Builder_Controller/predictDrawingController.js";

const router = express.Router();

// health check
router.get("/health", drawingModelHealth);

// IMPORTANT: field name must be "file" (same as FastAPI expects)
router.post("/predict", upload.single("file"), predictDrawing);

export default router;
