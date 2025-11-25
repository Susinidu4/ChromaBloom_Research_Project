import mongoose from "mongoose";
import bcrypt from "bcrypt";

const ParentSchema = new mongoose.Schema(
  {
    _id: { type: String }, // p-0001, p-0002 ...
    full_name: { type: String, required: true },
    dob: { type: Date },
    gender: { type: String },
    email: { type: String, unique: true, required: true },
    password: { type: String, required: true },
    phone: { type: String },
    address: { type: String },
    child_count: { type: Number, default: 0 },
  },
  { timestamps: true }
);

// ===============================
//  AUTO GENERATE ID: p-0001, p-0002,...
// ===============================
ParentSchema.pre("save", async function (next) {
  if (this._id) return next();

  const last = await mongoose
    .model("Parent")
    .findOne({})
    .sort({ _id: -1 })
    .lean();

  if (!last) {
    this._id = "p-0001";
  } else {
    const lastNumber = parseInt(last._id.split("-")[1]);
    this._id = "p-" + String(lastNumber + 1).padStart(4, "0");
  }

  next();
});

// ===============================
//  HASH PASSWORD BEFORE SAVE
// ===============================
ParentSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);

  next();
});

export default mongoose.model("Parent", ParentSchema);
