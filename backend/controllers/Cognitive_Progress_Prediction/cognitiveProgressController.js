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


// =======================================================
// PREDICT
// POST /chromabloom/cognitiveProgress/predict
// =======================================================
export const predictCognitiveProgress = async (req, res) => {
  try {
    const input = req.body;

    // Validate required fields
    for (const field of requiredFields) {
      if (!(field in input)) {
        return res.status(400).json({
          success: false,
          error: `Missing field: ${field}`,
        });
      }
    }

    // Call Python ML service
    const response = await axios.post(
      `${PYTHON_SERVICE_URL}/predict`,
      input
    );

    const predicted =
      response.data?.cognitive_progress_score_next_14_days ??
      response.data?.predicted_score;

    const positive_factors =
      response.data?.explainability?.top_positive_factors ?? [];

    const negative_factors =
      response.data?.explainability?.top_negative_factors ?? [];

    return res.json({
      success: true,
      predicted_score: predicted,
      positive_factors,
      negative_factors,
    });
  } catch (err) {
    console.error("Prediction error:", err.message);

    const status = err.response?.status || 500;
    const detail = err.response?.data || { error: err.message };

    return res.status(status).json({
      success: false,
      ...detail,
    });
  }
};



// =======================================================
// CREATE (Store Prediction)
// POST /chromabloom/cognitiveProgress
// =======================================================
export const createProgress = async (req, res) => {
  try {
    const {
      userId,
      progress_prediction,
      predicted_score,
      positive_factors,
      negative_factors,
      top_positive_factors,
      top_negative_factors,
      explainability
    } = req.body;

    // Use flexible naming (handle both prediction output and DB input names)
    const final_prediction = progress_prediction ?? predicted_score;
    const final_positive = positive_factors || top_positive_factors || explainability?.top_positive_factors || [];
    const final_negative = negative_factors || top_negative_factors || explainability?.top_negative_factors || [];

    if (!userId || final_prediction === undefined) {
      return res.status(400).json({
        success: false,
        message: "userId and progress_prediction/predicted_score are required",
      });
    }

    const doc = await CognitiveProgress.create({
      userId,
      progress_prediction: final_prediction,
      positive_factors: final_positive,
      negative_factors: final_negative,
    });

    return res.status(201).json({
      success: true,
      data: doc,
    });
  } catch (err) {
    console.error("createProgress error:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};



// =======================================================
// VIEW ALL
// =======================================================
export const getAllProgress = async (req, res) => {
  try {
    const docs = await CognitiveProgress
      .find({})
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      count: docs.length,
      data: docs,
    });
  } catch (err) {
    console.error("getAllProgress error:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};



// =======================================================
// VIEW BY ID
// =======================================================
export const getProgressById = async (req, res) => {
  try {
    const { id } = req.params;

    const doc = await CognitiveProgress.findById(id);

    if (!doc) {
      return res.status(404).json({
        success: false,
        message: "Not found",
      });
    }

    return res.json({
      success: true,
      data: doc,
    });
  } catch (err) {
    console.error("getProgressById error:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};



// =======================================================
// VIEW BY USER ID
// =======================================================
export const getProgressByUserId = async (req, res) => {
  try {
    const { userId } = req.params;

    const docs = await CognitiveProgress
      .find({ userId })
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      count: docs.length,
      data: docs,
    });
  } catch (err) {
    console.error("getProgressByUserId error:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};



// =======================================================
// UPDATE
// =======================================================
export const updateProgress = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      userId,
      progress_prediction,
      predicted_score,
      positive_factors,
      negative_factors,
      top_positive_factors,
      top_negative_factors,
      explainability
    } = req.body;

    const update = {};

    if (userId !== undefined) update.userId = userId;

    // Support multiple naming conventions for prediction field
    if (progress_prediction !== undefined) update.progress_prediction = progress_prediction;
    else if (predicted_score !== undefined) update.progress_prediction = predicted_score;

    // Support multiple naming conventions for factors
    if (positive_factors !== undefined) update.positive_factors = positive_factors;
    else if (top_positive_factors !== undefined) update.positive_factors = top_positive_factors;
    else if (explainability?.top_positive_factors !== undefined) update.positive_factors = explainability.top_positive_factors;

    if (negative_factors !== undefined) update.negative_factors = negative_factors;
    else if (top_negative_factors !== undefined) update.negative_factors = top_negative_factors;
    else if (explainability?.top_negative_factors !== undefined) update.negative_factors = explainability.top_negative_factors;

    const doc = await CognitiveProgress.findByIdAndUpdate(id, update, {
      new: true,
      runValidators: true,
    });

    if (!doc) {
      return res.status(404).json({
        success: false,
        message: "Not found",
      });
    }

    return res.json({
      success: true,
      data: doc,
    });
  } catch (err) {
    console.error("updateProgress error:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};



// =======================================================
// DELETE
// =======================================================
export const deleteProgress = async (req, res) => {
  try {
    const { id } = req.params;

    const doc = await CognitiveProgress.findByIdAndDelete(id);

    if (!doc) {
      return res.status(404).json({
        success: false,
        message: "Not found",
      });
    }

    return res.json({
      success: true,
      message: "Deleted successfully",
      data: doc,
    });
  } catch (err) {
    console.error("deleteProgress error:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};