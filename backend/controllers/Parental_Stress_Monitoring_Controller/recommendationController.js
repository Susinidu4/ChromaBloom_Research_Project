import RecommendationModel from "../../models/Parental_Stress_Monitoring_Model/recommendationModel.js";
import mongoose from "mongoose";

// ------------------------- Admin -------------------------- //

// Create recommendation
export const createRecommendation = async (req, res) => {
  try {
    const {
      title,
      message,
      level,
      category,
      duration,
      steps,
      source,
      is_active = true,
    } = req.body;

    if (
      !title ||
      !message ||
      !level ||
      !category ||
      !duration ||
      !steps
    ) {
      return res.status(400).json({
        error: "Missing required fields",
      });
    }

    // Steps must be a non-empty array
    if (!Array.isArray(steps) || steps.length === 0) {
      return res.status(400).json({
        error: "Steps must be a non-empty array",
      });
    }

    // Validate step structure
    for (const step of steps) {
      if (
        typeof step.step_number !== "number" ||
        typeof step.instruction !== "string"
      ) {
        return res.status(400).json({
          error:
            "Each step must have step_number (number) and instruction (string)",
        });
      }
    }

    // Create recommendation document
    const recommendation = new RecommendationModel({
      title,
      message,
      level,
      category,
      duration,
      steps,
      source,
      is_active,
    });

    // Save recommendation
    await recommendation.save();

    return res.status(201).json({
      message: "Recommendation created successfully",
      recommendation,
    });
  } catch (err) {
    console.error(err);

    // Handle enum validation errors nicely
    if (err.name === "ValidationError") {
      return res.status(400).json({
        error: "Validation error",
        details: err.message,
      });
    }

    return res.status(500).json({
      error: "Server error",
      details: err.message,
    });
  }
};

// Get all recommendations
export const getAllRecommendations = async (req, res) => {
  try {
    const recommendations = await RecommendationModel.find()
      .sort({ created_at: -1 }) // newest first
      .lean();

    return res.status(200).json({
      success: true,
      count: recommendations.length,
      data: recommendations,
    });
  } catch (error) {
    console.error("Get recommendations error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch recommendations",
    });
  }
};

// Get recommendation by ID
export const getRecommendationById = async (req, res) => {
  try {
    const { id } = req.params;

    let recommendation = null;

    // 🔹 If Mongo ObjectId
    if (mongoose.Types.ObjectId.isValid(id)) {
      recommendation = await RecommendationModel.findById(id).lean();
    }

    // 🔹 Otherwise, treat as custom recommendationId (REC-0001)
    if (!recommendation) {
      recommendation = await RecommendationModel.findOne({
        recommendationId: id,
      }).lean();
    }

    if (!recommendation) {
      return res.status(404).json({
        success: false,
        message: "Recommendation not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: recommendation,
    });
  } catch (error) {
    console.error("Get recommendation by ID error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch recommendation",
    });
  }
};

// Update recommendation
export const updateRecommendation = async (req, res) => {
  try {
    const { id } = req.params;

    delete req.body.recommendationId;
    delete req.body._id;

    if (!req.body || Object.keys(req.body).length === 0) {
      return res.status(400).json({
        success: false,
        message: "No update data provided",
      });
    }

    let updated = null;

    if (mongoose.Types.ObjectId.isValid(id)) {
      updated = await RecommendationModel.findByIdAndUpdate(
        id,
        req.body,
        { new: true, runValidators: true }
      ).lean();
    }

    if (!updated) {
      updated = await RecommendationModel.findOneAndUpdate(
        { recommendationId: id },
        req.body,
        { new: true, runValidators: true }
      ).lean();
    }

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: "Recommendation not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Recommendation updated successfully",
      data: updated,
    });
  } catch (error) {
    console.error("Update recommendation error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update recommendation",
    });
  }
};

// delete recommendation
export const deleteRecommendation = async (req, res) => {
  try {
    const { id } = req.params;

    let deleted = null;

    if (mongoose.Types.ObjectId.isValid(id)) {
      deleted = await RecommendationModel.findByIdAndDelete(id).lean();
    }

    if (!deleted) {
      deleted = await RecommendationModel.findOneAndDelete({
        recommendationId: id,
      }).lean();
    }

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: "Recommendation not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Recommendation permanently deleted",
    });
  } catch (error) {
    console.error("Hard delete error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to delete recommendation",
    });
  }
};
