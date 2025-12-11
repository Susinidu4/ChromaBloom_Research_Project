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
  },
  { _id: false} // no separate _id for each step (optional)
);

const systemActivitySchema = new Schema(
  {
    system_activityId: { // Auto-increment number: 1,2,3
      type: String,
      unique: true,
    },

    title: {
      type: String,
      required: true,
    },

    description: {
      type: String,
      required: true,
    },

    age_group: {
      type: String,
      enum: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
      required: true,
    },

    development_area: {
      type: String,
      enum: ["self-care", "motor", "language", "cognitive", "social", "emotional"],
      required: true,
    },

    steps: {
      type: [stepSchema],
      validate: [
        (v) => Array.isArray(v) && v.length > 0,
        "Routine must contain at least one step",
      ],
    },

    estimated_duration_minutes: {
      // in minutes
      type: Number,
      required: true,
    },

    difficulty_level: {
      type: String,
      enum: ["easy", "medium", "hard"],
      required: true,
    },

    media_links: [
      {
        type: String,
      },
    ],
  },
  {
    collection: "SystemActivity",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

// AUTO-GENERATE system_activityId: S001, S002
systemActivitySchema.pre("save", async function (next) {
  if (this.system_activityId) return next();

  const lastActivity = await this.constructor
    .findOne()
    .sort({ system_activityId: -1 })
    .lean();

  let nextNumber = 1;

  if (lastActivity && lastActivity.system_activityId) {
    // Extract number from "A-001"
    const lastNumber = parseInt(lastActivity.system_activityId.substring(3));
    nextNumber = lastNumber + 1;
  }

  // Format with zero padding: S001, S002, S010, S100
  this.system_activityId = `SA-${String(nextNumber).padStart(3, "0")}`;

  next();
});

const SystemActivity = model("SystemActivity", systemActivitySchema);
export default SystemActivity;
