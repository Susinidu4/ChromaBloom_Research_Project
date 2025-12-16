// controllers/problemSolvingLesson.controller.js
import ProblemSolvingLesson from "../../models/Gamified_Knowlage_Builder_Model/Problem_Solving_Lesson.js"; // adjust path if needed
import cloudinary from "../../config/cloudinary.js";

// Helper: upload a single image buffer to Cloudinary
const uploadImageToCloudinary = (fileBuffer) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        resource_type: "image",
        folder: "chromabloom/problem_solving_lessons",
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );
    stream.end(fileBuffer);
  });
};

// @desc    Create a problem solving lesson (with optional image upload)
// @route   POST /chromabloom/problem-solving-lessons
export const createProblemSolvingLesson = async (req, res, next) => {
  try {
    const { title, content, difficultyLevel, correct_answer, tips } = req.body;

    if (!title || !difficultyLevel || !correct_answer) {
      return res.status(400).json({
        success: false,
        message: "title, difficultyLevel, and correct_answer are required",
      });
    }

    // Parse tips (if sent as JSON string in multipart/form-data)
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

    // Handle images upload (if any)
    let images = [];
    if (req.files && req.files.length > 0) {
      const uploadPromises = req.files.map((file) =>
        uploadImageToCloudinary(file.buffer)
      );
      const uploadResults = await Promise.all(uploadPromises);

      images = uploadResults.map((result, index) => ({
        image_number: index + 1,
        image_url: result.secure_url,
      }));
    }

    const lesson = await ProblemSolvingLesson.create({
      title,
      content,
      difficultyLevel,
      correct_answer,
      tips: parsedTips,
      images,
    });

    return res.status(201).json({ success: true, data: lesson });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all problem solving lessons
// @route   GET /chromabloom/problem-solving-lessons
export const getAllProblemSolvingLessons = async (req, res, next) => {
  try {
    const lessons = await ProblemSolvingLesson.find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, data: lessons });
  } catch (err) {
    next(err);
  }
};

// @desc    Get a single lesson by ID
// @route   GET /chromabloom/problem-solving-lessons/:id
export const getProblemSolvingLessonById = async (req, res, next) => {
  try {
    const lesson = await ProblemSolvingLesson.findById(req.params.id);

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

// @desc    Update a problem solving lesson (optionally replace images)
// @route   PUT /chromabloom/problem-solving-lessons/:id
export const updateProblemSolvingLesson = async (req, res, next) => {
  try {
    const { title, content, difficultyLevel, correct_answer, tips } = req.body;

    const lesson = await ProblemSolvingLesson.findById(req.params.id);
    if (!lesson) {
      return res
        .status(404)
        .json({ success: false, message: "Lesson not found" });
    }

    if (title) lesson.title = title;
    if (content) lesson.content = content;
    if (difficultyLevel) lesson.difficultyLevel = difficultyLevel;
    if (correct_answer) lesson.correct_answer = correct_answer;

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

    // If new images uploaded, replace existing images
    if (req.files && req.files.length > 0) {
      const uploadPromises = req.files.map((file) =>
        uploadImageToCloudinary(file.buffer)
      );
      const uploadResults = await Promise.all(uploadPromises);

      lesson.images = uploadResults.map((result, index) => ({
        image_number: index + 1,
        image_url: result.secure_url,
      }));
      // (Optional) you can store public_id and delete old images if needed.
    }

    await lesson.save();

    return res.status(200).json({ success: true, data: lesson });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete a problem solving lesson
// @route   DELETE /chromabloom/problem-solving-lessons/:id
export const deleteProblemSolvingLesson = async (req, res, next) => {
  try {
    const lesson = await ProblemSolvingLesson.findById(req.params.id);

    if (!lesson) {
      return res
        .status(404)
        .json({ success: false, message: "Lesson not found" });
    }

    await lesson.deleteOne();

    // (Optional) if you later store cloudinary public_id, you can delete images from Cloudinary here.

    return res
      .status(200)
      .json({ success: true, message: "Lesson deleted successfully" });
  } catch (err) {
    next(err);
  }
};
