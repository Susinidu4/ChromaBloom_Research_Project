// controllers/completeDrawingLesson.controller.js
import Complete_Drawing_Lesson from "../../models/Gamified_Knowlage_Builder_Model/Complete_Drawing_Lesson.js"; // adjust path

import DrawingLesson from "../../models/Gamified_Knowlage_Builder_Model/Drawing_Lesson.js"; // not strictly required but nice to have

// @desc   Create a "completed drawing lesson" record
// @route  POST /chromabloom/completed-drawing-lessons
export const createCompleteDrawingLesson = async (req, res, next) => {
  try {
    const { lesson_id, user_id } = req.body;

    if (!lesson_id || !user_id) {
      return res.status(400).json({
        success: false,
        message: "lesson_id and user_id are required",
      });
    }

    // Optional: prevent duplicate completion for same user + lesson
    const existing = await Complete_Drawing_Lesson.findOne({ lesson_id, user_id });
    if (existing) {
      return res.status(200).json({
        success: true,
        message: "Lesson already marked as completed for this user",
        data: existing,
      });
    }

    const completed = await Complete_Drawing_Lesson.create({
      lesson_id,
      user_id,
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
      .populate("lesson_id") // remove if you don't want full lesson data
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

// @desc   Update a completed lesson record (e.g., change lesson_id or user_id)
// @route  PUT /chromabloom/completed-drawing-lessons/:id
export const updateCompleteDrawingLesson = async (req, res, next) => {
  try {
    const { lesson_id, user_id } = req.body;

    const completed = await Complete_Drawing_Lesson.findById(req.params.id);
    if (!completed) {
      return res
        .status(404)
        .json({ success: false, message: "Completed lesson not found" });
    }

    if (lesson_id) completed.lesson_id = lesson_id;
    if (user_id) completed.user_id = user_id;

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
