import mongoose from "mongoose";
const { Schema, model } = mongoose;

const activitiesSchema = new Schema(
  {
    activityId: {
      type: Schema.Types.ObjectId,
      ref: "SystemActivity",
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
      type: String,
      ref: "caregivers",
      required: true,
    },

    childId: {
      type: String,
      ref: "children",
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

childRoutinePlanSchema.pre("save", async function (next) {
  // If planId already exists (manual insert), skip
  if (this.planId) return next();

  const lastPlan = await this.constructor
    .findOne()
    .sort({ created_at: -1 })
    .lean();

  let lastNumber = 0;

  if (lastPlan?.planId) {
    const match = lastPlan.planId.match(/\d+/);
    if (match) {
      lastNumber = parseInt(match[0], 10);
    }
  }

  const nextNumber = lastNumber + 1;
  this.planId = `AP-${String(nextNumber).padStart(3, "0")}`;

  next();
});

const ChildRoutinePlan = model("ChildRoutinePlan", childRoutinePlanSchema);
export default ChildRoutinePlan;
