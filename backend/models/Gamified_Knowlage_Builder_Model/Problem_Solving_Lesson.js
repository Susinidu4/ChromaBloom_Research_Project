import mongoose from 'mongoose';

const MiniTutorialSchema = new mongoose.Schema({
    tip_number: {type: Number, required: true},
    tip_content: {type: String, required: true},
});


const ProblemSolvingLessonSchema = new mongoose.Schema({
    _id: {type: String},
    title: {type: String, required: true},
    description: {type: String, required: true},
    difficulty_level: {type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], required: true},
    miniTutorialsName: {type: String},
    miniTutorials: [MiniTutorialSchema],
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