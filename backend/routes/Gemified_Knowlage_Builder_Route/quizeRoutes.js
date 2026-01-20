// routes/quize.routes.js
import express from "express";
import upload from "../../middlewares/uploadImage.js"; // your multer memory upload
import {
  createQuize,
  getAllQuizes,
  getQuizeById,
  updateQuize,
  deleteQuize,
  getQuizeByLessonId,
} from "../../controllers/Gemified_knowlage_Builder_Controller/quizeController.js";

const router = express.Router();

// Create quiz
// - JSON: no files
// - multipart: use field name "images" (multiple)
router.post("/", upload.array("images", 10), createQuize);

// Get all (optional ?lesson_id=...)
router.get("/", getAllQuizes);

// Get one
router.get("/:id", getQuizeById);

// Update (optional new images)
router.put("/:id", upload.array("images", 10), updateQuize);

// Delete
router.delete("/:id", deleteQuize);

// Get quize by lesson ID
router.get("/lesson/:lessonId", getQuizeByLessonId);
export default router;
