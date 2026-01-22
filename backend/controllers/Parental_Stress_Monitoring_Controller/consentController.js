import ConsentModel from "../../models/Parental_Stress_Monitoring_Model/consentModel.js";

// ------------------------- Caregiver -------------------------- //
// Get consent records by caregiverId
export const getConsentByCaregiver = async (req, res) => {
  try {
    const { caregiverId } = req.params;
    if (!caregiverId) return res.status(400).json({ message: "caregiverId required" });

    const consent = await ConsentModel.findOne({ caregiverId }).lean();
    return res.status(200).json({ consent: consent || null });
  } catch (err) {
    console.error("getConsentByCaregiver:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// Save (create/update) the caregiver's digital wellbeing consent decision
export const saveConsentDecision = async (req, res) => {
  try {
    const { caregiverId, decision } = req.body;

    if (!caregiverId || !decision) {
      return res.status(400).json({ message: "caregiverId and decision required" });
    }

    // Decision validation: only allow two accepted values
    //    - "allow"  => caregiver grants consent
    //    - "cancel" => caregiver declines/revokes consent
    if (!["allow", "cancel"].includes(decision)) {
      return res.status(400).json({ message: "decision must be allow or cancel" });
    }

    const now = new Date();
    const allow = decision === "allow";

    // Prepare consent update data
    const update = {
      caregiverId,
      digital_wellbeing_consent: allow,
      is_active: allow,
      granted_at: allow ? now : null,
      revoked_at: allow ? null : now,
    };

    // Create or update consent record
    const consent = await ConsentModel.findOneAndUpdate(
      { caregiverId },
      { $set: update },
      { upsert: true, new: true }
    );

    return res.status(200).json({
      message: allow ? "Consent granted" : "Consent declined",
      consent,
    });
  } catch (err) {
    console.error("saveConsentDecision:", err);
    return res.status(500).json({ message: "Server error" });
  }
};
