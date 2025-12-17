import mongoose from "mongoose";

const Complete_Drawing_Lesson_Schema = new mongoose.Schema(
  {
    _id: { type: String },

    // RELATIONSHIP: Link to DrawingLesson
    lesson_id: { 
      type: String, 
      ref: "DrawingLesson", 
      required: true 
    },

    user_id: { type: String},

    correctness_rate : { type: Number, default: 0 },
  },
  { timestamps: true }
);

// Generate ID like CLD-0001
Complete_Drawing_Lesson_Schema.pre("save", async function (next) {
  if (this.isNew) {
    const last = await mongoose.model("Complete_Drawing_Lesson")
      .findOne()
      .sort({ _id: -1 });

    if (!last) {
      this._id = "CLD-0001";
    } else {
      const lastNumber = parseInt(last._id.split("-")[1]);
      this._id = "CLD-" + String(lastNumber + 1).padStart(4, "0");
    }
  }
  next();
});

const Complete_Drawing_Lesson = mongoose.model("Complete_Drawing_Lesson",Complete_Drawing_Lesson_Schema
);
export default Complete_Drawing_Lesson;
