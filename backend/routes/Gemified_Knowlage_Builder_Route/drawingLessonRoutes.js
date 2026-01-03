import express from "express";
import uploadVideo from "../.././middlewares/uploadVideo.js";
import {
  createDrawingLesson,
  getAllDrawingLessons,
  getDrawingLessonById,
  updateDrawingLesson,
  deleteDrawingLesson,
} from "../../controllers/Gemified_knowlage_Builder_Controller/drawingLessonController.js";

const router = express.Router();

// field name MUST be "file"
router.post("/", uploadVideo.single("file"), createDrawingLesson);
router.get("/", getAllDrawingLessons);
router.get("/:id", getDrawingLessonById);
router.put("/:id", uploadVideo.single("file"), updateDrawingLesson);
router.delete("/:id", deleteDrawingLesson);

export default router;
