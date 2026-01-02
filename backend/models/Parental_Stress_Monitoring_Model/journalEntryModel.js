import mongoose from "mongoose";
const { Schema, model } = mongoose;

const journalEntrySchema = new Schema(
  {
    caregiver_ID: {
      type: String,
      ref: "caregiver",
      required: true,
    },

    mood: {
      type: String,
      enum: ["happy", "calm", "neutral", "tired", "sad", "angry", "stressed"],
      required: true,
      default: "neutral",
    },

    moodEmoji: {
      type: String,
      enum: ["😃", "😌", "🙂", "🥱", "😢", "😡", "😖"],
      required: true,
    },

    text: {
      type: String,
      required: true,
    },

    journal_sentiment: {
      type: Number,
      default: 0,
    },
  },
  {
    collection: "JournalEntry",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

const JournalEntry = model("JournalEntry", journalEntrySchema);
export default JournalEntry;
