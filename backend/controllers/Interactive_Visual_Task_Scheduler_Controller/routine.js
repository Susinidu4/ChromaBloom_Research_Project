import Routine from "../../models/Interactive_Visual_Task_Scheduler_Model/routine.js";
import cloudinary from "../../config/cloudinary.js";

// Controller to create a new routine
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
      difficulty_level,
    } = req.body;

    // steps comes as TEXT in form-data → parse JSON
    const parsedSteps =
      typeof steps === "string" ? JSON.parse(steps) : steps;

    if (!parsedSteps || parsedSteps.length === 0) {
      return res
        .status(400)
        .json({ error: "Routine must contain at least one step" });
    }

    // ✅ image comes from multer
    if (!req.file) {
      return res
        .status(400)
        .json({ error: "Image file (routine_image) is required" });
    }

    // convert buffer -> base64 data URI for Cloudinary
    const base64Image = `data:${req.file.mimetype};base64,${req.file.buffer.toString(
      "base64"
    )}`;

    // Upload image to Cloudinary
    const uploadResult = await cloudinary.uploader.upload(base64Image, {
      folder: "chromabloom/routines",
      // transformation: [{ width: 800, height: 800, crop: "limit" }],
    });

    const imageUrl = uploadResult.secure_url; // ✅ store in MongoDB

    const routine = await Routine.create({
      created_by,
      title,
      description,
      image: imageUrl,
      age_group,
      development_area,
      steps: parsedSteps,
      estimated_duration,
      difficulty_level,
    });

    return res.status(201).json({
      message: "Routine created successfully",
      data: routine,
    });
  } catch (error) {
    console.error("Create routine error:", error);
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};


// Controller to get routines by creator
export const getRoutineByCreator = async (req, res) => {
  try {
    const { created_by } = req.params;

    // Validate creator ID
    if (!created_by) {
      return res.status(400).json({ error: "Creator ID is required" });
    }

    const routines = await Routine.find({ created_by });

    return res.status(200).json({
      message: "Routines fetched successfully",
      data: routines,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Controller to get routine by ID
export const getRoutineById = async (req, res) => {
    try{
        const { routineId } = req.params;

        if(!routineId){
            return res.status(400).json({ error: "Routine ID is required" });
        }

        const routine = await Routine.findById(routineId);

        if(!routine){
            return res.status(404).json({ error: "Routine not found" });
        }

        return res.status(200).json({
            message: "Routine fetched successfully",
            data: routine,
        });
    } catch(error){
        return res.status(500).json({
            message: "Internal server error",
            error: error.message,
        })
    }
}

// Controller to update a routine
export const updateRoutine = async (req, res) => {
  try {
    const { routineId } = req.params;
    const updateRoutineData = req.body;

    // Ensure steps is not empty
    if (updateRoutineData.steps && updateRoutineData.steps.length === 0) {
      return res
        .status(400)
        .json({ error: "Routine must contain at least one step" });
    }

    const updatedRoutine = await Routine.findByIdAndUpdate(
      routineId,
      updateRoutineData,
      {
        new: true, // return updated document
        runValidators: true, // validate updates with schema
      }
    );

    if (!updatedRoutine) {
      return res.status(404).json({ error: "Routine not found" });
    }

    return res.status(200).json({
      message: "Routine updated successfully",
      data: updatedRoutine,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Controller to delete a routine
export const deleteRoutine = async (req, res) => {
  try {
    const { routineId } = req.params;

    const deletedRoutine = await Routine.findByIdAndDelete(routineId);

    if (!deletedRoutine) {
      return res.status(404).json({ error: "Routine not found" });
    }

    return res.status(200).json({
      message: "Routine deleted successfully",
      data: deletedRoutine,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};
