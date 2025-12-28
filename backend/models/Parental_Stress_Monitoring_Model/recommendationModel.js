import mongoose from "mongoose";
const { Schema, model } = mongoose;

const stepSchema = new Schema({
  step_number: {
    type: Number,
    required: true,
  },
  instruction: {
    type: String,
    required: true,
  },
});
const recommendationSchema = new Schema(
  {
    recommendationId: {
      type: String,
      unique: true,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    level: {
      type: String,
      enum: ["low", "medium", "high", "critical"],
      required: true,
    },
    category: {
      type: String,
      enum: [
        "calm reset",
        "positivity",
        "hydration",
        "routine ease",
        "connection",
        "self kindness",
        "digital break",
        "fresh air",
        "support seeking",
        "grounding",
        "movement",
        "sensory soothing",
        "emotional awareness",
        "communication",
        "de-escalation",
        "safety",
        "mini gratitude",
        "eye care",
        "emotional safety",
        "restorative",
        "rest",
      ],
      required: true,
    },

    duration: {
      type: Number,
      required: true,
    },

    steps: {
      type: [stepSchema],
      required: true,
    },

    source: {
      type: String,
      required: true,
    },

    is_active: {
      type: Boolean,
      required: true,
      default: true,
    },
  },
  {
    collection: "Recommendation",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

/* ---------------- AUTO ID GENERATION ---------------- */
recommendationSchema.pre("save", async function (next) {
  if (!this.isNew) return next();

  const lastRec = await mongoose
    .model("Recommendation")
    .findOne({}, { recommendationId: 1 })
    .sort({ recommendationId: -1 })
    .lean();

  if (!lastRec || !lastRec.recommendationId) {
    this.recommendationId = "REC-0001";
  } else {
    const lastNumber = parseInt(lastRec.recommendationId.split("-")[1], 10);
    const nextNumber = lastNumber + 1;
    this.recommendationId = "REC-" + String(nextNumber).padStart(4, "0");
  }

  next();
});

const RecommendationModel = model("Recommendation", recommendationSchema);
export default RecommendationModel;
