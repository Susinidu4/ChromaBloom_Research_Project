// controllers/completeProblemSolvingLesson.controller.js
import Complete_Problem_Solving_Lesson from "../../models/Gamified_Knowlage_Builder_Model/Problem_Solving_Lesson.js"; 

// Create a "completed problem solving lesson" record
// POST /chromabloom/completed-problem-solving-lessons
export const createCompleteProblemSolvingLesson = async (req, res, next) => {
  try {
    const { lesson_id, user_id } = req.body;

    if (!lesson_id || !user_id) {
      return res.status(400).json({
        success: false,
        message: "lesson_id and user_id are required",
      });
    }

    // Optional: prevent duplicate record for same user + lesson
    const existing = await Complete_Problem_Solving_Lesson.findOne({
      lesson_id,
      user_id,
    });

    if (existing) {
      return res.status(200).json({
        success: true,
        message: "Lesson already marked as completed for this user",
        data: existing,
      });
    }

    const completed = await Complete_Problem_Solving_Lesson.create({
      lesson_id,
      user_id,
    });

    return res.status(201).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// Get all completed problem solving lessons
// GET /chromabloom/completed-problem-solving-lessons
export const getAllCompleteProblemSolvingLessons = async (req, res, next) => {
  try {
    const completed = await Complete_Problem_Solving_Lesson.find()
      .populate("lesson_id") // remove if you don't want lesson details
      .sort({ createdAt: -1 });

    return res.status(200).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// Get one completed record by its _id (CLP-000x)
// GET /chromabloom/completed-problem-solving-lessons/:id
export const getCompleteProblemSolvingLessonById = async (req, res, next) => {
  try {
    const completed = await Complete_Problem_Solving_Lesson.findById(
      req.params.id
    ).populate("lesson_id");

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

// Get all completed lessons for a specific user
// GET /chromabloom/completed-problem-solving-lessons/user/:userId
export const getCompleteProblemSolvingLessonsByUserId = async (
  req,
  res,
  next
) => {
  try {
    const { userId } = req.params;

    const completed = await Complete_Problem_Solving_Lesson.find({
      user_id: userId,
    })
      .populate("lesson_id")
      .sort({ createdAt: -1 });

    return res.status(200).json({ success: true, data: completed });
  } catch (err) {
    next(err);
  }
};

// Update a completed record (change lesson_id or user_id)
// PUT /chromabloom/completed-problem-solving-lessons/:id
export const updateCompleteProblemSolvingLesson = async (req, res, next) => {
  try {
    const { lesson_id, user_id } = req.body;

    const completed = await Complete_Problem_Solving_Lesson.findById(
      req.params.id
    );

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

// Delete a completed problem solving lesson record
// DELETE /chromabloom/completed-problem-solving-lessons/:id
export const deleteCompleteProblemSolvingLesson = async (req, res, next) => {
  try {
    const completed = await Complete_Problem_Solving_Lesson.findById(
      req.params.id
    );

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
