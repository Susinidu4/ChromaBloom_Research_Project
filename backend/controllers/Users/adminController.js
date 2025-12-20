import Admin from "../../models/Users/adminModel.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// helper: create token
const generateToken = (admin) => {
  return jwt.sign(
    { id: admin._id, email: admin.email },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};

// ✅ CREATE ADMIN
export const createAdmin = async (req, res) => {
  try {
    const { full_name, email, password } = req.body;

    if (!full_name || !email || !password) {
      return res.status(400).json({
        message: "full_name, email and password are required",
      });
    }

    const existing = await Admin.findOne({ email });
    if (existing) {
      return res.status(400).json({ message: "Admin with this email already exists" });
    }

    const admin = await Admin.create({ full_name, email, password });

    const adminObj = admin.toObject();
    delete adminObj.password;

    return res.status(201).json({
      message: "Admin created successfully",
      admin: adminObj,
    });
  } catch (error) {
    console.error("Error creating admin:", error);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

// ✅ LOGIN ADMIN
export const loginAdmin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "email and password are required" });
    }

    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const token = generateToken(admin);

    const adminObj = admin.toObject();
    delete adminObj.password;

    return res.status(200).json({
      message: "Login successful",
      admin: adminObj,
      token,
    });
  } catch (error) {
    console.error("Error logging in admin:", error);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

// ✅ GET ALL ADMINS
export const getAdmins = async (req, res) => {
  try {
    const admins = await Admin.find().select("-password");
    return res.status(200).json(admins);
  } catch (error) {
    console.error("Error fetching admins:", error);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

// ✅ GET ADMIN BY ID
export const getAdminById = async (req, res) => {
  try {
    const { id } = req.params;

    const admin = await Admin.findById(id).select("-password");
    if (!admin) return res.status(404).json({ message: "Admin not found" });

    return res.status(200).json(admin);
  } catch (error) {
    console.error("Error fetching admin:", error);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

// ✅ UPDATE ADMIN
export const updateAdmin = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, email, password } = req.body;

    const admin = await Admin.findById(id);
    if (!admin) return res.status(404).json({ message: "Admin not found" });

    if (full_name !== undefined) admin.full_name = full_name;
    if (email !== undefined) admin.email = email;

    if (password !== undefined && password !== "") {
      admin.password = password; // will be hashed by pre("save")
    }

    const saved = await admin.save();

    const adminObj = saved.toObject();
    delete adminObj.password;

    return res.status(200).json({
      message: "Admin updated successfully",
      admin: adminObj,
    });
  } catch (error) {
    console.error("Error updating admin:", error);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

// ✅ DELETE ADMIN
export const deleteAdmin = async (req, res) => {
  try {
    const { id } = req.params;

    const admin = await Admin.findByIdAndDelete(id);
    if (!admin) return res.status(404).json({ message: "Admin not found" });

    return res.status(200).json({ message: "Admin deleted successfully" });
  } catch (error) {
    console.error("Error deleting admin:", error);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};
