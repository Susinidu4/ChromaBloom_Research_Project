import mongoose from "mongoose";

const factorSchema = new mongoose.Schema({
  feature: String,
  shap_value: Number,
},
{ _id: false });

const CognitiveProgressSchema = new mongoose.Schema(
  {
    _id: { type: String },
    userId: { type: String },
    progress_prediction: { type: Number },
    positive_factors: [factorSchema],
    negative_factors: [factorSchema],
  },
  { timestamps: true }
);

// ✅ Auto-generate ID like pp-0001
CognitiveProgressSchema.pre("save", async function (next) {
  if (this._id) return next();
  if (!this.isNew) return next();

  const last = await mongoose
    .model("CognitiveProgress")
    .findOne({})
    .sort({ _id: -1 })
    .lean();

  if (!last) {
    this._id = "pp-0001";
  } else {
    const lastNumber = parseInt(last._id.split("-")[1], 10);
    this._id = "pp-" + String(lastNumber + 1).padStart(4, "0");
  }

  next();
});

const CognitiveProgress = mongoose.model("CognitiveProgress", CognitiveProgressSchema);
export default CognitiveProgress;
