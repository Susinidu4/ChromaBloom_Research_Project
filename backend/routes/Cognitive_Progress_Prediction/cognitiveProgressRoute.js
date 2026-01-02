import express from "express";
import axios from "axios";

const router = express.Router();
const ML_SERVICE_URL = process.env.ML_SERVICE_URL || "http://localhost:8000";

// ✅ Match the model-required feature set (minimum)
const REQUIRED_FIELDS = [
  "gender",
  "diagnosis_type",
  "activity",
  "mood_label",
  "caregiver_mood_label",

  "age",
  "time_duration_for_activity",
  "sentiment_score",
  "stress_score_combined",
  "phone_screen_time_mins",
  "sleep_hours",
  "total_tasks_assigned",
  "total_tasks_completed",
  "completion_rate",
  "engagement_minutes",
  "memory_accuracy",
  "attention_accuracy",
  "problem_solving_accuracy",
  "motor_skills_accuracy",
  "average_response_time",

  "caregiver_sentiment_score",
  "caregiver_stress_score_combined",
  "caregiver_phone_screen_time_mins",
  "caregiver_sleep_hours",
];

function validateRequiredFeatures(features) {
  const missing = [];
  for (const k of REQUIRED_FIELDS) {
    if (features[k] === undefined || features[k] === null || features[k] === "") {
      missing.push(k);
    }
  }
  return missing;
}

router.post("/predict-progress", async (req, res) => {
  try {
    const { features } = req.body;

    if (!features || typeof features !== "object") {
      return res.status(400).json({ message: "features object is required" });
    }

    // ✅ Validate required fields
    const missing = validateRequiredFeatures(features);
    if (missing.length > 0) {
      return res.status(400).json({
        message: "Missing required feature fields",
        missing,
      });
    }

    // Call Python ML service
    const mlRes = await axios.post(`${ML_SERVICE_URL}/predict`, {
      features,
      top_k: 10,
    });

    return res.json({
      message: "Prediction generated",
      result: mlRes.data,
    });
  } catch (err) {
    console.error("predict-progress error:", err?.response?.data || err.message);

    return res.status(500).json({
      message: "Prediction service failed",
      error: err?.response?.data || err.message,
    });
  }
});

export default router;
