import mongoose from "mongoose";

const Drawing_Level_Schema = new mongoose.Schema(
  {
    _id: { type: String },
    user_id: { type: String },
    level: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'] },
  },
  { timestamps: true }
);

// Generate ID like DL-0001
Drawing_Level_Schema.pre('save', async function (next) {
  if (this.isNew) {
    const lastLesson = await mongoose.model('Drawing_Level').findOne().sort({ _id: -1 });
    if (!lastLesson) {
      this._id = 'DL-0001';
    } else {
      const lastNumber = parseInt(lastLesson._id.split('-')[1]);
      this._id = 'DL-' + String(lastNumber + 1).padStart(4, '0');
    }
  }
  next();
});

const Drawing_Level = mongoose.model("Drawing_Level", Drawing_Level_Schema);
export default Drawing_Level;
