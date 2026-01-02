from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np

app = FastAPI(title="ChromaBloom Difficulty ML")

# Load model + encoders (put files in same folder as app.py)
model = joblib.load("routine_difficulty_lgbm_model.joblib")
current_enc = joblib.load("current_level_encoder.joblib")
next_enc = joblib.load("next_level_encoder.joblib")

class PredictReq(BaseModel):
    childId: str
    avg_completion_rate: float
    avg_skepped_steps: float
    avg_duration_minutes: float
    runs_count: int
    completion_rate_trend: float
    current_difficulty_level: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict-difficulty")
def predict(req: PredictReq):
    try:
        # Encode current difficulty
        cur_encoded = current_enc.transform([req.current_difficulty_level])[0]

        # Build feature vector in the SAME ORDER you trained the model
        X = np.array([[
            req.avg_completion_rate,
            req.avg_skepped_steps,
            req.avg_duration_minutes,
            req.runs_count,
            req.completion_rate_trend,
            cur_encoded
        ]], dtype=float)

        # Predict (usually returns encoded class)
        pred_encoded = model.predict(X)

        # LightGBM sometimes returns float; convert to int safely
        pred_encoded = int(round(float(pred_encoded[0])))

        # Decode next difficulty
        next_level = next_enc.inverse_transform([pred_encoded])[0]

        return {
            "childId": req.childId,
            "next_difficulty_level": str(next_level)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
