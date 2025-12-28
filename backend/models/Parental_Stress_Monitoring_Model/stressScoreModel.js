import mongoose from "mongoose";
const { Schema, model } = mongoose;

const stressScoreSchema = new Schema(
    {
        caregiverId: {
            type: String,
            ref: "caregiver",
            required: true,
        },
        score_date: {
            type: Date,
            required: true,
        },
        computed_at: {
            type: Date,
            required: true,
        },
        stress_level: {
            type: String,
            enum: ["low", "moderate", "high"],
            required: true,
        },
        stress_probability: {
            type: Number,
            required: true,
        },
        consecutive_high_days:{
            type: Number,
            required: true,
        },
        escalation_triggered:{
            type: Boolean,
            required: true,
        },
    },
    {
        collection: "StressScore",
        timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
   }
)

const StressScoreModel = model("StressScore", stressScoreSchema);
export default StressScoreModel;