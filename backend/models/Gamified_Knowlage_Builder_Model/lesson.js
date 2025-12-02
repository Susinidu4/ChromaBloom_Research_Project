import mongoose from "mongoose";

const LessonSchema = new mongoose.Schema(
  {
    _id: { type: String }, // l-0001, l-0002...

    moduleId: {
      type: String,
      ref: "Module",
      required: true, // category: drawing or problemSolving
    },

    // ----------------------------
    // Common fields (both categories)
    // ----------------------------
    title: { type: String, required: true },
    description: { type: String, required: true },

    tips: {
      type: [String], // general tips shown in lesson
      default: [],
      required: true,
    },

    level: {
      type: String,
      enum: ["easy", "medium", "hard"],
      required: true,
    },

    // ----------------------------
    // Drawing-only fields
    // ----------------------------
    videoUrl: {
      type: String,
      default: null,
    },

    childrenDrawingUploadEnabled: {
      type: Boolean,
      default: false, // true only for drawing lessons
    },

    uploadInstruction: {
      type: String,
      default: null, // required only for drawing lessons
    },

    // optional: example image to show before upload
    sampleDrawingUrl: {
      type: String,
      default: null,
    },

    // ----------------------------
    // ProblemSolving-only fields
    // ----------------------------
    homeActivityTips: {
      type: [String],
      default: [],
    },

    gameInstructions: {
      type: String,
      default: null,
    },
  },
  { timestamps: true }
);

// =====================================================
// Conditional validation based on module category
// =====================================================
LessonSchema.pre("validate", async function (next) {
  try {
    const Module = mongoose.model("Module");
    const mod = await Module.findById(this.moduleId).lean();

    if (!mod) return next(new Error("Invalid moduleId"));

    // ---------- Drawing rules ----------
    if (mod.category === "drawing") {
      if (!this.videoUrl) {
        return next(new Error("Drawing lessons require a videoUrl."));
      }

      // upload must be enabled + instruction must exist
      if (!this.childrenDrawingUploadEnabled) {
        this.childrenDrawingUploadEnabled = true;
      }
      if (!this.uploadInstruction) {
        return next(
          new Error("Drawing lessons require uploadInstruction.")
        );
      }

      // clear problem-solving only fields
      this.homeActivityTips = [];
      this.gameInstructions = null;
    }

    // ---------- Problem solving rules ----------
    if (mod.category === "problemSolving") {
      if (!this.gameInstructions) {
        return next(
          new Error("Problem-solving lessons require gameInstructions.")
        );
      }

      if (!this.homeActivityTips || this.homeActivityTips.length === 0) {
        return next(
          new Error("Problem-solving lessons require homeActivityTips.")
        );
      }

      // clear drawing-only fields
      this.videoUrl = null;
      this.childrenDrawingUploadEnabled = false;
      this.uploadInstruction = null;
      this.sampleDrawingUrl = null;
    }

    next();
  } catch (err) {
    next(err);
  }
});

// =====================================================
// Auto-generate ID l-0001, l-0002...
// =====================================================
LessonSchema.pre("save", async function (next) {
  if (this._id) return next();

  const last = await mongoose
    .model("Lesson")
    .findOne({})
    .sort({ _id: -1 })
    .lean();

  if (!last) this._id = "l-0001";
  else {
    const num = parseInt(last._id.split("-")[1]) + 1;
    this._id = "l-" + String(num).padStart(4, "0");
  }

  next();
});

export default mongoose.model("Lesson", LessonSchema);
