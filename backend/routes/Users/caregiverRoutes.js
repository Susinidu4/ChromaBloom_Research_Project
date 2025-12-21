// routes/Users/caregiverRoutes.js
import express from "express";
import {
  createCaregiver,
  loginCaregiver,
  getAllCaregivers,
  getCaregiverById,
  updateCaregiver,
  deleteCaregiver,
} from "../../controllers/Users/caregiverController.js";

import upload from "../../middlewares/uploadImage.js";

const router = express.Router();

// Auth
router.post("/register", createCaregiver); // JSON only
router.post("/login", loginCaregiver);

// CRUD
router.get("/", getAllCaregivers);
router.get("/:id", getCaregiverById);

// ✅ Only update supports image upload
// form-data key must be: profile_pic
router.put("/:id", upload.single("profile_pic"), updateCaregiver);

router.delete("/:id", deleteCaregiver);

export default router;
