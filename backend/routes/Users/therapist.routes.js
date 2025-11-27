// routes/therapist.routes.js
import express from "express";
import multer from "multer";
import {
  registerTherapist,
  loginTherapist,
  getAllTherapists,
  getTherapistById,
  updateTherapist,
  deleteTherapist,
} from "../../controllers/Users/therapist.controller.js";

const router = express.Router();

// multer using memory storage (for Cloudinary upload_stream)
const storage = multer.memoryStorage();
const upload = multer({ storage });

// register with optional profile picture
router.post(
  "/register",
  upload.single("profile_picture"),
  registerTherapist
);

// login
router.post("/login", loginTherapist);

// get all
router.get("/", getAllTherapists);

// get by id (t-0001)
router.get("/:id", getTherapistById);

// update details + optional new profile picture
router.put("/:id", upload.single("profile_picture"), updateTherapist);

// delete
router.delete("/:id", deleteTherapist);

export default router;
