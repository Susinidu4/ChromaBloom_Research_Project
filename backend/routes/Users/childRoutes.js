// routes/child.routes.js
import express from "express";
import {
  createChild,
  getAllChildren,
  getChildById,
  getChildrenByCaregiver,
  updateChild,
  deleteChild,
  getChildrenByTherapist,
  updateChildStatus
} from "../../controllers/Users/childController.js";

const router = express.Router();

// CREATE
router.post("/", createChild);                   // POST  /api/children

// READ
router.get("/", getAllChildren);                 // GET   /api/children
router.get("/caregiver/:caregiverId", getChildrenByCaregiver); // GET /api/children/caregiver/p-0001
router.get("/:id", getChildById);                // GET   /api/children/c-0001

// UPDATE
router.put("/:id", updateChild);                 // PUT   /api/children/c-0001
router.patch("/:id/status", updateChildStatus);  // PATCH /api/children/c-0001/status

// DELETE
router.delete("/:id", deleteChild);              // DELETE /api/children/c-0001

// GET CHILDREN BY THERAPIST ID (t-0001)
router.get("/therapist/:therapistId", getChildrenByTherapist); // GET /api/children/therapist/t-0001
export default router;
