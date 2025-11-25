// routes/admin.routes.js
import express from "express";
import {
  createAdmin,
  getAdmins,
  getAdminById,
  updateAdmin,
  deleteAdmin,
} from "../../controllers/Users/admin.controller.js";

const router = express.Router();

// POST /api/admins          -> create admin
router.post("/", createAdmin);

// GET /api/admins           -> view all admins
router.get("/", getAdmins);

// GET /api/admins/:id       -> view admin by id
router.get("/:id", getAdminById);

// PUT /api/admins/:id       -> update admin
router.put("/:id", updateAdmin);

// DELETE /api/admins/:id    -> delete admin
router.delete("/:id", deleteAdmin);

export default router;
