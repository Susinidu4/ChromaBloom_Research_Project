// models/caregiver.model.js
import mongoose from "mongoose";
import bcrypt from "bcrypt";

const CaregiverSchema = new mongoose.Schema(
  {
    _id: { type: String }, // p-0001, p-0002 ...

    full_name: { type: String, },
    dob: { type: Date },
    gender: { type: String },

    email: { type: String, unique: true,},
    password: { type: String, required: true },

    phone: { type: String },
    address: { type: String },

    // number of children (can be updated when you add/remove children)
    child_count: { type: Number, default: 0 },
  },
  { timestamps: true }
);

// ===============================
//  AUTO GENERATE ID: p-0001, p-0002,...
// ===============================
CaregiverSchema.pre("save", async function (next) {
  if (this._id) return next();

  const last = await mongoose
    .model("Caregiver")
    .findOne({})
    .sort({ _id: -1 })
    .lean();

  if (!last) {
    this._id = "p-0001";
  } else {
    const lastNumber = parseInt(last._id.split("-")[1]); // "0001" -> 1
    this._id = "p-" + String(lastNumber + 1).padStart(4, "0");
  }

  next();
});

// ===============================
//  HASH PASSWORD BEFORE SAVE
// ===============================
CaregiverSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);

  next();
});

const Caregiver = mongoose.model("Caregiver", CaregiverSchema);
export default Caregiver;
