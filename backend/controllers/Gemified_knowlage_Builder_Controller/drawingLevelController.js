import Drawing_Level from "../../models/Gamified_Knowlage_Builder_Model/Drawing_level.js";

export const createDrawingLevel = async (req, res) => {
    try {
        const { user_id, level } = req.body;

        if (!user_id || !level) {
            return res.status(400).json({ message: "User ID and level are required" });
        }

        const newDrawingLevel = new Drawing_Level({
            user_id,
            level,
        });

        const savedLevel = await newDrawingLevel.save();
        res.status(201).json(savedLevel);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

//Update a drawing level
// @route   PUT /api/drawing-levels/update/:id
export const updateDrawingLevel = async (req, res) => {
    try {
        const { id } = req.params;
        const { level } = req.body;

        const updatedLevel = await Drawing_Level.findByIdAndUpdate(
            id,
            { level },
            { new: true, runValidators: true }
        );

        if (!updatedLevel) {
            return res.status(404).json({ message: "Drawing level not found" });
        }

        res.status(200).json(updatedLevel);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get drawing level by user ID
// @route   GET /api/drawing-levels/user/:userId
export const getDrawingLevelByUserId = async (req, res) => {
    try {
        const { userId } = req.params;
        const drawingLevels = await Drawing_Level.find({ user_id: userId });

        if (!drawingLevels || drawingLevels.length === 0) {
            return res.status(404).json({ message: "No drawing levels found for this user" });
        }

        res.status(200).json(drawingLevels);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update a drawing level by user ID
// @route   PUT /api/drawing-levels/user/update/:userId
export const updateDrawingLevelByUserId = async (req, res) => {
    try {
        const { userId } = req.params;
        const { level } = req.body;

        const updatedLevel = await Drawing_Level.findOneAndUpdate(
            { user_id: userId },
            { level },
            { new: true, runValidators: true }
        );

        if (!updatedLevel) {
            return res.status(404).json({ message: "Drawing level not found for this user" });
        }

        res.status(200).json(updatedLevel);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
