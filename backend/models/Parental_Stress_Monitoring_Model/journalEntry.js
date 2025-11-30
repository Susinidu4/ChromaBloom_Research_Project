import mongoose from "mongoose";
const { Schema, model } = mongoose;

const journalEntrySchema = new Schema(
  {
    caregiver_ID: {
      type: String, //Schema.Types.ObjectId
      ref: "user",
      required: true,
    },
    mood: {
      type: String,
      enum: ["happy", "calm", "neutral", "tired", "sad", "angry", "stressed"],
      required: true,
      default: "neutral",
    },
    text: {
      type: String,
      required: true,
    },
    
    // optional NLP fields (computed server-side later)
    // sentimentScore: {
    //   type: Number, 
    //   min: -1,
    //   max: 1,
    // }, // -1..1
    // emotions: {
    //   joy: { type: Number, min: 0, max: 1 },
    //   sadness: { type: Number, min: 0, max: 1 },
    //   anger: { type: Number, min: 0, max: 1 },
    //   fear: { type: Number, min: 0, max: 1 },
    //   calm: { type: Number, min: 0, max: 1 },
    // },
  },
  {
    collection: "JournalEntry",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

const JournalEntry = model("JournalEntry", journalEntrySchema);
export default JournalEntry;
