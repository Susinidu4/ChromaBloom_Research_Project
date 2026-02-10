// routes/therapist.routes.js
import express from "express";
import {
  registerTherapist,
  loginTherapist,
  getAllTherapists,
  getTherapistById,
  updateTherapist,
  deleteTherapist,
  updateAccountStatus,
} from "../../controllers/Users/therapistController.js";

const router = express.Router();

// 🔹 Register (pure JSON + optional base64 image)
router.post("/register", registerTherapist);

// 🔹 Login (JSON)
router.post("/login", loginTherapist);

// 🔹 Get all therapists
router.get("/", getAllTherapists);

// 🔹 Get by ID (e.g., t-0001)
router.get("/:id", getTherapistById);

// 🔹 Update therapist (JSON + optional base64 image)
router.put("/:id", updateTherapist);

// 🔹 Update Account Status
router.patch("/:id/status", updateAccountStatus);

// 🔹 Delete therapist
router.delete("/:id", deleteTherapist);

export default router;
