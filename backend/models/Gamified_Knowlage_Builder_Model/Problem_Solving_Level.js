import mongoose from "mongoose";

const problemSolvingLevelSchema = new mongoose.Schema({
    _id: { type: String },
    userId: { type: String },
    level: { type: String }
});


// Generate ID like PL-0001
problemSolvingLevelSchema.pre('save', async function (next) {
    if (this.isNew) {
        const lastLesson = await mongoose.model('ProblemSolvingLevel').findOne().sort({ _id: -1 });
        if (!lastLesson) {
            this._id = 'PL-0001';
        } else {
            const lastNumber = parseInt(lastLesson._id.split('-')[1]);
            this._id = 'PL-' + String(lastNumber + 1).padStart(4, '0');
        }
    }
    next();
});


const ProblemSolvingLevel = mongoose.model("ProblemSolvingLevel", problemSolvingLevelSchema);

export default ProblemSolvingLevel;