import { computeCycleFeatures } from "../../services/Interactive_Visual_Task_Scheduler/routineCycleFeatures.service.js";

import SystemActivity from "../../models/Interactive_Visual_Task_Scheduler_Model/systemActivityModel.js";
import ChildRoutinePlan from "../../models/Interactive_Visual_Task_Scheduler_Model/childRoutinePlanModel.js";
import RoutineRunModel from "../../models/Interactive_Visual_Task_Scheduler_Model/routineRunModel.js";

import axios from "axios";

import cloudinary from "../../config/cloudinary.js";

// helper: upload buffer to Cloudinary using upload_stream
const uploadBufferToCloudinary = (buffer, folder) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );
    stream.end(buffer); // send buffer
  });
};

// Controller to create a new system routine
export const createSystemActivity = async (req, res) => {
  try {
    let {
      title,
      description,
      age_group,
      development_area,
      steps,
      estimated_duration_minutes,
      difficulty_level,
    } = req.body;

    // 🔹 steps might come as a string when using multipart/form-data
    let parsedSteps = steps;
    if (typeof steps === "string") {
      try {
        parsedSteps = JSON.parse(steps);
      } catch (e) {
        return res.status(400).json({ error: "Invalid steps JSON format" });
      }
    }

    // 🔹 convert estimated_duration_minutes to Number if it's a string
    if (typeof estimated_duration_minutes === "string") {
      estimated_duration_minutes = Number(estimated_duration_minutes);
    }

    // ---------------- VALIDATION ----------------
    if (!title || !description) {
      return res
        .status(400)
        .json({ error: "title and description are required" });
    }

    if (!age_group) {
      return res.status(400).json({ error: "age_group is required" });
    }

    if (!development_area) {
      return res.status(400).json({ error: "development_area is required" });
    }

    if (
      !parsedSteps ||
      !Array.isArray(parsedSteps) ||
      parsedSteps.length === 0
    ) {
      return res.status(400).json({
        error: "At least one step is required",
      });
    }

    if (
      estimated_duration_minutes === undefined ||
      estimated_duration_minutes === null ||
      Number.isNaN(estimated_duration_minutes)
    ) {
      return res.status(400).json({
        error: "estimated_duration_minutes is required and must be a number",
      });
    }

    if (!difficulty_level) {
      return res.status(400).json({
        error: "difficulty_level is required",
      });
    }

    // ---------------- CLOUDINARY UPLOAD ----------------
    let uploadedImageUrl = null;

    if (req.file) {
      try {
        const result = await uploadBufferToCloudinary(
          req.file.buffer,
          "chromabloom/system_activities"
        );
        uploadedImageUrl = result.secure_url;
      } catch (error) {
        console.error("Cloudinary Upload Error:", error);
        return res.status(500).json({
          error: "Image upload failed",
          details: error.message,
        });
      }
    }

    // ---------------- CREATE SYSTEM ACTIVITY ----------------
    const activity = await SystemActivity.create({
      title,
      description,
      age_group,
      development_area,
      steps: parsedSteps,
      estimated_duration_minutes,
      difficulty_level,
      media_links: uploadedImageUrl ? [uploadedImageUrl] : [],
    });

    return res.status(201).json({
      message: "System activity created successfully",
      data: activity,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};

// GET all system activities
export const getAllSystemActivities = async (req, res) => {
  try {
    // Fetch everything sorted by created date (newest first)
    const activities = await SystemActivity.find().sort({ created_at: -1 });

    return res.status(200).json({
      message: "All system activities fetched successfully",
      count: activities.length,
      data: activities,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};


// --------------------------- Special controller --------------------------- // 


// GET or CREATE starter plan (5 easy) for 14-day cycle
export const getOrCreateStarterPlan = async (req, res) => {
  try {
    const { caregiverId, childId, ageGroup } = req.body;

    if (!caregiverId || !childId || !ageGroup) {
      return res.status(400).json({
        error: "caregiverId, childId, and ageGroup are required",
      });
    }

    const now = new Date();

    // 1) Check existing active plan (not expired)
    const existingPlan = await ChildRoutinePlan.findOne({
      caregiverId,
      childId,
      is_active: true,
      cycle_end_date: { $gte: now },
    }).populate({
      path: "activities.activityId",
      model: "SystemActivity", // ✅ important
    });

    if (existingPlan) {
      return res.status(200).json({
        message: "Active plan found",
        data: existingPlan,
      });
    }

    // 2) No active plan => create a new one
    // (Optional) deactivate old plans for safety
    await ChildRoutinePlan.updateMany(
      { caregiverId, childId, is_active: true },
      { $set: { is_active: false } }
    );

    // 3) Pick 5 random EASY activities for that age group
    const picked = await SystemActivity.aggregate([
      { $match: { age_group: ageGroup, difficulty_level: "easy" } },
      { $sample: { size: 5 } },
      { $project: { _id: 1 } },
    ]);

    if (!picked || picked.length < 5) {
      return res.status(404).json({
        error: "Not enough EASY activities for this age group",
      });
    }

    // 4) version = last version + 1 (or 1)
    const lastPlan = await ChildRoutinePlan.findOne({ caregiverId, childId })
      .sort({ created_at: -1 })
      .lean();

    const nextVersion = (lastPlan?.version || 0) + 1;

    // 5) 14-day cycle (today → +13 days end-of-day)
    const cycleStart = new Date(now);
    cycleStart.setHours(0, 0, 0, 0);

    const cycleEnd = new Date(cycleStart);
    cycleEnd.setDate(cycleEnd.getDate() + 13);
    cycleEnd.setHours(23, 59, 59, 999);

    // 6) Save plan with ordered activities
    const plan = await ChildRoutinePlan.create({
      caregiverId,
      childId,
      current_difficulty_level: "easy",
      activities: picked.map((p, idx) => ({
        activityId: p._id,
        order: idx + 1,
      })),
      cycle_start_date: cycleStart,
      cycle_end_date: cycleEnd,
      version: nextVersion,
      is_active: true,
    });

    // 7) Return populated plan
    const populatedPlan = await ChildRoutinePlan.findById(plan._id).populate({
      path: "activities.activityId",
      model: "SystemActivity",
    });

    return res.status(201).json({
      message: "New starter plan created",
      data: populatedPlan,
    });
  } catch (e) {
    return res.status(500).json({
      message: "Server error",
      error: e.message,
    });
  }
};

// POST /chromabloom/systemActivities/updateSystemActivityProgress
export const updateSystemActivityProgress = async (req, res) => {
  try {
    const {
      caregiverId,
      childId,
      planId,
      activityId,
      run_date,
      steps_progress,
      completed_duration_minutes,
    } = req.body;

    if (!caregiverId || !childId || !planId || !activityId || !run_date) {
      return res.status(400).json({
        error: "caregiverId, childId, planId, activityId, run_date required",
      });
    }

    // normalize date (YYYY-MM-DD)
    const [y, m, d] = run_date.split("-").map(Number);
    const runDate = new Date(Date.UTC(y, m - 1, d, 0, 0, 0));

    const activity = await SystemActivity.findById(activityId).lean();
    if (!activity) return res.status(404).json({ error: "Activity not found" });

    const total_steps = activity.steps.length;

    const normalized = Array.from({ length: total_steps }, (_, i) => {
      const found = steps_progress?.find(s => s.step_number === i + 1);
      return { step_number: i + 1, status: !!found?.status };
    });

    const completed_steps = normalized.filter(s => s.status).length;

    const run = await RoutineRunModel.findOneAndUpdate(
      {
        caregiverId,
        childId,
        planId,
        activityId,
        run_date: runDate,
      },
      {
        $set: {
          steps_progress: normalized,
          total_steps,
          completed_steps,
          skipped_steps: total_steps - completed_steps,
          completed_duration_minutes,
          run_date: runDate,
        },
      },
      { upsert: true, new: true }
    );

    res.status(200).json({ message: "Saved", data: run });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

// GET routine run progress for a specific planId + activityId + caregiverId + childId
export const getRoutineRunProgress = async (req, res) => {
  try {
    const { planId, activityId } = req.params;
    const { caregiverId, childId, run_date } = req.query;

    if (!planId || !activityId || !caregiverId || !childId || !run_date) {
      return res.status(400).json({
        error: "planId, activityId, caregiverId, childId, run_date required",
      });
    }

    const [y, m, d] = run_date.split("-").map(Number);
    if (!y || !m || !d) {
      return res.status(400).json({ error: "run_date must be YYYY-MM-DD" });
    }
    const runDate = new Date(Date.UTC(y, m - 1, d, 0, 0, 0, 0));

    const run = await RoutineRunModel.findOne({
      planId,
      activityId,
      caregiverId,
      childId,
      run_date: runDate,
    }).lean();

    return res.status(200).json({
      message: "Progress fetched",
      data: run ?? null,
    });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
};





/**
 * Call ML service to predict next difficulty level
 */
async function callMlForNextDifficulty(payload) {
  const mlUrl = process.env.ML_PREDICT_URL; // http://127.0.0.1:8000/predict-difficulty
  if (!mlUrl) throw new Error("ML_PREDICT_URL is not set in .env");

  const resp = await axios.post(mlUrl, payload, {
    headers: { "Content-Type": "application/json" },
    timeout: 15000,
  });

  return resp.data; // expected: { next_difficulty_level: "easy|medium|hard" }
}

/**
 * POST /chromabloom/systemActivities/closeCycleAndSendToML
 * body: { caregiverId, childId }
 */
export const closeCycleAndSendToML = async (req, res) => {
  try {
    const { caregiverId, childId } = req.body;

    if (!caregiverId || !childId) {
      return res.status(400).json({ error: "caregiverId and childId required" });
    }

    const now = new Date();

    // 1) find ended active plan
    const plan = await ChildRoutinePlan.findOne({
      caregiverId,
      childId,
      is_active: true,
      cycle_end_date: { $lte: now },
    }).lean();

    if (!plan) {
      return res.status(404).json({
        error: "No ended active plan found (cycle not finished yet)",
      });
    }

    // 2) compute 14-day features
    const features = await computeCycleFeatures({
      caregiverId,
      childId,
      planId: plan._id,
      cycleStart: plan.cycle_start_date,
      cycleEnd: plan.cycle_end_date,
      currentDifficultyLevel: plan.current_difficulty_level,
    });

    // 3) call ML
    const mlResult = await callMlForNextDifficulty(features);
    const nextLevel = mlResult?.next_difficulty_level;

    if (!nextLevel) {
      return res.status(500).json({
        error: "ML response missing next_difficulty_level",
        ml_result: mlResult,
      });
    }

    return res.status(200).json({
      message: "Cycle features sent to ML successfully",
      features_sent: features,
      ml_result: mlResult,
    });
  } catch (e) {
    return res.status(500).json({
      message: "Server error",
      error: e.message,
    });
  }
};
