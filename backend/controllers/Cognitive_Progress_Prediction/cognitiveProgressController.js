import axios from "axios";
import CognitiveProgress from "../../models/Cognitive_Progress_Prediction/Cognitive_progress_Model.js";

const PYTHON_SERVICE_URL =
  process.env.PYTHON_SERVICE_URL || "http://localhost:8000";

const requiredFields = [
  "child_id",
  "age",
  "height_cm",
  "weight_kg",
  "gender",
  "diagnosis_type",
  "mood_label",
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
];

// ================================
// PREDICT (calls Python service)
// POST /chromabloom/cognitiveProgress/predict
// ================================
export const predictCognitiveProgress = async (req, res) => {
  try {
    const input = req.body;

    for (const field of requiredFields) {
      if (!(field in input)) {
        return res
          .status(400)
          .json({ success: false, error: `Missing field: ${field}` });
      }
    }

    const response = await axios.post(`${PYTHON_SERVICE_URL}/predict`, input);

    // Python returns either:
    // - cognitive_progress_score_next_14_days
    // or (older)
    // - predicted_score
    const predicted =
      response.data?.cognitive_progress_score_next_14_days ??
      response.data?.predicted_score;

    return res.json({
      success: true,
      predicted_score: predicted, // ✅ normalize for Flutter
      top_factors: response.data?.top_factors ?? [],
    });
  } catch (err) {
    console.error("Prediction error:", err.message);
    const status = err.response?.status || 500;
    const detail = err.response?.data || { error: err.message };
    return res.status(status).json({ success: false, ...detail });
  }
};

// ================================
// CREATE (store prediction)
// POST /chromabloom/cognitiveProgress
// body: { userId, progress_prediction }
// ================================
export const createProgress = async (req, res) => {
  try {
    const { userId, progress_prediction } = req.body;

    if (!userId || progress_prediction === undefined) {
      return res.status(400).json({
        success: false,
        message: "userId and progress_prediction are required",
      });
    }

    const doc = await CognitiveProgress.create({
      userId,
      progress_prediction,
    });

    return res.status(201).json({ success: true, data: doc });
  } catch (err) {
    console.error("createProgress error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// VIEW ALL
export const getAllProgress = async (req, res) => {
  try {
    const docs = await CognitiveProgress.find({}).sort({ createdAt: -1 });
    return res.json({ success: true, count: docs.length, data: docs });
  } catch (err) {
    console.error("getAllProgress error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// VIEW BY ID
export const getProgressById = async (req, res) => {
  try {
    const { id } = req.params;

    const doc = await CognitiveProgress.findById(id);
    if (!doc) {
      return res.status(404).json({ success: false, message: "Not found" });
    }

    return res.json({ success: true, data: doc });
  } catch (err) {
    console.error("getProgressById error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// VIEW BY userId
export const getProgressByUserId = async (req, res) => {
  try {
    const { userId } = req.params;

    const docs = await CognitiveProgress
      .find({ userId })
      .sort({ createdAt: -1 });

    return res.json({ success: true, count: docs.length, data: docs });
  } catch (err) {
    console.error("getProgressByUserId error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// UPDATE
export const updateProgress = async (req, res) => {
  try {
    const { id } = req.params;
    const { userId, progress_prediction } = req.body;

    const update = {};
    if (userId !== undefined) update.userId = userId;
    if (progress_prediction !== undefined)
      update.progress_prediction = progress_prediction;

    const doc = await CognitiveProgress.findByIdAndUpdate(id, update, {
      new: true,
      runValidators: true,
    });

    if (!doc) {
      return res.status(404).json({ success: false, message: "Not found" });
    }

    return res.json({ success: true, data: doc });
  } catch (err) {
    console.error("updateProgress error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// DELETE
export const deleteProgress = async (req, res) => {
  try {
    const { id } = req.params;

    const doc = await CognitiveProgress.findByIdAndDelete(id);
    if (!doc) {
      return res.status(404).json({ success: false, message: "Not found" });
    }

    return res.json({
      success: true,
      message: "Deleted successfully",
      data: doc,
    });
  } catch (err) {
    console.error("deleteProgress error:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
};
