import Admin from "../../models/Users/admin.model.js";
import bcrypt from "bcryptjs";
import { generateToken } from "../../utils/generateToken.js";
import cloudinary from "../../config/cloudinary.js";
import { Readable } from "stream";

// Create new admin
export const createAdmin = async (req, res) => {
  try {
    const { full_name, email, password, phone } = req.body;

    if (!full_name || !email || !password || !phone) {
      return res.status(400).json({ message: "full_name, email, password and phone are required" });
    }

    const existingEmail = await Admin.findOne({ email });
    if (existingEmail) {
      return res.status(400).json({ message: "Admin with this email already exists" });
    }

    const existingPhone = await Admin.findOne({ phone });
    if (existingPhone) {
      return res.status(400).json({ message: "Admin with this phone number already exists" });
    }

    const admin = await Admin.create({ full_name, email, password, phone });

    const adminObj = admin.toObject();
    delete adminObj.password;

    res.status(201).json({ message: "Admin created successfully", admin: adminObj });
  } catch (error) {
    console.error("Error creating admin:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Admin login
export const adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    const admin = await Admin.findOne({ email });
    if (!admin) return res.status(404).json({ message: "Admin not found" });

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) return res.status(401).json({ message: "Invalid email or password" });

    if (admin.account_status === "inactive") {
      return res.status(403).json({ message: "Your account is inactive. Please contact the super admin." });
    }

    const token = generateToken(admin);

    const adminObj = admin.toObject();
    delete adminObj.password;

    res.json({ message: "Login successful", admin: adminObj, token });
  } catch (error) {
    console.error("Error logging in admin:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Get all admins
export const getAdmins = async (req, res) => {
  try {
    const admins = await Admin.find().select("-password");
    res.status(200).json(admins);
  } catch (error) {
    console.error("Error fetching admins:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Get admin by ID
export const getAdminById = async (req, res) => {
  try {
    const { id } = req.params;

    const admin = await Admin.findById(id).select("-password");
    if (!admin) {
      return res.status(404).json({ message: "Admin not found" });
    }

    res.status(200).json(admin);
  } catch (error) {
    console.error("Error fetching admin:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Update admin
export const updateAdmin = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, email, password, phone } = req.body;

    const admin = await Admin.findById(id);
    if (!admin) {
      return res.status(404).json({ message: "Admin not found" });
    }

    if (full_name !== undefined) admin.full_name = full_name;
    if (email !== undefined) admin.email = email;
    if (phone !== undefined) admin.phone = phone;
    if (password !== undefined && password !== "") {
      // This will trigger pre('save') and re-hash the password
      admin.password = password;
    }

    const saved = await admin.save();

    const adminObj = saved.toObject();
    delete adminObj.password;

    res.status(200).json({
      message: "Admin updated successfully",
      admin: adminObj,
    });
  } catch (error) {
    console.error("Error updating admin:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Delete admin
export const deleteAdmin = async (req, res) => {
  try {
    const { id } = req.params;

    const admin = await Admin.findByIdAndDelete(id);
    if (!admin) {
      return res.status(404).json({ message: "Admin not found" });
    }

    res.status(200).json({ message: "Admin deleted successfully" });
  } catch (error) {
    console.error("Error deleting admin:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Update Only Account Status
export const updateAccountStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // Validate status match enum
    if (!["active", "inactive"].includes(status)) {
      return res.status(400).json({ message: "Invalid status value" });
    }

    const admin = await Admin.findByIdAndUpdate(
      id,
      { account_status: status },
      { new: true }
    ).select("-password");

    if (!admin) {
      return res.status(404).json({ message: "Admin not found" });
    }

    res.status(200).json({
      message: "Account status updated",
      admin
    });
  } catch (error) {
    console.error("Error updating account status:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Upload Profile Picture
export const uploadProfilePicture = async (req, res) => {
  try {
    const { id } = req.params;

    if (!req.file) {
      return res.status(400).json({ message: "No image file provided" });
    }

    // Upload to Cloudinary using a stream
    const uploadStream = (buffer) => {
      return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: "chromabloom/admins" },
          (error, result) => {
            if (result) resolve(result);
            else reject(error);
          }
        );
        const readable = new Readable();
        readable.push(buffer);
        readable.push(null);
        readable.pipe(stream);
      });
    };

    const result = await uploadStream(req.file.buffer);

    const admin = await Admin.findByIdAndUpdate(
      id,
      { profile_picture: result.secure_url },
      { new: true }
    ).select("-password");

    if (!admin) {
      return res.status(404).json({ message: "Admin not found" });
    }

    res.status(200).json({
      message: "Profile picture uploaded successfully",
      admin,
    });

  } catch (error) {
    console.error("Error uploading profile picture:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};
