// controllers/Users/caregiverController.js
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import Caregiver from "../../models/Users/caregiver.model.js";
import cloudinary from "../../config/cloudinary.js";

// Helper to create JWT
const generateToken = (caregiver) => {
  return jwt.sign({ id: caregiver._id, email: caregiver.email }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });
};

// Helper: upload buffer to Cloudinary
const uploadBufferToCloudinary = (fileBuffer, folder = "chromabloom/caregivers") => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder, resource_type: "image" },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );

    stream.end(fileBuffer);
  });
};

// ✅ CREATE / REGISTER (NO profile image upload here)
export const createCaregiver = async (req, res) => {
  try {
    const full_name = req.body.full_name ?? req.body.fullName;
    const email = req.body.email;
    const password = req.body.password;

    const dob = req.body.dob ?? req.body.dateOfBirth;
    const gender = req.body.gender;

    const phone = req.body.phone ?? req.body.phoneNumber;
    const address = req.body.address;

    const child_count = req.body.child_count ?? req.body.numberOfChildren ?? 0;

    const existing = await Caregiver.findOne({ email });
    if (existing) {
      return res.status(400).json({ message: "Email already registered" });
    }

    const caregiver = await Caregiver.create({
      full_name,
      email,
      password,
      dob,
      gender,
      phone,
      address,
      child_count,
      // profile_pic NOT handled here
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

// ✅ LOGIN
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

// ✅ GET ALL
export const getAllCaregivers = async (req, res) => {
  try {
    const caregivers = await Caregiver.find().sort({ createdAt: -1 });
    res.json(caregivers);
  } catch (err) {
    console.error("getAllCaregivers error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// ✅ GET BY ID
export const getCaregiverById = async (req, res) => {
  try {
    const { id } = req.params;
    const caregiver = await Caregiver.findById(id);

    if (!caregiver) {
      return res.status(404).json({ message: "Caregiver not found" });
    }

    res.json(caregiver);
  } catch (err) {
    console.error("getCaregiverById error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// ✅ UPDATE CAREGIVER (supports profile_pic upload)
export const updateCaregiver = async (req, res) => {
  try {
    const { id } = req.params;

    // If password sent, hash it
    if (req.body.password) {
      const salt = await bcrypt.genSalt(10);
      req.body.password = await bcrypt.hash(req.body.password, salt);
    }

    // If image uploaded (multipart/form-data)
    if (req.file) {
      const result = await uploadBufferToCloudinary(req.file.buffer);
      req.body.profile_pic = result.secure_url;
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

// ✅ DELETE
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
