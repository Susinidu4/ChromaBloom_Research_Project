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

const userActivitySchema = new Schema(
  {
    
    user_activityId: {     // Auto-increment number: 1,2,3
      type: Number,
      unique: true,
    },

    created_by: {
      type: String,  // later you can change to Schema.Types.ObjectId
      ref: "User",
      required: true,
    },

    scheduled_date: {
      type: Date,
      required:true,
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
    
    estimated_duration_minutes: { // in minutes
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
    collection: "UserActivity",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

// AUTO-GENERATE user_activityId BEFORE SAVING
userActivitySchema.pre("save", async function (next) {

  // If already present (manual seed), skip
  if (this.user_activityId) return next();

  const last = await this.constructor
    .findOne()
    .sort({ user_activityId: -1 })
    .lean();

  const nextId = last && last.user_activityId ? last.user_activityId + 1 : 1;

  this.user_activityId = nextId;
  next();
});

const UserActivity = model("UserActivity", userActivitySchema);
export default UserActivity;