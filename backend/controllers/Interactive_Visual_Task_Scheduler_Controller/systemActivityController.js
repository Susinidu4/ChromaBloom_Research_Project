import { computeCycleFeatures } from "../../services/Interactive_Visual_Task_Scheduler/routineCycleFeatures.service.js";
import mongoose from "mongoose";

import SystemActivity from "../../models/Interactive_Visual_Task_Scheduler_Model/systemActivityModel.js";
import ChildRoutinePlan from "../../models/Interactive_Visual_Task_Scheduler_Model/childRoutinePlanModel.js";
import RoutineRunModel from "../../models/Interactive_Visual_Task_Scheduler_Model/routineRunModel.js";
import Child from "../../models/Users/child.model.js";
import axios from "axios";

import cloudinary from "../../config/cloudinary.js";

// ------------------------- Admin ------------------------- //

// helper: upload buffer to Cloudinary using upload_stream
const uploadBufferToCloudinary = (buffer, folder) =>
  new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder, resource_type: "video", timeout: 180000 },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      },
    );
    stream.end(buffer);
  });

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

    // steps might come as a string when using multipart/form-data
    let parsedSteps = steps;
    if (typeof steps === "string") {
      try {
        parsedSteps = JSON.parse(steps);
      } catch (e) {
        return res.status(400).json({ error: "Invalid steps JSON format" });
      }
    }

    // convert estimated_duration_minutes to Number if it's a string
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
    if (!req.file) {
      return res
        .status(400)
        .json({ error: "Video file is required (field name: video)" });
    }

    let uploadedVideoUrl = null;

    try {
      const result = await new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          {
            folder: "chromabloom/system_activities/videos",
            resource_type: "video",
            timeout: 180000,
          },
          (error, result) => {
            if (error) return reject(error);
            resolve(result);
          },
        );

        stream.end(req.file.buffer);
      });

      uploadedVideoUrl = result.secure_url;
    } catch (error) {
      console.error("Cloudinary Upload Error:", error);
      return res.status(500).json({
        error: "Video upload failed",
        details: error.message,
      });
    }

    // CREATE system activity
    const activity = await SystemActivity.create({
      title,
      description,
      age_group,
      development_area,
      steps: parsedSteps,
      estimated_duration_minutes,
      difficulty_level,
      media_links: uploadedVideoUrl ? [uploadedVideoUrl] : [],
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

// GET system activity by ID
export const getSystemActivityById = async (req, res) => {
  try {
    const { id } = req.params;

    const activity = await SystemActivity.findById(id);

    if (!activity) {
      return res.status(404).json({ message: "System activity not found" });
    }

    return res.status(200).json({
      message: "System activity fetched successfully",
      data: activity,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Update System Activity (Edit routine)
export const updateSystemActivity = async (req, res) => {
  try {
    const { id } = req.params;

    // find by Mongo _id OR by system_activityId (SA-001)
    const activity = await SystemActivity.findOne({
      $or: [{ _id: id }, { system_activityId: id }],
    });

    if (!activity) {
      return res.status(404).json({ message: "Routine not found" });
    }

    const {
      title,
      description,
      age_group,
      development_area,
      difficulty_level,
      estimated_duration_minutes,
      steps,
      media_links,
    } = req.body;

    // Update only if provided
    if (title !== undefined) activity.title = title;
    if (description !== undefined) activity.description = description;
    if (age_group !== undefined) activity.age_group = age_group;
    if (development_area !== undefined)
      activity.development_area = development_area;
    if (difficulty_level !== undefined)
      activity.difficulty_level = difficulty_level;

    if (estimated_duration_minutes !== undefined) {
      const dur = Number(estimated_duration_minutes);
      if (Number.isNaN(dur) || dur <= 0) {
        return res.status(400).json({
          message: "estimated_duration_minutes must be a valid number > 0",
        });
      }
      activity.estimated_duration_minutes = dur;
    }

    let parsedSteps = steps;

    if (typeof steps === "string") {
      try {
        parsedSteps = JSON.parse(steps);
      } catch (e) {
        return res.status(400).json({ message: "Invalid steps JSON format" });
      }
    }

    // Steps: accept either [{instruction}] or [{step_number,instruction}]
    if (parsedSteps !== undefined) {
      if (!Array.isArray(parsedSteps) || parsedSteps.length === 0) {
        return res
          .status(400)
          .json({ message: "Routine must contain at least one step" });
      }

      const cleanedSteps = parsedSteps
        .map((s) => (typeof s === "string" ? { instruction: s } : s))
        .map((s) => ({ instruction: String(s.instruction || "").trim() }))
        .filter((s) => s.instruction.length > 0)
        .map((s, idx) => ({
          step_number: idx + 1,
          instruction: s.instruction,
        }));

      if (cleanedSteps.length === 0) {
        return res
          .status(400)
          .json({ message: "Routine must contain at least one step" });
      }

      activity.steps = cleanedSteps;
    }

    // if new video is uploaded, replace media_links with new URL
    if (req.file) {
      try {
        const result = await uploadBufferToCloudinary(
          req.file.buffer,
          "chromabloom/system_activities/videos",
        );
        activity.media_links = [result.secure_url];
      } catch (error) {
        return res.status(500).json({
          message: "Video upload failed",
          error: error.message,
        });
      }
    }

    await activity.save();

    return res.status(200).json({
      message: "Routine updated successfully",
      data: activity,
    });
  } catch (err) {
    return res.status(500).json({
      message: "Failed to update routine",
      error: err.message,
    });
  }
};

// DELETE system activity
export const deleteSystemActivity = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await SystemActivity.findByIdAndDelete(id);

    if (!deleted) {
      return res.status(404).json({ message: "SystemActivity not found" });
    }

    return res.status(200).json({
      message: "SystemActivity deleted successfully",
      data: { id: deleted._id, system_activityId: deleted.system_activityId },
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to delete SystemActivity",
      error: err.message,
    });
  }
};

// ------------------------- Caregiver ------------------------- //

// Used by Task Scheduler Home page

// GET routine summary: previous vs current difficulty level
export const getLatestRoutineSummary = async (req, res) => {
  try {
    const { caregiverId } = req.params;

    // 1️⃣ Get ACTIVE plan (current)
    const activePlan = await ChildRoutinePlan.findOne({
      caregiverId,
      is_active: true,
    }).lean();

    if (!activePlan) {
      return res.status(404).json({
        success: false,
        message: "No active routine plan found",
      });
    }

    const current = activePlan.current_difficulty_level;

    // 2️⃣ Get PREVIOUS plan (same child, older version)
    const previousPlan = await ChildRoutinePlan.findOne({
      caregiverId,
      version: activePlan.version - 1,
    }).lean();

    const previous = previousPlan
      ? previousPlan.current_difficulty_level
      : null;

    // 3️⃣ Generate message
    const summaryMessage = buildDifficultyMessage(previous, current);

    // 4️⃣ Response
    return res.status(200).json({
      success: true,
      data: {
        previousDifficulty: previous,
        currentDifficulty: current,
        message: summaryMessage,
      },
    });
  } catch (error) {
    console.error("Routine summary error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching routine summary",
    });
  }
};
// Helper to build difficulty level change message
function buildDifficultyMessage(previous, current) {
  if (!previous) {
    return "This is the first routine plan created for the child.";
  }

  if (previous === current) {
    return "The difficulty level remains the same to reinforce consistency and confidence.";
  }

  const transitions = {
    "easy->medium":
      "Great progress! The child has successfully mastered Easy-level routines and is ready to move on to Medium difficulty.",
    "medium->hard":
      "Excellent improvement! The child is now ready to take on more challenging Hard-level routines.",
    "hard->medium":
      "The difficulty was adjusted to Medium to strengthen understanding and reduce cognitive load.",
    "medium->easy":
      "The routine difficulty was lowered to Easy to help rebuild confidence and consistency.",
    "easy->hard":
      "Outstanding performance! The child advanced directly from Easy to Hard difficulty.",
    "hard->easy":
      "The difficulty was reset to Easy to support the child with foundational activities.",
  };

  return (
    transitions[`${previous}->${current}`] ||
    "The routine difficulty level was updated based on recent performance."
  );
}

// GET routine dashboard data for caregiver (and optional childId, planId, cycleStart, cycleEnd)(charts)
export const getRoutineDashboard = async (req, res) => {
  try {
    const { caregiverId } = req.params;
    const { childId, planId, cycleStart, cycleEnd } = req.query;

    if (!caregiverId) {
      return res
        .status(400)
        .json({ success: false, message: "caregiverId is required" });
    }

    // 1) Load plans for caregiver (optionally for a specific child)
    const planFilter = { caregiverId };
    if (childId) planFilter.childId = childId;

    const plans = await ChildRoutinePlan.find(planFilter)
      .sort({ version: 1 }) // keep overallProgress stable
      .lean();

    if (!plans.length) {
      return res.status(404).json({
        success: false,
        message: "No routine plans found for this caregiver",
      });
    }

    // 2) Build overallProgress + cycles list
    const overallProgress = plans.map((p) => ({
      version: p.version,
      difficulty: p.current_difficulty_level,
      cycleStart: p.cycle_start_date,
      cycleEnd: p.cycle_end_date,
      planMongoId: p._id,
    }));

    const cycles = plans
      .slice()
      .sort(
        (a, b) => new Date(b.cycle_start_date) - new Date(a.cycle_start_date),
      )
      .map((p) => ({
        label: `${formatDate(p.cycle_start_date)} - ${formatDate(
          p.cycle_end_date,
        )}`,
        cycleStart: p.cycle_start_date,
        cycleEnd: p.cycle_end_date,
        version: p.version,
        planMongoId: p._id,
        isActive: !!p.is_active,
      }));

    // 3) Decide which plan/cycle is selected
    let selectedPlan = null;

    // (a) If planId provided
    if (planId && mongoose.Types.ObjectId.isValid(planId)) {
      selectedPlan = plans.find((p) => String(p._id) === String(planId));
    }

    // (b) If cycleStart & cycleEnd provided
    if (!selectedPlan && cycleStart && cycleEnd) {
      const cs = startOfDay(new Date(cycleStart));
      const ce = endOfDay(new Date(cycleEnd));
      selectedPlan = plans.find((p) => {
        const ps = startOfDay(new Date(p.cycle_start_date)).getTime();
        const pe = endOfDay(new Date(p.cycle_end_date)).getTime();
        return ps === cs.getTime() && pe === ce.getTime();
      });
    }

    // (c) Default: active plan, else latest plan by cycle_start_date (NOT by version)
    if (!selectedPlan) {
      selectedPlan =
        plans.find((p) => p.is_active) ||
        plans
          .slice()
          .sort(
            (a, b) =>
              new Date(b.cycle_start_date) - new Date(a.cycle_start_date),
          )[0];
    }

    if (!selectedPlan) {
      return res.status(404).json({
        success: false,
        message: "No valid plan found to select",
      });
    }

    const cycleStartDate = startOfDay(new Date(selectedPlan.cycle_start_date));
    const cycleEndDate = endOfDay(new Date(selectedPlan.cycle_end_date));

    // 4) Compute TOTAL STEPS PER DAY from the PLAN activities
    // selectedPlan.activities = [{ activityId(ObjectId), order }]
    const activityIds = (selectedPlan.activities || [])
      .map((a) => a.activityId)
      .filter(Boolean);

    const activities = await SystemActivity.find({ _id: { $in: activityIds } })
      .select("steps")
      .lean();

    const stepsPerDay = activities.reduce((sum, a) => {
      const count = Array.isArray(a.steps) ? a.steps.length : 0;
      return sum + count;
    }, 0);

    // total expected steps for 14 days
    const totalStepsTotal = stepsPerDay * 14;

    // 5) Fetch routine runs for that selected cycle (we only NEED completed_steps per date now)
    const runFilter = {
      caregiverId,
      planId: selectedPlan._id,
      run_date: { $gte: cycleStartDate, $lte: cycleEndDate },
    };
    if (childId) runFilter.childId = childId;

    const runs = await RoutineRunModel.find(runFilter)
      .select("run_date completed_steps")
      .lean();

    // 6) Completed total (from runs)
    let completedStepsTotal = runs.reduce(
      (sum, r) => sum + (r.completed_steps || 0),
      0,
    );

    // If completedStepsTotal is bigger than expected total (edge case), clamp it
    if (completedStepsTotal > totalStepsTotal)
      completedStepsTotal = totalStepsTotal;

    // 7) Skipped total = expected - completed (this is the fix you asked)
    const skippedStepsTotal = Math.max(
      totalStepsTotal - completedStepsTotal,
      0,
    );

    // 8) Daily progress Day1..Day14
    // Build map by date string -> completedSteps
    const byDate = new Map();
    for (const r of runs) {
      const key = yyyyMmDd(r.run_date);
      byDate.set(key, (byDate.get(key) || 0) + (r.completed_steps || 0));
    }

    const dailyProgress = [];
    for (let i = 0; i < 14; i++) {
      const d = addDays(cycleStartDate, i);
      const key = yyyyMmDd(d);

      let completedSteps = byDate.get(key) || 0;

      // if multiple runs cause completed > stepsPerDay, clamp
      if (stepsPerDay > 0 && completedSteps > stepsPerDay) {
        completedSteps = stepsPerDay;
      }

      const completionPercent =
        stepsPerDay > 0 ? Math.round((completedSteps / stepsPerDay) * 100) : 0;

      dailyProgress.push({
        dayIndex: i + 1,
        date: key,
        completedSteps,
        totalSteps: stepsPerDay,
        completionPercent,
      });
    }

    // 9) Response
    return res.status(200).json({
      success: true,
      data: {
        overallProgress,
        cycles,
        selectedCycle: {
          planMongoId: selectedPlan._id,
          version: selectedPlan.version,
          difficulty: selectedPlan.current_difficulty_level,
          cycleStart: selectedPlan.cycle_start_date,
          cycleEnd: selectedPlan.cycle_end_date,
        },
        stepAnalysis: {
          completedStepsTotal,
          skippedStepsTotal, // ✅ fixed
          totalStepsTotal, // ✅ fixed (plan-based)
        },
        dailyProgress,
      },
    });
  } catch (error) {
    console.error("getRoutineDashboard error:", error);
    return res.status(500).json({
      success: false,
      message: "Server error while fetching routine dashboard",
    });
  }
};
// GetRoutineDashboard helper functions
function formatDate(date) {
  const d = new Date(date);
  const dd = String(d.getDate()).padStart(2, "0");
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const yyyy = d.getFullYear();
  return `${dd}/${mm}/${yyyy}`;
}

function yyyyMmDd(date) {
  const d = new Date(date);
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

function startOfDay(d) {
  const x = new Date(d);
  x.setHours(0, 0, 0, 0);
  return x;
}

function endOfDay(d) {
  const x = new Date(d);
  x.setHours(23, 59, 59, 999);
  return x;
}

function addDays(d, n) {
  const x = new Date(d);
  x.setDate(x.getDate() + n);
  return x;
}

// ------------------------- Special controllers ------------------------- //

// Used in display_userActivity page

// GET or CREATE starter plan (5 easy) for 14-day cycle (1 cycle = 14 days)
export const getOrCreateStarterPlan = async (req, res) => {
  try {
    // extract caregiverId, childId, ageGroup from body
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
      model: "SystemActivity",
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
      { $set: { is_active: false } },
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
    // cycle starts today 00:00
    const cycleStart = new Date(now);
    cycleStart.setHours(0, 0, 0, 0);
    // cycle ends in 13 days end-of-day
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

// system activity progress update (SAVE or UPDATE)
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

    // fetch activity to get total steps
    const activity = await SystemActivity.findById(activityId).lean();
    if (!activity) return res.status(404).json({ error: "Activity not found" });

    const total_steps = activity.steps.length;

    const normalized = Array.from({ length: total_steps }, (_, i) => {
      const found = steps_progress?.find((s) => s.step_number === i + 1);
      return { step_number: i + 1, status: !!found?.status };
    });

    // count completed steps
    const completed_steps = normalized.filter((s) => s.status).length;

    // upsert routine run
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
      { upsert: true, new: true },
    );

    res.status(200).json({ message: "Saved", data: run });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

// Ensure daily RoutineRuns exist for ALL activities in plan, then return them(automatically creates missing runs with default progress = not started)
export const getDailyRoutineRunsEnsureRecords = async (req, res) => {
  try {
    const { caregiverId, childId, planId, run_date } = req.query;

    if (!caregiverId || !childId || !planId || !run_date) {
      return res.status(400).json({
        error: "caregiverId, childId, planId, run_date required",
      });
    }

    // normalize date (YYYY-MM-DD) -> UTC midnight
    const [y, m, d] = run_date.split("-").map(Number);
    if (!y || !m || !d) {
      return res.status(400).json({ error: "run_date must be YYYY-MM-DD" });
    }
    const runDate = new Date(Date.UTC(y, m - 1, d, 0, 0, 0, 0));

    // 1) Get the plan (must exist and belong to caregiver/child)
    const plan = await ChildRoutinePlan.findOne({
      _id: planId,
      caregiverId,
      childId,
      is_active: true, // optional: remove if you want to allow old plans too
    }).lean();

    if (!plan) {
      return res.status(404).json({ error: "Plan not found (or not active)" });
    }

    const planActivityIds = (plan.activities || []).map((a) =>
      String(a.activityId),
    );

    if (planActivityIds.length === 0) {
      return res.status(200).json({
        message: "No activities in plan",
        data: [],
      });
    }

    // 2) Find existing runs for this day for the plan activities
    const existingRuns = await RoutineRunModel.find({
      caregiverId,
      childId,
      planId,
      run_date: runDate,
      activityId: { $in: planActivityIds },
    }).lean();

    const existingSet = new Set(existingRuns.map((r) => String(r.activityId)));
    const missingActivityIds = planActivityIds.filter(
      (id) => !existingSet.has(String(id)),
    );

    // 3) If missing runs exist, create them with default progress
    if (missingActivityIds.length > 0) {
      // Fetch activities to get steps length
      const activities = await SystemActivity.find(
        { _id: { $in: missingActivityIds } },
        { steps: 1 },
      ).lean();

      const stepLenMap = new Map(
        activities.map((a) => [
          String(a._id),
          Array.isArray(a.steps) ? a.steps.length : 0,
        ]),
      );

      const docsToInsert = missingActivityIds.map((actId) => {
        const total_steps = stepLenMap.get(String(actId)) ?? 0;

        const steps_progress = Array.from({ length: total_steps }, (_, i) => ({
          step_number: i + 1,
          status: false,
        }));

        return {
          caregiverId,
          childId,
          planId,
          activityId: actId,
          run_date: runDate,
          steps_progress,
          total_steps,
          completed_steps: 0,
          skipped_steps: total_steps, // not done = skipped (your current model)
          completed_duration_minutes: 0,
        };
      });

      // Insert missing docs (ignore duplicates if two requests happen at same time)
      try {
        await RoutineRunModel.insertMany(docsToInsert, { ordered: false });
      } catch (err) {
        // If duplicates happen due to race condition, ignore duplicate key errors
        if (err?.code !== 11000) throw err;
      }
    }

    // 4) Return full runs for this day (now complete)
    const finalRuns = await RoutineRunModel.find({
      caregiverId,
      childId,
      planId,
      run_date: runDate,
      activityId: { $in: planActivityIds },
    })
      .populate({ path: "activityId", model: "SystemActivity" })
      .lean();

    // Sort by plan order (optional but nice)
    const orderMap = new Map(
      (plan.activities || []).map((a) => [String(a.activityId), a.order]),
    );
    finalRuns.sort(
      (a, b) =>
        (orderMap.get(String(a.activityId)) || 999) -
        (orderMap.get(String(b.activityId)) || 999),
    );

    return res.status(200).json({
      message: "Daily runs ensured and fetched",
      missing_created: missingActivityIds.length,
      data: finalRuns,
    });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Display routine run progress for a specific planId + activityId + caregiverId + childId (READ)
export const getRoutineRunProgress = async (req, res) => {
  try {
    // extract params and query
    const { planId, activityId } = req.params;
    const { caregiverId, childId, run_date } = req.query;

    if (!planId || !activityId || !caregiverId || !childId || !run_date) {
      return res.status(400).json({
        error: "planId, activityId, caregiverId, childId, run_date required",
      });
    }

    // normalize date (YYYY-MM-DD)
    const [y, m, d] = run_date.split("-").map(Number);
    if (!y || !m || !d) {
      return res.status(400).json({ error: "run_date must be YYYY-MM-DD" });
    }
    // convert to UTC date
    const runDate = new Date(Date.UTC(y, m - 1, d, 0, 0, 0, 0));

    // fetch routine run
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

// ------------------------- ML integration ------------------------- //

//This function use for testing ML integration only

// This function computes features for the ended cycle and sends them to ML
// to get the next difficulty level recommendation.
export const closeCycleAndSendToML = async (req, res) => {
  try {
    const { caregiverId, childId } = req.body;

    if (!caregiverId || !childId) {
      return res
        .status(400)
        .json({ error: "caregiverId and childId required" });
    }
    // current date-time
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
    // send features, get next level
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

// Helper to call ML service for next difficulty level
async function callMlForNextDifficulty(payload) {
  const base = process.env.PYTHON_SERVICE_URL; // http://localhost:8000
  if (!base) throw new Error("PYTHON_SERVICE_URL is not set in .env");

  const url = `${base}/routine/predict-difficulty`; // full URL

  const resp = await axios.post(url, payload, {
    headers: { "Content-Type": "application/json" },
    timeout: 15000,
  });

  return resp.data; // { childId, next_difficulty_level }
}

//---------------------------- next routine plan --------------------------- //

// Real production flow

// This function closes the ended plan, sends features to ML, gets next level,
// picks new activities, and creates the next 14-day plan.
// export const closeCycleSendToMLAndCreateNextPlan = async (req, res) => {
//   try {
//     const { caregiverId, childId } = req.body;

//     if (!caregiverId || !childId) {
//       return res
//         .status(400)
//         .json({ error: "caregiverId and childId required" });
//     }

//     const now = new Date();

//     // 1) Find ended active plan
//     const endedPlan = await ChildRoutinePlan.findOne({
//       caregiverId,
//       childId,
//       is_active: true,
//       cycle_end_date: { $lte: now },
//     }).lean();

//     if (!endedPlan) {
//       return res.status(404).json({
//         error: "No ended active plan found (cycle not finished yet)",
//       });
//     }

//     // 2) Compute features + call ML (you already have these functions)
//     const features = await computeCycleFeatures({
//       caregiverId,
//       childId,
//       planId: endedPlan._id,
//       cycleStart: endedPlan.cycle_start_date,
//       cycleEnd: endedPlan.cycle_end_date,
//       currentDifficultyLevel: endedPlan.current_difficulty_level,
//     });

//     const mlResult = await callMlForNextDifficulty(features);
//     const nextLevel = mlResult?.next_difficulty_level;

//     if (!nextLevel) {
//       return res.status(500).json({
//         error: "ML response missing next_difficulty_level",
//         ml_result: mlResult,
//       });
//     }

//     // 3) Get child's age_group via logged-in caregiver + childId
//     // (This ensures caregiver owns this child)
//     const child = await Child.findOne({
//       _id: childId, // if your childId is Mongo _id
//       caregiver: caregiverId,
//     }).lean();

//     if (!child) {
//       return res
//         .status(404)
//         .json({ error: "Child not found for this caregiver" });
//     }

//     // If you store age_group directly:
//     // const ageGroup = child.age_group; // e.g. "age_6"
//     const ageGroup = getAgeGroupFromDOB(child.dateOfBirth);

//     // DEBUG LOGS (temporary)
//     // console.log("DOB:", child.dateOfBirth);
//     // console.log("Computed age_group:", ageGroup);

//     if (!ageGroup) {
//       return res.status(400).json({ error: "Child age_group not found" });
//     }

//     // 4) Pick 5 random activities for ageGroup + nextLevel
//     const picked = await SystemActivity.aggregate([
//       { $match: { age_group: ageGroup, difficulty_level: nextLevel } },
//       { $sample: { size: 5 } },
//       { $project: { _id: 1 } },
//     ]);

//     if (!picked || picked.length < 5) {
//       return res.status(404).json({
//         error: `Not enough activities for age_group=${ageGroup} difficulty_level=${nextLevel}`,
//       });
//     }

//     // 5) Deactivate old plan
//     await ChildRoutinePlan.updateOne(
//       { _id: endedPlan._id },
//       { $set: { is_active: false } },
//     );

//     // 6) Next version number
//     const lastPlan = await ChildRoutinePlan.findOne({ caregiverId, childId })
//       .sort({ created_at: -1 })
//       .lean();

//     const nextVersion = (lastPlan?.version || 0) + 1;

//     // 7) Create new 14-day plan (new cycle)
//     const { start, end } = computeNextCycleDatesFromEndedPlan(endedPlan.cycle_end_date);

//     // create new plan
//     const newPlan = await ChildRoutinePlan.create({
//       caregiverId,
//       childId,
//       current_difficulty_level: nextLevel,
//       activities: picked.map((p, idx) => ({
//         activityId: p._id,
//         order: idx + 1,
//       })),
//       cycle_start_date: start,
//       cycle_end_date: end,
//       version: nextVersion,
//       is_active: true,
//     });

//     // 8) Return populated plan
//     const populated = await ChildRoutinePlan.findById(newPlan._id).populate({
//       path: "activities.activityId",
//       model: "SystemActivity",
//     });

//     return res.status(201).json({
//       message: "Next 14-day plan created successfully",
//       ended_plan_id: endedPlan._id,
//       features_sent: features,
//       ml_result: mlResult,
//       new_plan: populated,
//     });
//   } catch (e) {
//     return res.status(500).json({ message: "Server error", error: e.message });
//   }
// };

// // Continuous cycle dates: next cycle starts immediately after the previous cycle ends
// function computeNextCycleDatesFromEndedPlan(prevCycleEndDate) {
//   const prevEnd = new Date(prevCycleEndDate);

//   // next start = next day at 00:00:00.000
//   const start = new Date(prevEnd);
//   start.setDate(start.getDate() + 1);
//   start.setHours(0, 0, 0, 0);

//   // next end = start + 13 days at 23:59:59.999
//   const end = new Date(start);
//   end.setDate(end.getDate() + 13);
//   end.setHours(23, 59, 59, 999);

//   return { start, end };
// }

// // Helper to get age group from date of birth
// function getAgeGroupFromDOB(dateOfBirth) {
//   // child’s date of birth
//   const dob = new Date(dateOfBirth);
//   const today = new Date();

//   // calculate age
//   let age = today.getFullYear() - dob.getFullYear();
//   const m = today.getMonth() - dob.getMonth();

//   // adjust if birthday hasn't occurred yet this year
//   if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
//     age--;
//   }
//   // map age to age_group string
//   if (age <= 2) return "2";
//   if (age === 3) return "3";
//   if (age === 4) return "4";
//   if (age === 5) return "5";
//   if (age === 6) return "6";
//   if (age === 7) return "7";
//   if (age === 8) return "8";
//   if (age === 9) return "9";
//   return "10";
// }

// UPDATED CONTROLLER: auto-catches up ALL missing 14-day plans in ONE call
// It will keep creating plans until the active plan's cycle_end_date is AFTER "now".
export const closeCycleSendToMLAndCreateNextPlan = async (req, res) => {
  try {
    const { caregiverId, childId } = req.body;

    if (!caregiverId || !childId) {
      return res
        .status(400)
        .json({ error: "caregiverId and childId required" });
    }

    const now = new Date();

    // Get child + ageGroup ONCE (no need inside loop)
    const child = await Child.findOne({
      _id: childId, // if your childId is Mongo _id
      caregiver: caregiverId,
    }).lean();

    if (!child) {
      return res
        .status(404)
        .json({ error: "Child not found for this caregiver" });
    }

    const ageGroup = getAgeGroupFromDOB(child.dateOfBirth);
    if (!ageGroup) {
      return res.status(400).json({ error: "Child age_group not found" });
    }

    // Safety guard to avoid infinite loops (e.g., bad dates)
    const MAX_PLANS_TO_CREATE = 30;

    const createdPlans = [];
    let loops = 0;

    while (loops < MAX_PLANS_TO_CREATE) {
      loops++;

      // 1) Find ended active plan
      const endedPlan = await ChildRoutinePlan.findOne({
        caregiverId,
        childId,
        is_active: true,
        cycle_end_date: { $lte: now },
      }).lean();

      // If there is no ended active plan -> we are already caught up
      if (!endedPlan) break;

      // 2) Compute features + call ML (based on ended plan)
      const features = await computeCycleFeatures({
        caregiverId,
        childId,
        planId: endedPlan._id,
        cycleStart: endedPlan.cycle_start_date,
        cycleEnd: endedPlan.cycle_end_date,
        currentDifficultyLevel: endedPlan.current_difficulty_level,
      });

      const mlResult = await callMlForNextDifficulty(features);
      const nextLevel = mlResult?.next_difficulty_level;

      if (!nextLevel) {
        return res.status(500).json({
          error: "ML response missing next_difficulty_level",
          ml_result: mlResult,
        });
      }

      // 3) Pick 5 random activities for ageGroup + nextLevel
      const picked = await SystemActivity.aggregate([
        { $match: { age_group: ageGroup, difficulty_level: nextLevel } },
        { $sample: { size: 5 } },
        { $project: { _id: 1 } },
      ]);

      if (!picked || picked.length < 5) {
        return res.status(404).json({
          error: `Not enough activities for age_group=${ageGroup} difficulty_level=${nextLevel}`,
        });
      }

      // 4) Deactivate old plan
      await ChildRoutinePlan.updateOne(
        { _id: endedPlan._id },
        { $set: { is_active: false } },
      );

      // 5) Next version number (based on latest plan in DB)
      const lastPlan = await ChildRoutinePlan.findOne({ caregiverId, childId })
        .sort({ created_at: -1 })
        .lean();

      const nextVersion = (lastPlan?.version || 0) + 1;

      // 6) Create next 14-day plan
      const { start, end } = computeNextCycleDatesFromEndedPlan(
        endedPlan.cycle_end_date,
      );

      const newPlan = await ChildRoutinePlan.create({
        caregiverId,
        childId,
        current_difficulty_level: nextLevel,
        activities: picked.map((p, idx) => ({
          activityId: p._id,
          order: idx + 1,
        })),
        cycle_start_date: start,
        cycle_end_date: end,
        version: nextVersion,
        is_active: true,
      });

      createdPlans.push({
        created_plan_id: newPlan._id,
        version: newPlan.version,
        level: newPlan.current_difficulty_level,
        start: newPlan.cycle_start_date,
        end: newPlan.cycle_end_date,
        ended_plan_id: endedPlan._id,
      });

      // LOOP continues:
      // if this newly created plan is also already ended compared to "now",
      // the next while iteration will close it and create another one.
    }

    if (createdPlans.length === 0) {
      return res.status(200).json({
        message: "No ended active plan found (already up to date)",
        created_count: 0,
        created_plans: [],
      });
    }

    // Return the LAST created plan populated (nice for frontend)
    const lastCreatedId = createdPlans[createdPlans.length - 1].created_plan_id;

    const populatedLast = await ChildRoutinePlan.findById(
      lastCreatedId,
    ).populate({
      path: "activities.activityId",
      model: "SystemActivity",
    });

    return res.status(201).json({
      message: "Missing 14-day plans generated until up-to-date",
      created_count: createdPlans.length,
      created_plans: createdPlans,
      last_active_plan: populatedLast,
      safety_stop: createdPlans.length >= MAX_PLANS_TO_CREATE,
    });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
};

// Continuous cycle dates: next cycle starts immediately after the previous cycle ends
function computeNextCycleDatesFromEndedPlan(prevCycleEndDate) {
  const prevEnd = new Date(prevCycleEndDate);

  // next start = next day at 00:00:00.000
  const start = new Date(prevEnd);
  start.setDate(start.getDate() + 1);
  start.setHours(0, 0, 0, 0);

  // next end = start + 13 days at 23:59:59.999
  const end = new Date(start);
  end.setDate(end.getDate() + 13);
  end.setHours(23, 59, 59, 999);

  return { start, end };
}

// Helper to get age group from date of birth
function getAgeGroupFromDOB(dateOfBirth) {
  const dob = new Date(dateOfBirth);
  const today = new Date();

  let age = today.getFullYear() - dob.getFullYear();
  const m = today.getMonth() - dob.getMonth();

  if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) age--;

  if (age <= 2) return "2";
  if (age === 3) return "3";
  if (age === 4) return "4";
  if (age === 5) return "5";
  if (age === 6) return "6";
  if (age === 7) return "7";
  if (age === 8) return "8";
  if (age === 9) return "9";
  return "10";
}
