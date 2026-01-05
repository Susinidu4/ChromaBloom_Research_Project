import DigitalWellbeingLog from "../../models/Parental_Stress_Monitoring_Model/digitalWellbeingLogModel.js";
import JournalEntry from "../../models/Parental_Stress_Monitoring_Model/journalEntryModel.js";
import StressScoreModel from "../../models/Parental_Stress_Monitoring_Model/stressScoreModel.js";
import RecommendationModel from "../../models/Parental_Stress_Monitoring_Model/recommendationModel.js";
import axios from "axios";

const PY_BASE = process.env.PYTHON_SERVICE_URL; // http://localhost:8000
const ML_URL = `${PY_BASE}/stress/predict`;

function toUtcMidnight(dateObj = new Date()) {
  return new Date(
    Date.UTC(
      dateObj.getUTCFullYear(),
      dateObj.getUTCMonth(),
      dateObj.getUTCDate(),
      0,
      0,
      0,
      0
    )
  );
}

function utcDayRange(dateObj = new Date()) {
  const start = new Date(
    Date.UTC(
      dateObj.getUTCFullYear(),
      dateObj.getUTCMonth(),
      dateObj.getUTCDate(),
      0,
      0,
      0,
      0
    )
  );
  const end = new Date(
    Date.UTC(
      dateObj.getUTCFullYear(),
      dateObj.getUTCMonth(),
      dateObj.getUTCDate() + 1,
      0,
      0,
      0,
      0
    )
  );
  return { start, end };
}

function isHighOrCriticalTitle(levelTitle) {
  return levelTitle === "High" || levelTitle === "Critical";
}

export const computeStressAndRecommendation = async (req, res) => {
  try {
    const { caregiverId } = req.params;
    if (!caregiverId)
      return res.status(400).json({ error: "caregiverId required" });

    // 1) latest digital wellbeing
    const wellbeing = await DigitalWellbeingLog.findOne({ caregiverId })
      .sort({ log_date: -1 })
      .lean();

    if (!wellbeing) {
      return res
        .status(404)
        .json({ error: "No DigitalWellbeingLog found for this caregiver" });
    }

    // 2) latest journal entry for TODAY only
    const { start: todayStart, end: todayEnd } = utcDayRange(new Date());

    const journal = await JournalEntry.findOne({
      caregiver_ID: caregiverId,
      created_at: { $gte: todayStart, $lt: todayEnd },
    })
      .sort({ created_at: -1 })
      .lean();

    if (!journal) {
      return res.status(404).json({
        error: "No JournalEntry found for TODAY for this caregiver",
      });
    }

    // 3) ML payload (your 10 features)
    const payload = {
      total_screen_time_min: wellbeing.total_screen_time_min ?? 0,
      night_usage_min: wellbeing.night_usage_min ?? 0,
      unlock_count: wellbeing.unlock_count ?? 0,
      app_opened_times_count: wellbeing.app_opened_times_count ?? 0,
      social_media_min: wellbeing.social_media_min ?? 0,
      video_apps_min: wellbeing.video_apps_min ?? 0,
      late_night_usage_flag: Boolean(wellbeing.late_night_usage_flag),
      mood: journal.mood ?? "neutral",
      sleep_quality: wellbeing.sleep_quality ?? "good",
      journal_sentiment: journal.journal_sentiment ?? 0,
    };

    // 4) Call ML
    const mlResp = await fetch(ML_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!mlResp.ok) {
      const errText = await mlResp.text();
      return res
        .status(500)
        .json({ error: "ML service error", details: errText });
    }

    const ml = await mlResp.json();

    // ✅ your requested outputs
    const stress_score = Number(ml.stress_score); // 0..3
    const stress_level = ml.stress_level; // "Low" | "Medium" | "High" | "Critical"
    const stress_probability = Number(ml.stress_probability ?? 0);

    if (![0, 1, 2, 3].includes(stress_score) || !stress_level) {
      return res.status(500).json({ error: "Invalid ML response", ml });
    }

    // 5) consecutive high/critical days
    const today = toUtcMidnight(new Date());

    const recentScores = await StressScoreModel.find({ caregiverId })
      .sort({ score_date: -1 })
      .limit(14)
      .lean();

    let consecutive_high_days = 0;
    for (const s of recentScores) {
      if (isHighOrCriticalTitle(s.stress_level)) consecutive_high_days += 1;
      else break;
    }

    if (isHighOrCriticalTitle(stress_level)) consecutive_high_days += 1;
    else consecutive_high_days = 0;

    // 6) escalation rule
    const escalation_triggered =
      stress_level === "Critical" ||
      (stress_level === "High" && consecutive_high_days >= 3);

    // 7) save / upsert today’s score
    const computed_at = new Date();

    const savedScore = await StressScoreModel.findOneAndUpdate(
      { caregiverId, score_date: today },
      {
        caregiverId,
        score_date: today,
        computed_at,
        stress_score, // ✅ store numeric too
        stress_level, // ✅ "Low/Medium/High/Critical"
        stress_probability,
        consecutive_high_days,
        escalation_triggered,
      },
      { upsert: true, new: true }
    );

    // 8) recommendation pick (IMPORTANT: match DB casing)
    // Your JSON recommendations use "Level": "Low/Medium/High/Critical" :contentReference[oaicite:2]{index=2}
    const recPool = await RecommendationModel.find({
      level: stress_level, // ✅ Title Case
      is_active: true,
    }).lean();

    let chosen = null;
    if (recPool.length > 0) {
      chosen = recPool[Math.floor(Math.random() * recPool.length)];
    } else {
      chosen = await RecommendationModel.findOne({
        level: "Medium",
        is_active: true,
      }).lean();
      if (!chosen)
        chosen = await RecommendationModel.findOne({
          level: "Low",
          is_active: true,
        }).lean();
    }

    return res.json({
      stress: savedScore,
      recommendation: chosen,
      ml_debug: {
        used_features: payload,
        raw: ml.raw,
      },
    });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ error: "Server error", details: String(err.message || err) });
  }
};
