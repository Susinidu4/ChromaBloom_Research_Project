import mongoose from "mongoose";

const ModuleSchema = new mongoose.Schema(
  {
    _id: { type: String }, // m-0001, m-0002

    
    category: {
      type: String,
      enum: ["drawing", "problemSolving"],
      required: true,
      unique: true,
    },

    title: { type: String, required: true },       // "Drawing", "Problem Solving"
    description: { type: String, required: true },

    coverImageUrl: String,
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

ModuleSchema.pre("save", async function (next) {
  if (this._id) return next();
  const last = await mongoose.model("Module").findOne({}).sort({ _id: -1 }).lean();

  if (!last) this._id = "m-0001";
  else {
    const num = parseInt(last._id.split("-")[1]) + 1;
    this._id = "m-" + String(num).padStart(4, "0");
  }
  next();
});

export default mongoose.model("Module", ModuleSchema);
