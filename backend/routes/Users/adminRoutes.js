import express from "express";
import {
  createAdmin,
  loginAdmin,
  getAdmins,
  getAdminById,
  updateAdmin,
  deleteAdmin,
} from "../../controllers/Users/adminController.js";

import { protectAdmin } from "../../middlewares/authAdmin.js";

const router = express.Router();

// PUBLIC
router.post("/", createAdmin);
router.post("/login", loginAdmin);

// PROTECTED (optional) - require token
router.get("/", protectAdmin, getAdmins);
router.get("/:id", protectAdmin, getAdminById);
router.put("/:id", protectAdmin, updateAdmin);
router.delete("/:id", protectAdmin, deleteAdmin);

export default router;
