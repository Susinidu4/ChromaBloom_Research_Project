// controllers/completeDrawingLesson.controller.js
import Complete_Drawing_Lesson from "../../models/Gamified_Knowlage_Builder_Model/Complete_Drawing_Lesson.js";
import DrawingLesson from "../../models/Gamified_Knowlage_Builder_Model/Drawing_Lesson.js"; // optional

// Helper: convert incoming correctness_rate to percentage
// Expects value like 0.76 -> store 76

const toPercentage = (value) => {
  if (value === undefined || value === null) return undefined;
  const num = Number(value);
  if (Number.isNaN(num)) return undefined;
  return num * 100; // 👈 you said: "multiply by 100"
};

// @desc   Create a "completed drawing lesson" record
// @route  POST /chromabloom/completed-drawing-lessons
export const createCompleteDrawingLesson = async (req, res, next) => {
  try {
    const { lesson_id, user_id, correctness_rate } = req.body;

    if (!lesson_id || !user_id) {
      return res.status(400).json({
        success: false,
        message: "lesson_id and user_id are required",
      });
    }

    const correctnessRatePercent = toPercentage(correctness_rate);

    // Optional: prevent duplicate completion for same user + lesson
    let existing = await Complete_Drawing_Lesson.findOne({ lesson_id, user_id });

    if (existing) {
      // If correctness_rate is sent again, update it (overwrite old value)
      if (correctnessRatePercent !== undefined) {
        existing.correctness_rate = correctnessRatePercent;
        await existing.save();
      }

      return res.status(200).json({
        success: true,
        message: "Lesson already marked as completed for this user",
        data: existing,
      });
    }

    const completed = await Complete_Drawing_Lesson.create({
      lesson_id,
      user_id,
      ...(correctnessRatePercent !== undefined && {
        correctness_rate: correctnessRatePercent,
      }),
    });

    return res.status(201).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// @desc   Get all completed drawing lessons
// @route  GET /chromabloom/completed-drawing-lessons
export const getAllCompleteDrawingLessons = async (req, res, next) => {
  try {
    const completed = await Complete_Drawing_Lesson.find()
      .populate("lesson_id")
      .sort({ createdAt: -1 });

    return res.status(200).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// @desc   Get one completed lesson by its _id (CLD-000x)
// @route  GET /chromabloom/completed-drawing-lessons/:id
export const getCompleteDrawingLessonById = async (req, res, next) => {
  try {
    const completed = await Complete_Drawing_Lesson.findById(req.params.id)
      .populate("lesson_id");

    if (!completed) {
      return res
        .status(404)
        .json({ success: false, message: "Completed lesson not found" });
    }

    return res.status(200).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// @desc   Get all completed lessons for a specific user
// @route  GET /chromabloom/completed-drawing-lessons/user/:userId
export const getCompleteDrawingLessonsByUserId = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const completed = await Complete_Drawing_Lesson.find({ user_id: userId })
      .populate("lesson_id")
      .sort({ createdAt: -1 });

    return res.status(200).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// @desc   Update a completed lesson record
// @route  PUT /chromabloom/completed-drawing-lessons/:id
export const updateCompleteDrawingLesson = async (req, res, next) => {
  try {
    const { lesson_id, user_id, correctness_rate } = req.body;

    const completed = await Complete_Drawing_Lesson.findById(req.params.id);
    if (!completed) {
      return res
        .status(404)
        .json({ success: false, message: "Completed lesson not found" });
    }

    if (lesson_id) completed.lesson_id = lesson_id;
    if (user_id) completed.user_id = user_id;

    const correctnessRatePercent = toPercentage(correctness_rate);
    if (correctnessRatePercent !== undefined) {
      completed.correctness_rate = correctnessRatePercent;
    }

    await completed.save();

    return res.status(200).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// @desc   Delete a completed lesson record
// @route  DELETE /chromabloom/completed-drawing-lessons/:id
export const deleteCompleteDrawingLesson = async (req, res, next) => {
  try {
    const completed = await Complete_Drawing_Lesson.findById(req.params.id);
    if (!completed) {
      return res
        .status(404)
        .json({ success: false, message: "Completed lesson not found" });
    }

    await completed.deleteOne();

    return res.status(200).json({
      success: true,
      message: "Completed lesson deleted successfully",
    });
  } catch (err) {
    next(err);
  }
};
