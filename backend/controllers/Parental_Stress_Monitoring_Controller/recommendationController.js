import RecommendationModel from "../../models/Parental_Stress_Monitoring_Model/recommendationModel.js";

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
      !steps ||
      !source
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
