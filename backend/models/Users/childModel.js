// models/child.model.js
import mongoose from "mongoose";

const childSchema = new mongoose.Schema(
  {
    _id: { type: String }, // c-0001, c-0002 ...

    // ----- Child Details -----
    childName: {
      type: String,
      trim: true,
    },

    dateOfBirth: {
      type: Date,
    },

    gender: {
      type: String,
      enum: ["Male", "Female", "Other"],
      
    },

    heightCm: {
      type: Number,
      min: 0,
    },

    weightKg: {
      type: Number,
      min: 0,
    },

    // ----- Medical Information -----
    downSyndromeType: {
      type: String,
      enum: ["Trisomy 21", "Mosaic", "Translocation", "Not Confirmed", "Other"],
      default: "Not Confirmed",
    },

    downSyndromeConfirmedBy: {
      type: String,
      trim: true,
    },

    // ----- Other Health Conditions -----
    otherHealthConditions: {
      heartIssues: { type: Boolean, default: false },
      thyroid: { type: Boolean, default: false },
      hearingProblems: { type: Boolean, default: false },
      visionProblems: { type: Boolean, default: false },
    },

    // Link to caregiver (ONE caregiver per child)
    caregiver: {
      type: String,          // "p-0001"
      ref: "Caregiver",
    },

    // Link to therapist (ONE therapist per child)
    therapist: {
      type: String,          // "t-0001"
      ref: "Therapist",      // make true if every child MUST have therapist
    },
  },
  {
    timestamps: true,
  }
);

// ===============================
// AUTO GENERATE CHILD ID: c-0001
// ===============================
childSchema.pre("save", async function (next) {
  if (this._id) return next(); // if ID already exists, skip

  const lastChild = await mongoose
    .model("Child")
    .findOne({})
    .sort({ _id: -1 })
    .lean();

  if (!lastChild) {
    this._id = "c-0001";
  } else {
    const lastNumber = parseInt(lastChild._id.split("-")[1]); // "0001" -> 1
    this._id = "c-" + String(lastNumber + 1).padStart(4, "0");
  }

  next();
});

const Child = mongoose.model("Child", childSchema);
export default Child;
