// controllers/therapist.controller.js
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import Therapist from "../../models/Users/terapist.model.js";
import cloudinary from "../../config/cloudinary.js";

// helper: create token
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

// helper: upload buffer to cloudinary
const uploadToCloudinary = (fileBuffer, folder) => {
  return new Promise((resolve, reject) => {
    cloudinary.uploader
      .upload_stream({ folder }, (error, result) => {
        if (error) return reject(error);
        resolve(result.secure_url);
      })
      .end(fileBuffer);
  });
};

// =========================
// REGISTER THERAPIST
// =========================
export const registerTherapist = async (req, res) => {
  try {
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
    } = req.body;

    const existing = await Therapist.findOne({ email });
    if (existing) {
      return res.status(400).json({ message: "Email already registered" });
    }

    // profile picture upload (optional)
    let profileUrl = "";
    if (req.file) {
      profileUrl = await uploadToCloudinary(
        req.file.buffer,
        "chromabloom/therapists"
      );
    }

    const therapist = await Therapist.create({
      full_name,
      dob,
      gender,
      email,
      password, // hashed by pre('save')
      phone,
      address,
      specialization,
      start_date,
      licence_number,
      work_place,
      profile_picture: profileUrl,
      terms_and_conditions: terms_and_conditions ?? false,
      privacy_policy: privacy_policy ?? false,
    });

    const token = generateToken(therapist);

    res.status(201).json({
      message: "Therapist registered successfully",
      therapist,
      token,
    });
  } catch (err) {
    console.error("registerTherapist error:", err);
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
// UPDATE THERAPIST
// (also supports new profile picture)
// =========================
export const updateTherapist = async (req, res) => {
  try {
    const { id } = req.params;

    // if password comes in, hash it here
    if (req.body.password) {
      const salt = await bcrypt.genSalt(10);
      req.body.password = await bcrypt.hash(req.body.password, salt);
    }

    // new profile picture
    if (req.file) {
      const profileUrl = await uploadToCloudinary(
        req.file.buffer,
        "chromabloom/therapists"
      );
      req.body.profile_picture = profileUrl;
    }

    const updated = await Therapist.findByIdAndUpdate(id, req.body, {
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
