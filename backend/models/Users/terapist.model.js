// models/Users/terapist.model.js
import mongoose from "mongoose";
import bcrypt from "bcrypt";

const TherapistSchema = new mongoose.Schema(
  {
    _id: { type: String }, // t-0001, t-0002 ...

    full_name: { type: String, required: true },
    dob: { type: Date },
    gender: { type: String },
    email: { type: String, unique: true, required: true },
    password: { type: String, required: true },
    phone: { type: String },
    address: { type: String },
    specialization: { type: String },
    start_date: { type: String },
    licence_number: { type: String },
    work_place: { type: String },
    profile_picture: { type: String },
    terms_and_conditions: { type: Boolean, default: false },
    privacy_policy: { type: Boolean, default: false },
  },
  { timestamps: true }
);

// ===============================
//  AUTO GENERATE ID: t-0001, t-0002,...
// ===============================
TherapistSchema.pre("save", async function (next) {
  if (this._id) return next();

  const last = await mongoose
    .model("Therapist")
    .findOne({})
    .sort({ _id: -1 })
    .lean();

  if (!last) {
    this._id = "t-0001";
  } else {
    const lastNumber = parseInt(last._id.split("-")[1]);
    const newId = "t-" + String(lastNumber + 1).padStart(4, "0");
    this._id = newId;
  }

  next();
});

// ===============================
//  HASH PASSWORD BEFORE SAVE
// ===============================
TherapistSchema.pre("save", async function (next) {
  // if password not changed, skip
  if (!this.isModified("password")) return next();

  // 🔴 extra safety: if somehow password is missing, avoid bcrypt error
  if (!this.password) {
    return next(new Error("Password is required"));
  }

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

export default mongoose.model("Therapist", TherapistSchema);
