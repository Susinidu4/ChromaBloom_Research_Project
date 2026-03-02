// routes/Users/caregiverRoutes.js
import express from "express";
import {
  createCaregiver,
  loginCaregiver,
  getAllCaregivers,
  getCaregiverById,
  getCaregiverByEmail,
  updateCaregiver,
  changePassword,
  deleteCaregiver,
} from "../../controllers/Users/caregiverController.js";

import upload from "../../middlewares/uploadImage.js";

const router = express.Router();

// ── Auth ──────────────────────────────────────────────────────
router.post("/register", createCaregiver);   // JSON  { full_name, email, password, ... }
router.post("/login", loginCaregiver);    // JSON  { email, password }

// ── Look-up ───────────────────────────────────────────────────
router.get("/", getAllCaregivers);         // list all
router.get("/by-email/:email", getCaregiverByEmail);     // GET /by-email/user@example.com
router.get("/:id", getCaregiverById);        // GET /p-0001

// ── Mutations ─────────────────────────────────────────────────
// form-data key for image MUST be: profile_pic
router.put("/:id", upload.single("profile_pic"), updateCaregiver);

// Change password — JSON { currentPassword, newPassword }
router.post("/:id/change-password", changePassword);

// ── Delete ────────────────────────────────────────────────────
router.delete("/:id", deleteCaregiver);

export default router;
