// controllers/problemSolvingLesson.controller.js
import ProblemSolvingLesson from "../../models/Gamified_Knowlage_Builder_Model/Problem_Solving_Lesson.js";

// @desc    Create a problem solving lesson
// @route   POST /chromabloom/problem-solving-lessons
export const createProblemSolvingLesson = async (req, res, next) => {
  try {
    const { title, description, difficulty_level, miniTutorialsName, miniTutorials } = req.body;

    if (!title || !description) {
      return res.status(400).json({
        success: false,
        message: "title and description are required",
      });
    }

    // miniTutorials can come as array OR JSON string
    let parsedMiniTutorials = [];
    if (miniTutorials) {
      try {
        parsedMiniTutorials =
          typeof miniTutorials === "string"
            ? JSON.parse(miniTutorials)
            : miniTutorials;

        // optional: validate each item
        if (!Array.isArray(parsedMiniTutorials)) {
          return res.status(400).json({
            success: false,
            message: "miniTutorials must be an array",
          });
        }
      } catch (e) {
        return res.status(400).json({
          success: false,
          message: "Invalid miniTutorials format. Send as JSON array.",
        });
      }
    }

    const lesson = await ProblemSolvingLesson.create({
      title,
      description,
      difficulty_level,
      miniTutorialsName,
      miniTutorials: parsedMiniTutorials,
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

// @desc    Get a single lesson by ID (LP-0001)
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

// @desc    Update a problem solving lesson
// @route   PUT /chromabloom/problem-solving-lessons/:id
export const updateProblemSolvingLesson = async (req, res, next) => {
  try {
    const { title, description, difficulty_level, miniTutorialsName, miniTutorials } = req.body;

    const lesson = await ProblemSolvingLesson.findById(req.params.id);
    if (!lesson) {
      return res
        .status(404)
        .json({ success: false, message: "Lesson not found" });
    }

    if (title !== undefined) lesson.title = title;
    if (description !== undefined) lesson.description = description;
    if (difficulty_level !== undefined) lesson.difficulty_level = difficulty_level;
    if (miniTutorialsName !== undefined) lesson.miniTutorialsName = miniTutorialsName;

    if (miniTutorials !== undefined) {
      try {
        const parsedMiniTutorials =
          typeof miniTutorials === "string"
            ? JSON.parse(miniTutorials)
            : miniTutorials;

        if (!Array.isArray(parsedMiniTutorials)) {
          return res.status(400).json({
            success: false,
            message: "miniTutorials must be an array",
          });
        }

        lesson.miniTutorials = parsedMiniTutorials;
      } catch (e) {
        return res.status(400).json({
          success: false,
          message: "Invalid miniTutorials format. Send as JSON array.",
        });
      }
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
    return res
      .status(200)
      .json({ success: true, message: "Lesson deleted successfully" });
  } catch (err) {
    next(err);
  }
};