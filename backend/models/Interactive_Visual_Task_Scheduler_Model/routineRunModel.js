import mongoose from "mongoose";
const { Schema } = mongoose;

const routineRunSchema = new Schema(
  {
    caregiverId: {
      type: String,
      ref: "Caregiver",
      required: true,
    },

    childId: {
      type: String,
      ref: "Child",
      required: true,
    },

    activityId: {
      type: String,    // Schema.Types.ObjectId
      ref: "userActivity",
      required: true,
    },

    planId: {
      type: String,
      required: true,
    },

    date: {
      type: Date,
      required: true,
    },

    total_steps: {
      type: Number,
      required: true,
    },

    completed_steps: {
      type: Number,
      required: true,
    },

    skipped_steps: {
      type: Number,
      required: true,
    },

    duration_minutes: {
      type: Number,
      required: true,
    },
  },
  {
    collection: "routineRun",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

const RoutineRunModel = mongoose.model("RoutineRun", routineRunSchema);
export default RoutineRunModel;
