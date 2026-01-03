import DrawingLesson from "../../models/Gamified_Knowlage_Builder_Model/Drawing_Lesson.js";
import cloudinary from "../../config/cloudinary.js";

// helper: upload video buffer to Cloudinary
const uploadVideoToCloudinary = (fileBuffer) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        resource_type: "video",
        folder: "chromabloom/drawing_lessons",
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );

    stream.end(fileBuffer);
  });
};

// ✅ helper: always generate a "safe" MP4 url (H.264 + AAC)
// Fixes: audio works but video stuck/black on many devices
const buildSafeMp4Url = (publicId) => {
  return cloudinary.url(publicId, {
    resource_type: "video",
    format: "mp4",
    secure: true,
    transformation: [
      { video_codec: "h264" },
      { audio_codec: "aac" },
    ],
  });
};

// @desc    Create a drawing lesson (with video upload)
// @route   POST /chromabloom/drawing-lessons
export const createDrawingLesson = async (req, res, next) => {
  try {
    const { title, description, difficulty_level, tips } = req.body;

    if (!req.file) {
      return res
        .status(400)
        .json({ success: false, message: "Video file is required" });
    }

    const uploadResult = await uploadVideoToCloudinary(req.file.buffer);

    // tips parsing
    let parsedTips = [];
    if (tips) {
      try {
        parsedTips = typeof tips === "string" ? JSON.parse(tips) : tips;
      } catch {
        return res.status(400).json({
          success: false,
          message: "Invalid tips format. Send as JSON array.",
        });
      }
    }

    const safeUrl = buildSafeMp4Url(uploadResult.public_id);

    const lesson = await DrawingLesson.create({
      title,
      description,
      difficulty_level,
      video_url: safeUrl,                 // ✅ use safe url
      video_public_id: uploadResult.public_id,
      tips: parsedTips,
    });

    return res.status(201).json({ success: true, data: lesson });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all drawing lessons
// @route   GET /chromabloom/drawing-lessons
export const getAllDrawingLessons = async (req, res, next) => {
  try {
    const lessons = await DrawingLesson.find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: lessons });
  } catch (err) {
    next(err);
  }
};

// @desc    Get a single lesson by ID
// @route   GET /chromabloom/drawing-lessons/:id
export const getDrawingLessonById = async (req, res, next) => {
  try {
    const lesson = await DrawingLesson.findById(req.params.id);

    if (!lesson) {
      return res
        .status(404)
        .json({ success: false, message: "Lesson not found" });
    }

    return res.status(200).json({ success: true, data: lesson });
  } catch (err) {
    next(err);
  }
};

// @desc    Update a lesson (optionally replace video)
// @route   PUT /chromabloom/drawing-lessons/:id
export const updateDrawingLesson = async (req, res, next) => {
  try {
    const { title, description, difficulty_level, tips } = req.body;

    const lesson = await DrawingLesson.findById(req.params.id);
    if (!lesson) {
      return res
        .status(404)
        .json({ success: false, message: "Lesson not found" });
    }

    // If new video uploaded, upload & replace (also update public_id + safe url)
    if (req.file) {
      const uploadResult = await uploadVideoToCloudinary(req.file.buffer);
      lesson.video_public_id = uploadResult.public_id;
      lesson.video_url = buildSafeMp4Url(uploadResult.public_id);
    }

    if (title) lesson.title = title;
    if (description) lesson.description = description;
    if (difficulty_level) lesson.difficulty_level = difficulty_level;

    if (tips) {
      try {
        const parsedTips = typeof tips === "string" ? JSON.parse(tips) : tips;
        lesson.tips = parsedTips;
      } catch {
        return res.status(400).json({
          success: false,
          message: "Invalid tips format. Send as JSON array.",
        });
      }
    }

    await lesson.save();

    return res.status(200).json({ success: true, data: lesson });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete a drawing lesson
// @route   DELETE /chromabloom/drawing-lessons/:id
export const deleteDrawingLesson = async (req, res, next) => {
  try {
    const lesson = await DrawingLesson.findById(req.params.id);

    if (!lesson) {
      return res
        .status(404)
        .json({ success: false, message: "Lesson not found" });
    }

    await lesson.deleteOne();

    // Optional: also delete Cloudinary asset
    // if (lesson.video_public_id) {
    //   await cloudinary.uploader.destroy(lesson.video_public_id, { resource_type: "video" });
    // }

    return res
      .status(200)
      .json({ success: true, message: "Lesson deleted successfully" });
  } catch (err) {
    next(err);
  }
};
