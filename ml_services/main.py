from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
ARTIFACT_DIR = BASE_DIR / "cognitive_progress_prediction"

model = joblib.load(ARTIFACT_DIR / "cognitive_progress_model.pkl")
label_encoders = joblib.load(ARTIFACT_DIR / "label_encoders.pkl")

try:
    shap_explainer = joblib.load(ARTIFACT_DIR / "shap_explainer.pkl")
except Exception as e:
    print("⚠️ SHAP explainer load failed:", e)
    shap_explainer = None

app = FastAPI()

# ✅ aligned with dataset columns used for training
FEATURE_COLS = [
    "child_id",
    "age",
    "height_cm",               # ✅ added
    "weight_kg",               # ✅ added
    "gender",
    "diagnosis_type",
    "mood_label",
    "sentiment_score",
    "stress_score_combined",
    "phone_screen_time_mins",
    "sleep_hours",
    "total_tasks_assigned",
    "total_tasks_completed",
    "completion_rate",
    "engagement_minutes",
    "memory_accuracy",
    "attention_accuracy",
    "problem_solving_accuracy",
    "motor_skills_accuracy",
    "average_response_time",
]

CAT_COLS = ["child_id", "gender", "diagnosis_type", "mood_label"]

class InputRecord(BaseModel):
    child_id: str
    age: int
    height_cm: int          # ✅ added
    weight_kg: float        # ✅ added
    gender: str
    diagnosis_type: str
    mood_label: str
    sentiment_score: float
    stress_score_combined: float
    phone_screen_time_mins: int
    sleep_hours: float
    total_tasks_assigned: int
    total_tasks_completed: int
    completion_rate: float
    engagement_minutes: float
    memory_accuracy: float
    attention_accuracy: float
    problem_solving_accuracy: float
    motor_skills_accuracy: float
    average_response_time: float

@app.post("/predict")
def predict_progress(record: InputRecord):
    try:
        data = record.dict()

        # encode categoricals
        for col in CAT_COLS:
            le = label_encoders.get(col)
            if le is None:
                continue
            val = str(data[col])
            try:
                data[col] = int(le.transform([val])[0])
            except Exception:
                data[col] = int(le.transform([le.classes_[0]])[0])

        df = pd.DataFrame([[data[c] for c in FEATURE_COLS]], columns=FEATURE_COLS)

        pred = float(model.predict(df)[0])

        # ✅ return target-like name (matches training target)
        response = {"cognitive_progress_score_next_14_days": pred}

        # SHAP top 5
        if shap_explainer is not None:
            shap_vals = shap_explainer.shap_values(df)
            if isinstance(shap_vals, list):
                shap_vals = shap_vals[0]

            shap_row = shap_vals[0]
            importance = sorted(
                [
                    {"feature": f, "value": float(df[f].iloc[0]), "impact": float(s)}
                    for f, s in zip(FEATURE_COLS, shap_row)
                ],
                key=lambda x: abs(x["impact"]),
                reverse=True,
            )[:5]
            response["top_factors"] = importance

        return response

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def read_root():
    return {"message": "Cognitive Progress Prediction Service is running."}
