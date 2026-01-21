import mongoose from "mongoose";

const ImageSchema = new mongoose.Schema({
    image_no: {type: Number},
    img_url: {type: String},
}, 
{_id: false}
);
const QuizeSchema = new mongoose.Schema({
    
    _id :{type: String},
    question: {type: String},
    lesson_id: {type: String, ref: "ProblemSolvingLesson"},
    name_tag: {type: String},
    difficulty_level: {type: String, enum: ['Beginner', 'Intermediate', 'Advanced']},
    correct_img_url: {type: String},
    correct_answer: {type: Number},
    answers: [ImageSchema]

});

//pass unique id to _id field like QZ-0001
QuizeSchema.pre('save', async function (next) {
    if (this.isNew) {
      const lastQuize = await mongoose.model('Quize').findOne().sort({_id: -1});
      if (!lastQuize) {
        this._id = 'QZ-0001';
      } else {
        const lastNumber = parseInt(lastQuize._id.split('-')[1]);
        this._id = 'QZ-' + String(lastNumber + 1).padStart(4, '0');
      }
    }
    next();
  });

const Quize = mongoose.model("Quize", QuizeSchema);
export default Quize;