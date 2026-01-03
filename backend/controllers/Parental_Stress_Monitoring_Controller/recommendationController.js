import RecommendationModel from "../../models/Parental_Stress_Monitoring_Model/recommendationModel.js";

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

    // ----------------------------
    // Basic validation
    // ----------------------------
    if (!title || !message || !level || !category || !duration || !steps || !source) {
      return res.status(400).json({
        error: "Missing required fields",
      });
    }

    if (!Array.isArray(steps) || steps.length === 0) {
      return res.status(400).json({
        error: "Steps must be a non-empty array",
      });
    }

    for (const step of steps) {
      if (
        typeof step.step_number !== "number" ||
        typeof step.instruction !== "string"
      ) {
        return res.status(400).json({
          error: "Each step must have step_number (number) and instruction (string)",
        });
      }
    }

    // ----------------------------
    // Create recommendation
    // ----------------------------
    const recommendation = new RecommendationModel({
      title,
      message,
      level,        // must be: Low | Medium | High | Critical
      category,     // must match enum
      duration,
      steps,
      source,
      is_active,
    });

    await recommendation.save(); // ✅ triggers pre("save") auto-ID

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
