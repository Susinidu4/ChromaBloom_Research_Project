from pathlib import Path

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from cognitive_service import CognitiveProgressService

BASE_DIR = Path(__file__).resolve().parent
ARTIFACT_DIR = BASE_DIR / "cognitive_progress_prediction"

service = CognitiveProgressService(artifact_dir=ARTIFACT_DIR)

app = FastAPI()


class InputRecord(BaseModel):
    child_id: str
    age: int
    height_cm: int
    weight_kg: float
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
        return service.predict(record.model_dump())
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/")
def read_root():
    return {"message": "Cognitive Progress Prediction Service is running."}
