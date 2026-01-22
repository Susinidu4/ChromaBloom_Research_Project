import mongoose from "mongoose";


const CompleteProblemSolvingSessionSchema = new mongoose.Schema(
  {
    _id: { type: String }, // CLP-0001

    childId: {type: String , ref: 'Child'},

    lessons: { type: String , ref: 'ProblemSolvingLesson'},

    correctness_score: {type: Number, default: 0,},
  },
  { timestamps: true }
);

/* AUTO GENERATE ID (CLP-0001)*/
CompleteProblemSolvingSessionSchema.pre("save", async function (next) {
  if (this.isNew) {
    const last = await mongoose
      .model("CompleteProblemSolvingSession")
      .findOne()
      .sort({ _id: -1 });

    if (!last) {
      this._id = "CLP-0001";
    } else {
      const lastNumber = parseInt(last._id.split("-")[1]);
      this._id = "CLP-" + String(lastNumber + 1).padStart(4, "0");
    }
  }
  next();
});

const CompleteProblemSolvingSession = mongoose.model(
  "CompleteProblemSolvingSession",
  CompleteProblemSolvingSessionSchema
);

export default CompleteProblemSolvingSession;
