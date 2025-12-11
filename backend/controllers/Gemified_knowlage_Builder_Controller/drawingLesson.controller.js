// controllers/drawingLesson.controller.js
import DrawingLesson from "../../models/Gamified_Knowlage_Builder_Model/Drawing_Lesson.js";  // adjust path if needed
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

    // Upload video to Cloudinary
    const uploadResult = await uploadVideoToCloudinary(req.file.buffer);

    // tips will usually come as JSON string in multipart/form-data
    let parsedTips = [];
    if (tips) {
      try {
        parsedTips = typeof tips === "string" ? JSON.parse(tips) : tips;
      } catch (e) {
        return res.status(400).json({
          success: false,
          message: "Invalid tips format. Send as JSON array.",
        });
      }
    }

    const lesson = await DrawingLesson.create({
      title,
      description,
      difficulty_level,
      video_url: uploadResult.secure_url,
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

    // If new video uploaded, upload to Cloudinary & replace
    if (req.file) {
      const uploadResult = await uploadVideoToCloudinary(req.file.buffer);
      lesson.video_url = uploadResult.secure_url;
      // (optional) you can also destroy old video via cloudinary.uploader.destroy(public_id)
    }

    if (title) lesson.title = title;
    if (description) lesson.description = description;
    if (difficulty_level) lesson.difficulty_level = difficulty_level;

    if (tips) {
      try {
        const parsedTips = typeof tips === "string" ? JSON.parse(tips) : tips;
        lesson.tips = parsedTips;
      } catch (e) {
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

    // (optional) also delete video from Cloudinary if you store public_id

    return res
      .status(200)
      .json({ success: true, message: "Lesson deleted successfully" });
  } catch (err) {
    next(err);
  }
};
