import mongoose from "mongoose";
const { Schema } = mongoose;

const stepProgressSchema = new Schema(
  {
    step_number: {
      type: Number,
      required: true,
    },

    status: {
      type: Boolean,
      default: false,
      required: true,
    },
    
  },
  { _id: false } // no separate _id for each step progress
);

const routineRunSchema = new Schema(
  {
    caregiverId: {
      type: String,
      ref: "caregivers",
      required: true,
    },

    childId: {
      type: String,
      ref: "children",
      required: true,
    },

    activityId: {
      type: Schema.Types.ObjectId,
      ref: "SystemActivity",
      required: true,
    },

    planId: {
      type: Schema.Types.ObjectId,
      ref: "childRoutinePlan",
      required: true,
    },

    steps_progress:{
      type: [stepProgressSchema],
    },

    // date: {
    //   type: Date,
    //   required: true,
    // },

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

    completed_duration_minutes: {
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
