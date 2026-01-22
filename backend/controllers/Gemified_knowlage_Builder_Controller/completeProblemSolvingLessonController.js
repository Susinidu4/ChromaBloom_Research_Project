import CompleteProblemSolvingSession from "../../models/Gamified_Knowlage_Builder_Model/Complete_Problem_Sloving_Session.js";

// ✅ CREATE
export const createCompleteProblemSolvingSession = async (req, res) => {
  try {
    const { childId, lessons, correctness_score } = req.body;

    if (!childId || !lessons) {
      return res.status(400).json({
        message: "childId and lessons are required",
      });
    }

    const newSession = new CompleteProblemSolvingSession({
      childId,
      lessons,
      correctness_score: correctness_score ?? 0,
    });

    const saved = await newSession.save(); // ID auto-generates (CLP-0001)
    return res.status(201).json(saved);
  } catch (err) {
    return res.status(500).json({
      message: "Failed to create complete problem solving session",
      error: err.message,
    });
  }
};

// ✅ GET BY ID
export const getCompleteProblemSolvingSessionById = async (req, res) => {
  try {
    const { id } = req.params;

    const session = await CompleteProblemSolvingSession.findById(id)
      .populate("childId")
      .populate("lessons");

    if (!session) {
      return res.status(404).json({ message: "Session not found" });
    }

    return res.status(200).json(session);
  } catch (err) {
    return res.status(500).json({
      message: "Failed to fetch session",
      error: err.message,
    });
  }
};

// ✅ GET BY CHILD + LESSON
export const getByChildAndLesson = async (req, res) => {
  try {
    const { childId, lessonId } = req.params;

    const sessions = await CompleteProblemSolvingSession.find({
      childId,
      lessons: lessonId,
    })
      .sort({ createdAt: -1 })
      .populate("childId")
      .populate("lessons");

    return res.status(200).json({
      count: sessions.length,
      data: sessions,
    });
  } catch (err) {
    return res.status(500).json({
      message: "Failed to fetch sessions by child and lesson",
      error: err.message,
    });
  }
};

// ✅ UPDATE
export const updateCompleteProblemSolvingSession = async (req, res) => {
  try {
    const { id } = req.params;

    // Only allow updating these fields (safe)
    const updateData = {};
    if (req.body.childId !== undefined) updateData.childId = req.body.childId;
    if (req.body.lessons !== undefined) updateData.lessons = req.body.lessons;
    if (req.body.correctness_score !== undefined)
      updateData.correctness_score = req.body.correctness_score;

    const updated = await CompleteProblemSolvingSession.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    )
      .populate("childId")
      .populate("lessons");

    if (!updated) {
      return res.status(404).json({ message: "Session not found" });
    }

    return res.status(200).json(updated);
  } catch (err) {
    return res.status(500).json({
      message: "Failed to update session",
      error: err.message,
    });
  }
};

// ✅ DELETE
export const deleteCompleteProblemSolvingSession = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await CompleteProblemSolvingSession.findByIdAndDelete(id);

    if (!deleted) {
      return res.status(404).json({ message: "Session not found" });
    }

    return res.status(200).json({
      message: "Session deleted successfully",
      deletedId: id,
    });
  } catch (err) {
    return res.status(500).json({
      message: "Failed to delete session",
      error: err.message,
    });
  }
};
