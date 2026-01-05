import mongoose from 'mongoose';

const TipsSchema = new mongoose.Schema({
    tip_number: {type: Number, required: true},
    tip_content: {type: String, required: true},
});

const ImageSchema = new mongoose.Schema({
    image_number: {type: Number, required: true},
    image_url: {type: String, required: true},
});

const ProblemSolvingLessonSchema = new mongoose.Schema({
    _id: {type: String},
    title: {type: String, required: true},
    content: {type: String},
    difficultyLevel: {type: String, enum: ['Easy', 'Medium', 'Hard'], required: true},
    tips: [TipsSchema],
    correct_answer: {type: String, required: true},
    images: [ImageSchema],
    catergory: {type: String , enum: [
        'match the similar objects',
        'spot the difference',
        'sorting by category',
        'what happen next',
        'find the missing piece'
    ]},
}, {timestamps: true});
    
//pass unique id to _id field like LP-0001

ProblemSolvingLessonSchema.pre('save', async function (next) {
    if (this.isNew) {
        const lastLesson = await mongoose.model('ProblemSolvingLesson').findOne().sort({_id: -1});
        if (!lastLesson) {
            this._id = 'LP-0001';
        } else {
            const lastNumber = parseInt(lastLesson._id.split('-')[1]);
            this._id = 'LP-' + String(lastNumber + 1).padStart(4, '0');
        }
    }
    next();
});

const ProblemSolvingLesson = mongoose.model('ProblemSolvingLesson', ProblemSolvingLessonSchema);
export default ProblemSolvingLesson;