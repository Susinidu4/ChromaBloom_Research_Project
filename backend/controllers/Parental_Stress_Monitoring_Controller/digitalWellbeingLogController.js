import DigitalWellbeingLog from "../../models/Parental_Stress_Monitoring_Model/digitalWellbeingLogModel.js";

// ------------------------- Caregiver -------------------------- //

// Create or update a digital wellbeing log entry for a caregiver
export const createDigitalWellbeingLog = async (req, res) => {
  try {
    // Read digital wellbeing data from request body
    const {
      caregiverId,
      log_date,
      total_screen_time_min,
      night_usage_min,
      unlock_count,
      app_opened_times_count,
      social_media_min,
      video_apps_min,
      late_night_usage_flag,
      sleep_quality,
    } = req.body;

    if (!caregiverId || !log_date) {
      return res
        .status(400)
        .json({ message: "caregiverId and log_date required" });
    }

    // Update existing log or create new one for the day
    const log = await DigitalWellbeingLog.findOneAndUpdate(
      { caregiverId, log_date }, // find log by caregiver and date
      {
        caregiverId,
        log_date,
        total_screen_time_min,
        night_usage_min,
        unlock_count,
        app_opened_times_count,
        social_media_min,
        video_apps_min,
        late_night_usage_flag,
        sleep_quality,
      },
      {
        new: true,
        upsert: true,
      },
    );

    return res
      .status(201)
      .json({ message: "Digital wellbeing log saved", log });
  } catch (err) {
    console.error("createDigitalWellbeingLog:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: String(err) });
  }
};


//get digital wellbeing logs by caregiverId
export const getDigitalWellbeingLogsByCaregiverId = async (req, res) => {
  try {
    const { caregiverId } = req.params;
    const logs = await DigitalWellbeingLog.find({ caregiverId }).sort({
      log_date: -1,
    });
    return res.status(200).json({ logs });
  } catch (err) {
    console.error("getDigitalWellbeingLogsByCaregiverId:", err);
    return res.status(500).json({ message: "Server error", error: String(err) });
  }
};