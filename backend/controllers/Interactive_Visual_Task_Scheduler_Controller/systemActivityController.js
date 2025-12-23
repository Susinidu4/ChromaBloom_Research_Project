import SystemActivity from "../../models/Interactive_Visual_Task_Scheduler_Model/systemActivityModel.js";
import ChildRoutinePlan from "../../models/Interactive_Visual_Task_Scheduler_Model/childRoutinePlanModel.js";
import RoutineRunModel from "../../models/Interactive_Visual_Task_Scheduler_Model/routineRunModel.js";


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

// Update system activity progress for a routine run
export const updateSystemActivityProgress = async (req, res) => {
  try {
    const {
      caregiverId,
      childId,
      planId,
      activityId,
      steps_progress,
      completed_duration_minutes,
    } = req.body;

    if (!caregiverId || !childId || !planId || !activityId) {
      return res.status(400).json({
        error: "caregiverId, childId, planId, activityId are required",
      });
    }

    // 1) validate active plan
    const now = new Date();
    const plan = await ChildRoutinePlan.findOne({
      _id: planId,
      caregiverId,
      childId,
      is_active: true,
      cycle_end_date: { $gte: now },
    }).lean();

    if (!plan) {
      return res.status(404).json({
        error: "Active plan not found for this caregiver/child",
      });
    }

    // 2) validate activity
    const activity = await SystemActivity.findById(activityId).lean();
    if (!activity) return res.status(404).json({ error: "System activity not found" });

    const total_steps = Array.isArray(activity.steps) ? activity.steps.length : 0;
    if (total_steps === 0) return res.status(400).json({ error: "Activity has no steps" });

    // 3) normalize steps_progress -> always 1..total_steps
    const incoming = Array.isArray(steps_progress) ? steps_progress : [];
    const normalized = Array.from({ length: total_steps }, (_, idx) => {
      const stepNo = idx + 1;
      const found = incoming.find((s) => Number(s.step_number) === stepNo);
      return { step_number: stepNo, status: found ? !!found.status : false };
    });

    const completed_steps = normalized.filter((s) => s.status).length;
    const skipped_steps = total_steps - completed_steps;

    const completedMins = Math.max(0, Number(completed_duration_minutes) || 0);

    // 4) prevent duplicate "same day" save using created_at (since you removed date field)
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date();
    end.setHours(23, 59, 59, 999);

    const existingRun = await RoutineRunModel.findOne({
      planId,
      activityId,
      created_at: { $gte: start, $lte: end },
    });

    if (existingRun) {
      existingRun.steps_progress = normalized;
      existingRun.total_steps = total_steps;
      existingRun.completed_steps = completed_steps;
      existingRun.skipped_steps = skipped_steps;
      existingRun.completed_duration_minutes = completedMins;
      await existingRun.save();

      return res.status(200).json({
        message: "Routine run updated",
        data: existingRun,
      });
    }

    const created = await RoutineRunModel.create({
      caregiverId,
      childId,
      planId,
      activityId,
      steps_progress: normalized,
      total_steps,
      completed_steps,
      skipped_steps,
      completed_duration_minutes: completedMins,
    });

    return res.status(201).json({
      message: "Routine run saved",
      data: created,
    });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
};

// GET routine run progress for a specific planId + activityId + caregiverId + childId
export const getRoutineRunProgress = async (req, res) => {
  try {
    const { planId, activityId } = req.params;
    const { caregiverId, childId } = req.query; // pass from frontend

    if (!planId || !activityId || !caregiverId || !childId) {
      return res.status(400).json({ error: "planId, activityId, caregiverId, childId required" });
    }

    const run = await RoutineRunModel.findOne({
      planId,
      activityId,
      caregiverId,
      childId,
    }).lean();

    return res.status(200).json({
      message: "Progress fetched",
      data: run ?? null,
    });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
};


