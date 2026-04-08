import mongoose from 'mongoose';

const TipsSchema = new mongoose.Schema({
  tip_number: { type: Number, required: true },
  tip: { type: String, required: true },
});

const DrawingLessonSchema = new mongoose.Schema({
  _id: { type: String },
  title: { type: String, required: true },
  description: { type: String, required: true },
  video_url: { type: String, required: true },
  video_public_id: { type: String, required: true },
  difficulty_level: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], required: true },
  tips: [TipsSchema],
}, { timestamps: true }
);

//pass unique id to _id field like LD-0001

DrawingLessonSchema.pre('save', async function (next) {
  if (this.isNew) {
    const lastLesson = await mongoose.model('DrawingLesson').findOne().sort({ _id: -1 });
    if (!lastLesson) {
      this._id = 'LD-0001';
    } else {
      const lastNumber = parseInt(lastLesson._id.split('-')[1]);
      this._id = 'LD-' + String(lastNumber + 1).padStart(4, '0');
    }
  }
  next();
});

const DrawingLesson = mongoose.model('DrawingLesson', DrawingLessonSchema);
export default DrawingLesson;

