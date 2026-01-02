from fastapi import FastAPI
from pydantic import BaseModel
from typing import Dict, Any
from pathlib import Path

from services.cognitive_progress_service import CognitiveProgressService

app = FastAPI(title="Cognitive Progress ML Service")

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "cognitive_progress_prediction" / "best_cognitive_progress_model.pkl"

service = CognitiveProgressService(MODEL_PATH)


class PredictRequest(BaseModel):
    features: Dict[str, Any]
    top_k: int = 10


@app.get("/health")
def health():
    return service.health()


@app.post("/predict")
def predict(req: PredictRequest):
    return service.predict(features=req.features, top_k=req.top_k)
