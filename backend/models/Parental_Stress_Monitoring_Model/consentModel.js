import mongoose from "mongoose";
const { Schema, model } = mongoose;

const consentSchema = new Schema(
  {
    caregiverId: {
      type: String,
      ref: "caregiver",
      required: true,
    },

    digital_wellbeing_consent: {
      type: Boolean,
      required: true,
      default: false,
    },

    granted_at: {
      type: Date,
      default: Date.now,
    },

    revoked_at: {
      type: Date,
      default: null,
    },

    is_active: {
      type: Boolean,
      required: true,
      default: true,
    },
  },
  {
    collection: "Consent",
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

const ConsentModel = model("Consent", consentSchema);
export default ConsentModel;
