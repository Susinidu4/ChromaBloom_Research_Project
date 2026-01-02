from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import numpy as np
import tensorflow as tf
from pathlib import Path
import joblib
import json
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = BASE_DIR / "stress_level_model.keras"
PREPROCESSOR_PATH = BASE_DIR / "preprocessor.joblib"
META_PATH = BASE_DIR / "meta.json"

# ----------------------------
# Load artifacts
# ----------------------------
try:
    model = tf.keras.models.load_model(MODEL_PATH)
except Exception as e:
    raise RuntimeError(f"❌ Failed to load model at {MODEL_PATH}: {e}")

try:
    preprocessor = joblib.load(PREPROCESSOR_PATH)
except Exception as e:
    raise RuntimeError(f"❌ Failed to load preprocessor at {PREPROCESSOR_PATH}: {e}")

try:
    meta = json.loads(META_PATH.read_text())
    feature_cols = meta["feature_cols"]
except Exception as e:
    raise RuntimeError(f"❌ Failed to load meta at {META_PATH}: {e}")

IDX_TO_LEVEL = {0: "Low", 1: "Medium", 2: "High", 3: "Critical"}
IDX_TO_LEVEL_LOWER = {0: "low", 1: "medium", 2: "high", 3: "critical"}

# ----------------------------
# Request schema
# ----------------------------
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


@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_loaded": True,
        "model_path": str(MODEL_PATH),
        "preprocessor_loaded": True,
        "meta_loaded": True
    }


@app.post("/predict")
def predict(req: PredictRequest):
    try:
        # Build row exactly as training expected (meta feature order)
        row = {
            "total_screen_time_min": req.total_screen_time_min,
            "night_usage_min": req.night_usage_min,
            "unlock_count": req.unlock_count,
            "app_opened_times_count": req.app_opened_times_count,
            "social_media_min": req.social_media_min,
            "video_apps_min": req.video_apps_min,
            "late_night_usage_flag": int(req.late_night_usage_flag),  # bool -> 0/1
            "mood": (req.mood or "neutral").strip().lower(),
            "sleep_quality": (req.sleep_quality or "good").strip().lower(),
            "journal_sentiment": req.journal_sentiment
        }

        X = pd.DataFrame([row], columns=feature_cols)

        Xt = preprocessor.transform(X)
        if hasattr(Xt, "toarray"):
            Xt = Xt.toarray()

        probs = model.predict(Xt, verbose=0)[0]  # shape (4,)
        probs = np.array(probs, dtype=float)

        if probs.ndim != 1 or probs.shape[0] != 4:
            raise ValueError(f"Unexpected model output shape: {probs.shape}")

        stress_score = int(np.argmax(probs))
        stress_probability = float(probs[stress_score])

        return {
            "stress_score": stress_score,                      # 0..3
            "stress_level_lower": IDX_TO_LEVEL_LOWER[stress_score],  # low/medium/high/critical
            "stress_level": IDX_TO_LEVEL[stress_score],        # Low/Medium/High/Critical
            "stress_probability": stress_probability,
            "raw": [probs.tolist()]
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
