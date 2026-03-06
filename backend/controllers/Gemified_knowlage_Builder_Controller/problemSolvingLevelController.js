import ProblemSolvingLevel from "../../models/Gamified_Knowlage_Builder_Model/Problem_Solving_Level.js";

// Create a new Problem Solving Level
export const createProblemSolvingLevel = async (req, res) => {
    try {
        const { userId, level } = req.body;
        const newLevel = new ProblemSolvingLevel({ userId, level });
        await newLevel.save();
        res.status(201).json(newLevel);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Get Problem Solving Level by User ID
export const getProblemSolvingLevelByUserId = async (req, res) => {
    try {
        const { userId } = req.params;
        const levelData = await ProblemSolvingLevel.findOne({ userId });
        if (!levelData) {
            return res.status(404).json({ message: "Level data not found for this user" });
        }
        res.status(200).json(levelData);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get all Problem Solving Levels
export const getAllProblemSolvingLevels = async (req, res) => {
    try {
        const levels = await ProblemSolvingLevel.find();
        res.status(200).json(levels);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update Problem Solving Level by Entry ID (_id)
export const updateProblemSolvingLevel = async (req, res) => {
    try {
        const { id } = req.params;
        const { level } = req.body;
        const updatedLevel = await ProblemSolvingLevel.findByIdAndUpdate(
            id,
            { level },
            { new: true }
        );
        if (!updatedLevel) {
            return res.status(404).json({ message: "Level data not found" });
        }
        res.status(200).json(updatedLevel);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Update Problem Solving Level by User ID
export const updateProblemSolvingLevelByUserId = async (req, res) => {
    try {
        const { userId } = req.params;
        const { level } = req.body;
        const updatedLevel = await ProblemSolvingLevel.findOneAndUpdate(
            { userId },
            { level },
            { new: true }
        );
        if (!updatedLevel) {
            return res.status(404).json({ message: "Level data not found for this user" });
        }
        res.status(200).json(updatedLevel);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};
