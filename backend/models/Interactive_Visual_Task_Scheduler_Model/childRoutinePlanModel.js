import mongoose, { version } from "mongoose";
const { Schema, model } = mongoose;

const activitiesSchema = new Schema(
  {
    activityId: {
      type: Schema.Types.ObjectId,
      ref: "UserActivity",
      required: true,
    },

    order: {
      type: Number,
      required: true,
    },

  },
  { _id: false } // no separate _id for each activity (optional)
);

const childRoutinePlanSchema = new Schema(
  {
    planId: {
      type: String,
      unique: true,
    },

    caregiverId: {
      type: Schema.Types.ObjectId,
      ref: "Caregiver",
      required: true,
    },

    childId: {
      type: Schema.Types.ObjectId,
      ref: "Child",
      required: true,
    },

    current_difficulty_level: {
      type: String,
      enum: ["easy", "medium", "hard"],
      required: true,
    },

    activities: {
      type: [activitiesSchema],
    },

    cycle_start_date: {
      type: Date,
      required: true,
    },

    cycle_end_date: {
      type: Date,
      required: true,
    },

    version: {
      type: Number,
      required: true,
    },

    is_active: {
      type: Boolean,
      default: true,
    },
    
  },
  {
    collection: "childRoutinePlan",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

const ChildRoutinePlan = model("ChildRoutinePlan", childRoutinePlanSchema);
export default ChildRoutinePlan;
