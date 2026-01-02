import CompleteProblemSolvingSession from "../../models/Gamified_Knowlage_Builder_Model/Complete_Problem_Sloving_Session.js";

// ✅ CREATE
export const createCompleteProblemSolvingSession = async (req, res, next) => {
  try {
    const { user_id, lessons, correctness_score } = req.body;

    if (!user_id) {
      return res.status(400).json({ status: "error", message: "user_id is required" });
    }

    if (!Array.isArray(lessons) || lessons.length === 0) {
      return res.status(400).json({ status: "error", message: "lessons must be a non-empty array" });
    }

    // validate each lesson has lesson_id
    const invalidLesson = lessons.find((l) => !l?.lesson_id);
    if (invalidLesson) {
      return res.status(400).json({
        status: "error",
        message: "Each lesson must contain lesson_id",
      });
    }

    const session = await CompleteProblemSolvingSession.create({
      user_id,
      lessons,
      correctness_score: typeof correctness_score === "number" ? correctness_score : 0,
    });

    return res.status(201).json({
      status: "success",
      message: "Complete Problem Solving Session created",
      data: session,
    });
  } catch (err) {
    next(err);
  }
};

// ✅ VIEW ALL
export const getAllCompleteProblemSolvingSessions = async (req, res, next) => {
  try {
    const sessions = await CompleteProblemSolvingSession.find().sort({ createdAt: -1 });

    return res.status(200).json({
      status: "success",
      count: sessions.length,
      data: sessions,
    });
  } catch (err) {
    next(err);
  }
};

// ✅ VIEW BY USER ID
export const getCompleteProblemSolvingSessionsByUserId = async (req, res, next) => {
  try {
    const { user_id } = req.params;

    const sessions = await CompleteProblemSolvingSession.find({ user_id }).sort({ createdAt: -1 });

    return res.status(200).json({
      status: "success",
      user_id,
      count: sessions.length,
      data: sessions,
    });
  } catch (err) {
    next(err);
  }
};

// ✅ DELETE (by CLP-0001)
export const deleteCompleteProblemSolvingSession = async (req, res, next) => {
  try {
    const { id } = req.params; // CLP-0001

    const deleted = await CompleteProblemSolvingSession.findByIdAndDelete(id);

    if (!deleted) {
      return res.status(404).json({
        status: "error",
        message: `Session not found: ${id}`,
      });
    }

    return res.status(200).json({
      status: "success",
      message: "Session deleted successfully",
      data: deleted,
    });
  } catch (err) {
    next(err);
  }
};
