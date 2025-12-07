import mongoose from "mongoose";

const Complete_Problem_Solving_Lesson_Schema = new mongoose.Schema(
  {
    _id: { type: String },

    // RELATIONSHIP: which lesson was completed
    lesson_id: {
      type: String,
      ref: "ProblemSolvingLesson",  
      required: true,
    },

    user_id: {type: String},
  },
  { timestamps: true }
);

// pass unique id to _id like CLP-0001
Complete_Problem_Solving_Lesson_Schema.pre("save", async function (next) {
  if (this.isNew) {
    const lastLesson = await mongoose
      .model("Complete_Problem_Solving_Lesson")
      .findOne()
      .sort({ _id: -1 });

    if (!lastLesson) {
      this._id = "CLP-0001";
    } else {
      const lastNumber = parseInt(lastLesson._id.split("-")[1]);
      this._id = "CLP-" + String(lastNumber + 1).padStart(4, "0");
    }
  }
  next();
});

const Complete_Problem_Solving_Lesson = mongoose.model("Complete_Problem_Solving_Lesson",Complete_Problem_Solving_Lesson_Schema);
export default Complete_Problem_Solving_Lesson;
