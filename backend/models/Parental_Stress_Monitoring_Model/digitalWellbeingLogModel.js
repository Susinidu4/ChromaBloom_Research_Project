import mongoose from "mongoose";
const { Schema, model } = mongoose;

const digitalWellbeingLogSchema = new Schema(
    {
        caregiverId: {
            type: String,
            ref: "caregiver",
            required: true,
        },

        log_date: {
            type: Date,
            required: true,
        },

        total_screen_time_min: {
            type: Number,
            required: true,
        },

        night_usage_min: {
            type: Number,
            required: true,
        },

        unlock_count:{
            type: Number,
            required: true,
        },

        app_opened_times_count:{
            type: Number,
            required: true,
        },

        social_media_min:{
            type: Number,
            required: true,
        },

        video_apps_min:{
            type: Number,
            required: true,
        },

        late_night_usage_flag:{
            type: Boolean,
            required: true,
        },

        sleep_quality: {
            type: String,
            required: true,
        },
    },
    {
        collection: "DigitalWellbeingLog",
        timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
    }
)

digitalWellbeingLogSchema.index(
  { caregiverId: 1, log_date: 1 },
  { unique: true }
);

const DigitalWellbeingLog = model("DigitalWellbeingLog", digitalWellbeingLogSchema);
export default DigitalWellbeingLog;
