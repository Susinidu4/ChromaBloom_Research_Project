import Routine from "../../models/Interactive_Visual_Task_Scheduler_Model/routine.js";

export const createRoutine = async (req, res) => {
    try {
        const {
            created_by,
            title,
            description,
            age_group,
            development_area,
            steps,
            estimated_duration,
            difficulty_level
        } = req.body;

        if (!steps || steps.length === 0){
            return res.status(400).json({ error: "Routine must contain at least one step" });
        }

        const routine = await Routine.create({
            created_by,
            title,
            description,
            age_group,
            development_area,
            steps,
            estimated_duration,
            difficulty_level
        });

        return res.status(201).json({
            message: "Routine created successfully",
            data: routine,
        });
    } catch (error) {
        console.error("Error creating routine:", error);
        return res.status(500).json({
            message: "Internal server error",
            error: error.message,
        });
    }
};