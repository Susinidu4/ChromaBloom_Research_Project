// controllers/caregiver.controller.js
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import Caregiver from "../../models/Users/caregiver.model.js";

// Helper to create JWT
const generateToken = (caregiver) => {
  return jwt.sign(
    { id: caregiver._id, email: caregiver.email },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};

// =======================
//   CREATE / REGISTER
// =======================
export const createCaregiver = async (req, res) => {
  try {
    const { full_name, email, password, dob, gender, phone, address } = req.body;

    // Check existing email
    const existing = await Caregiver.findOne({ email });
    if (existing) {
      return res.status(400).json({ message: "Email already registered" });
    }

    const caregiver = await Caregiver.create({
      full_name,
      email,
      password, // will be hashed in pre('save')
      dob,
      gender,
      phone,
      address,
    });

    const token = generateToken(caregiver);

    res.status(201).json({
      message: "Caregiver created successfully",
      caregiver,
      token,
    });
  } catch (err) {
    console.error("createCaregiver error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =======================
//   LOGIN
// =======================
export const loginCaregiver = async (req, res) => {
  try {
    const { email, password } = req.body;

    const caregiver = await Caregiver.findOne({ email });
    if (!caregiver) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, caregiver.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const token = generateToken(caregiver);

    res.json({
      message: "Login successful",
      caregiver,
      token,
    });
  } catch (err) {
    console.error("loginCaregiver error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =======================
//   GET ALL CAREGIVERS
// =======================
export const getAllCaregivers = async (req, res) => {
  try {
    const caregivers = await Caregiver.find().sort({ createdAt: -1 });
    res.json(caregivers);
  } catch (err) {
    console.error("getAllCaregivers error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =======================
//   GET CAREGIVER BY ID
// =======================
export const getCaregiverById = async (req, res) => {
  try {
    const { id } = req.params; // id = p-0001
    const caregiver = await Caregiver.findById(id); // works because _id is a string

    if (!caregiver) {
      return res.status(404).json({ message: "Caregiver not found" });
    }

    res.json(caregiver);
  } catch (err) {
    console.error("getCaregiverById error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =======================
//   UPDATE CAREGIVER
// =======================
export const updateCaregiver = async (req, res) => {
  try {
    const { id } = req.params;

    // If password is sent in body, hash it manually
    if (req.body.password) {
      const salt = await bcrypt.genSalt(10);
      req.body.password = await bcrypt.hash(req.body.password, salt);
    }

    const updated = await Caregiver.findByIdAndUpdate(id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!updated) {
      return res.status(404).json({ message: "Caregiver not found" });
    }

    res.json({
      message: "Caregiver updated successfully",
      caregiver: updated,
    });
  } catch (err) {
    console.error("updateCaregiver error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// =======================
//   DELETE CAREGIVER
// =======================
export const deleteCaregiver = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Caregiver.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ message: "Caregiver not found" });
    }

    res.json({ message: "Caregiver deleted successfully" });
  } catch (err) {
    console.error("deleteCaregiver error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};
