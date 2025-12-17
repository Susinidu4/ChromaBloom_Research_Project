// controllers/Users/therapist.controller.js
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import Therapist from "../../models/Users/terapistModel.js";
import cloudinary from "../../config/cloudinary.js";

// =========================
//  HELPERS
// =========================

// helper: create JWT
const generateToken = (therapist) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET is not defined");
  }

  return jwt.sign(
    { id: therapist._id, email: therapist.email },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};

// helper: safely cast "true"/"false" or boolean to real boolean
const toBool = (val) => {
  if (val === true || val === false) return val;
  if (typeof val === "string") {
    return val.toLowerCase() === "true";
  }
  return false;
};

// =========================
// REGISTER THERAPIST (JSON + base64 image)
// =========================
export const registerTherapist = async (req, res) => {
  try {
    console.log(
      "👉 [registerTherapist] req.headers['content-type'] =",
      req.headers["content-type"]
    );
    console.log(
      "👉 [registerTherapist] req.body keys =",
      Object.keys(req.body || {})
    );

    const {
      full_name,
      dob,
      gender,
      email,
      password,
      phone,
      address,
      specialization,
      start_date,
      licence_number,
      work_place,
      terms_and_conditions,
      privacy_policy,
      profile_picture_base64, // <-- sent from Flutter
    } = req.body;

    // ✅ Manual validation
    if (!full_name || !email || !password) {
      return res.status(400).json({
        message:
          "full_name, email, and password are required (check what your Flutter is sending).",
      });
    }

    // Check duplicate email
    const existing = await Therapist.findOne({ email });
    if (existing) {
      return res.status(400).json({ message: "Email already registered" });
    }

    // ✅ Optional base64 profile picture upload to Cloudinary
    let profileUrl = "";
    if (profile_picture_base64) {
      // profile_picture_base64 should be like "data:image/jpeg;base64,...."
      const uploadResult = await cloudinary.uploader.upload(
        profile_picture_base64,
        {
          folder: "chromabloom/therapists",
        }
      );
      profileUrl = uploadResult.secure_url;
    }

    // Mongoose create (password will be hashed by pre('save') in model)
    const therapist = await Therapist.create({
      full_name,
      dob,
      gender,
      email,
      password,
      phone,
      address,
      specialization,
      start_date,
      licence_number,
      work_place,
      profile_picture: profileUrl,
      terms_and_conditions: toBool(terms_and_conditions),
      privacy_policy: toBool(privacy_policy),
    });

    const token = generateToken(therapist);

    res.status(201).json({
      message: "Therapist registered successfully",
      therapist,
      token,
    });
  } catch (err) {
    console.error("registerTherapist error (catch):", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =========================
// LOGIN THERAPIST
// =========================
export const loginTherapist = async (req, res) => {
  try {
    const { email, password } = req.body;

    const therapist = await Therapist.findOne({ email });
    if (!therapist) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, therapist.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const token = generateToken(therapist);

    res.json({
      message: "Login successful",
      therapist,
      token,
    });
  } catch (err) {
    console.error("loginTherapist error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =========================
// GET ALL THERAPISTS
// =========================
export const getAllTherapists = async (req, res) => {
  try {
    const therapists = await Therapist.find().sort({ createdAt: -1 });
    res.json(therapists);
  } catch (err) {
    console.error("getAllTherapists error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =========================
// GET THERAPIST BY ID (t-0001)
// =========================
export const getTherapistById = async (req, res) => {
  try {
    const { id } = req.params;

    const therapist = await Therapist.findById(id);
    if (!therapist) {
      return res.status(404).json({ message: "Therapist not found" });
    }

    res.json(therapist);
  } catch (err) {
    console.error("getTherapistById error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =========================
// UPDATE THERAPIST (JSON + optional base64 image)
// =========================
export const updateTherapist = async (req, res) => {
  try {
    const { id } = req.params;

    // clone so we can safely modify
    const updateData = { ...req.body };

    // If password is being updated, hash it
    if (updateData.password) {
      const salt = await bcrypt.genSalt(10);
      updateData.password = await bcrypt.hash(updateData.password, salt);
    }

    // Normalize booleans
    if (updateData.terms_and_conditions !== undefined) {
      updateData.terms_and_conditions = toBool(updateData.terms_and_conditions);
    }
    if (updateData.privacy_policy !== undefined) {
      updateData.privacy_policy = toBool(updateData.privacy_policy);
    }

    // Optional new profile picture as base64
    if (updateData.profile_picture_base64) {
      const uploadResult = await cloudinary.uploader.upload(
        updateData.profile_picture_base64,
        {
          folder: "chromabloom/therapists",
        }
      );
      updateData.profile_picture = uploadResult.secure_url;
      delete updateData.profile_picture_base64; // don't save base64 in DB
    }

    const updated = await Therapist.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    });

    if (!updated) {
      return res.status(404).json({ message: "Therapist not found" });
    }

    res.json({
      message: "Therapist updated successfully",
      therapist: updated,
    });
  } catch (err) {
    console.error("updateTherapist error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =========================
// DELETE THERAPIST
// =========================
export const deleteTherapist = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Therapist.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ message: "Therapist not found" });
    }

    res.json({ message: "Therapist deleted successfully" });
  } catch (err) {
    console.error("deleteTherapist error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};
