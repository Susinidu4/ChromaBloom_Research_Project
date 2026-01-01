from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import numpy as np
import tensorflow as tf
from pathlib import Path

# ✅ Always load model using absolute path
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "stress_level_model.keras"

try:
    model = tf.keras.models.load_model(MODEL_PATH)
except Exception as e:
    raise RuntimeError(f"Failed to load model at {MODEL_PATH}: {e}")

# 0..3 mapping (what you requested)
IDX_TO_LEVEL_LOWER = {0: "low", 1: "medium", 2: "high", 3: "critical"}
IDX_TO_LEVEL_TITLE = {0: "Low", 1: "Medium", 2: "High", 3: "Critical"}

# ⚠️ MUST match training encoding
MOOD_MAP = {
    "happy": 0, "calm": 1, "neutral": 2, "tired": 3, "sad": 4, "angry": 5, "stressed": 6
}

SLEEP_QUALITY_MAP = {
    "poor": 0, "fair": 1, "good": 2, "excellent": 3
}

class PredictRequest(BaseModel):
    total_screen_time_min: float = Field(..., ge=0)
    night_usage_min: float = Field(..., ge=0)
    unlock_count: float = Field(..., ge=0)
    app_opened_times_count: float = Field(..., ge=0)
    social_media_min: float = Field(..., ge=0)
    video_apps_min: float = Field(..., ge=0)
    late_night_usage_flag: bool
    mood: str
    sleep_quality: str
    journal_sentiment: float

app = FastAPI()

def preprocess(req: PredictRequest) -> np.ndarray:
    late_flag = 1.0 if req.late_night_usage_flag else 0.0

    mood_key = (req.mood or "neutral").strip().lower()
    sleep_key = (req.sleep_quality or "good").strip().lower()

    mood_val = MOOD_MAP.get(mood_key, MOOD_MAP["neutral"])
    sleep_val = SLEEP_QUALITY_MAP.get(sleep_key, SLEEP_QUALITY_MAP["good"])

    x = np.array([[
        req.total_screen_time_min,
        req.night_usage_min,
        req.unlock_count,
        req.app_opened_times_count,
        req.social_media_min,
        req.video_apps_min,
        late_flag,
        mood_val,
        sleep_val,
        req.journal_sentiment
    ]], dtype=np.float32)

    return x

@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": True, "model_path": str(MODEL_PATH)}

@app.post("/predict")
def predict(req: PredictRequest):
    try:
        x = preprocess(req)
        y = model.predict(x, verbose=0)
        y = np.array(y)

        # If model outputs class probabilities [1,4]
        if y.ndim == 2 and y.shape[1] == 4:
            probs = y[0]
            stress_score = int(np.argmax(probs))
            stress_probability = float(probs[stress_score])
        else:
            # If model outputs a single value, clamp to 0..3
            stress_score = int(round(float(y.flatten()[0])))
            stress_score = max(0, min(3, stress_score))
            stress_probability = 0.0

        return {
            "stress_score": stress_score,                    # ✅ 0..3
            "stress_level_lower": IDX_TO_LEVEL_LOWER[stress_score],  # low/medium/high/critical
            "stress_level": IDX_TO_LEVEL_TITLE[stress_score],        # Low/Medium/High/Critical
            "stress_probability": stress_probability,
            "raw": y.tolist()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
