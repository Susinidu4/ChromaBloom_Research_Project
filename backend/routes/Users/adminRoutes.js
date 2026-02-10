// routes/admin.routes.js
import express from "express";
import {
  adminLogin,
  createAdmin,
  getAdmins,
  getAdminById,
  updateAdmin,
  deleteAdmin,
  updateAccountStatus,
  uploadProfilePicture,
} from "../../controllers/Users/adminController.js";
import upload from "../../middlewares/uploadImage.js";

const router = express.Router();

// POST /api/admins          -> create admin
router.post("/", createAdmin);

// POST /api/admins/login   -> login admin
router.post("/login", adminLogin);

// GET /api/admins           -> view all admins
router.get("/", getAdmins);

// GET /api/admins/:id       -> view admin by id
router.get("/:id", getAdminById);

// PUT /api/admins/:id       -> update admin
router.put("/:id", updateAdmin);

// DELETE /api/admins/:id    -> delete admin
router.delete("/:id", deleteAdmin);

// PATCH /api/admins/:id/status -> update account status
router.patch("/:id/status", updateAccountStatus);

// PATCH /api/admins/:id/profile-picture -> upload profile picture
router.patch("/:id/profile-picture", upload.single("profile_picture"), uploadProfilePicture);

export default router;
