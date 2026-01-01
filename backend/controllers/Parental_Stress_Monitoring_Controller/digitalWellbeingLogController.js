import DigitalWellbeingLog from "../../models/Parental_Stress_Monitoring_Model/digitalWellbeingLogModel.js";

export const createDigitalWellbeingLog = async (req, res) => {
  try {
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

    // 🔑 UPSERT: update if exists, create if not
    const log = await DigitalWellbeingLog.findOneAndUpdate(
      { caregiverId, log_date }, // find today's record
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
        new: true, // return updated document
        upsert: true, // create if not exists
      }
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
