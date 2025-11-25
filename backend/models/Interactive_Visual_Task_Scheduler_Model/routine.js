import mongoose from "mongoose";
const { Schema, model } = mongoose;

const stepSchema = new Schema(
  {
    step_number: {
      type: Number,
      required: true,
    },
    instruction: {  
        type: String, 
        required: true 
    },
  }
);

const routineSchema = new Schema(
  {
    created_by: { 
        type: String,  //Schema.Types.ObjectId
        ref: "User", 
        required: true 
    }, 
    title: { 
        type: String, 
        required: true 
    },
    description: { 
        type: String, 
        required: true 
    },
    age_group: { 
        type: String, 
        enum: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
        required: true 
    },
    development_area: { 
        type: String, 
        required: true 
    },
    steps:{
      type: [stepSchema],
      validate: [
        (v) => Array.isArray(v) && v.length > 0,
        "Routine must contain at least one step",
      ],
    },
    estimated_duration: { // in minutes
        type: Number, 
        required: true 
    }, 
    difficulty_level: { 
        type: String, 
        required: true 
    },
  },
  {
    collection: "routine",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

const routine = model("Routine", routineSchema);
export default routine;