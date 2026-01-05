import express from "express";
import { getConsentByCaregiver, saveConsentDecision } from "../../controllers/Parental_Stress_Monitoring_Controller/consentController.js";

const router = express.Router();

// Retrieve consent decision for a caregiver
// GET /chromabloom/consent/:caregiverId
router.get("/:caregiverId", getConsentByCaregiver);

// Save consent decision for a caregiver
// POST /chromabloom/consent/createConsent
router.post("/createConsent", saveConsentDecision);

export default router;
