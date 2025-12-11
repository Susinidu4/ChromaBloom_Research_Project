import SystemActivity from "../../models/Interactive_Visual_Task_Scheduler_Model/systemActivityModel.js";
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
