// routes/child.routes.js
import express from "express";
import {
  createChild,
  getAllChildren,
  getChildById,
  getChildrenByCaregiver,
  updateChild,
  deleteChild,
} from "../../controllers/Users/child.controller.js";

const router = express.Router();

// CREATE
router.post("/", createChild);                   // POST  /api/children

// READ
router.get("/", getAllChildren);                 // GET   /api/children
router.get("/caregiver/:caregiverId", getChildrenByCaregiver); // GET /api/children/caregiver/p-0001
router.get("/:id", getChildById);                // GET   /api/children/c-0001

// UPDATE
router.put("/:id", updateChild);                 // PUT   /api/children/c-0001

// DELETE
router.delete("/:id", deleteChild);              // DELETE /api/children/c-0001

export default router;
