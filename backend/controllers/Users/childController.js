// controllers/child.controller.js
import Child from "../../models/Users/child.model.js";


// CREATE / REGISTER CHILD
export const createChild = async (req, res) => {
  try {
    const {
      childName,
      dateOfBirth,
      gender,
      heightCm,
      weightKg,
      downSyndromeType,
      downSyndromeConfirmedBy,
      otherHealthConditions,
      caregiver,
      therapist,
    } = req.body;

    if (!childName || !dateOfBirth || !gender || !caregiver || !therapist) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const child = await Child.create({
      childName,
      dateOfBirth,
      gender,
      heightCm,
      weightKg,
      downSyndromeType,
      downSyndromeConfirmedBy,
      otherHealthConditions,
      caregiver, // "p-0001"
      therapist, // "t-0001"
    });

    res.status(201).json({
      message: "Child registered successfully",
      child,
    });
  } catch (err) {
    console.error("createChild error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// GET ALL CHILDREN
export const getAllChildren = async (req, res) => {
  try {
    const children = await Child.find()
      .sort({ createdAt: -1 })
      .populate("caregiver")
      .populate("therapist");

    res.json(children);
  } catch (err) {
    console.error("getAllChildren error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// GET CHILD BY ID (c-0001)
export const getChildById = async (req, res) => {
  try {
    const { id } = req.params; // e.g. "c-0001"

    const child = await Child.findById(id)
      .populate("caregiver")
      .populate("therapist");

    if (!child) {
      return res.status(404).json({ message: "Child not found" });
    }

    res.json(child);
  } catch (err) {
    console.error("getChildById error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// GET CHILDREN BY CAREGIVER ID (p-0001)
export const getChildrenByCaregiver = async (req, res) => {
  try {
    const { caregiverId } = req.params; // e.g. "p-0001"

    const children = await Child.find({ caregiver: caregiverId })
      .sort({ createdAt: -1 })
      .populate("caregiver")
      .populate("therapist");

    res.json(children);
  } catch (err) {
    console.error("getChildrenByCaregiver error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// UPDATE CHILD
export const updateChild = async (req, res) => {
  try {
    const { id } = req.params;

    const updated = await Child.findByIdAndUpdate(id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!updated) {
      return res.status(404).json({ message: "Child not found" });
    }

    res.json({
      message: "Child updated successfully",
      child: updated,
    });
  } catch (err) {
    console.error("updateChild error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// DELETE CHILD
export const deleteChild = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Child.findByIdAndDelete(id);

    if (!deleted) {
      return res.status(404).json({ message: "Child not found" });
    }

    res.json({ message: "Child deleted successfully" });
  } catch (err) {
    console.error("deleteChild error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};
