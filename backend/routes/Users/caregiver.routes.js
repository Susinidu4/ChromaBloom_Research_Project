// routes/caregiver.routes.js
import express from "express";
import {
  createCaregiver,
  loginCaregiver,
  getAllCaregivers,
  getCaregiverById,
  updateCaregiver,
  deleteCaregiver,
} from "../../controllers/Users/caregiver.controller.js";

const router = express.Router();

// Auth routes
router.post("/register", createCaregiver); // POST /api/caregivers/register
router.post("/login", loginCaregiver);     // POST /api/caregivers/login

// CRUD routes
router.get("/", getAllCaregivers);         // GET  /api/caregivers
router.get("/:id", getCaregiverById);      // GET  /api/caregivers/p-0001
router.put("/:id", updateCaregiver);       // PUT  /api/caregivers/p-0001
router.delete("/:id", deleteCaregiver);    // DELETE /api/caregivers/p-0001

export default router;
