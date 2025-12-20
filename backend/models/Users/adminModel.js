import mongoose from "mongoose";
import bcrypt from "bcrypt";

const AdminSchema = new mongoose.Schema(
  {
    _id: { type: String }, // a-0001, a-0002 ...
    full_name: { type: String, required: true, trim: true },
    email: { type: String, unique: true, required: true, lowercase: true, trim: true },
    password: { type: String, required: true },
  },
  { timestamps: true }
);


//  AUTO GENERATE ID: a-0001, a-0002,...

AdminSchema.pre("save", async function (next) {
  try {
    if (this._id) return next();

    const last = await mongoose
      .model("Admin")
      .findOne({})
      .sort({ _id: -1 })
      .lean();

    if (!last) this._id = "a-0001";
    else {
      const lastNumber = parseInt(last._id.split("-")[1], 10);
      this._id = "a-" + String(lastNumber + 1).padStart(4, "0");
    }

    next();
  } catch (err) {
    next(err);
  }
});


//  HASH PASSWORD BEFORE SAVE
AdminSchema.pre("save", async function (next) {
  try {
    if (!this.isModified("password")) return next();

    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);

    next();
  } catch (err) {
    next(err);
  }
});

export default mongoose.model("Admin", AdminSchema);
