from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any
from pathlib import Path

from services.cognitive_progress_service import CognitiveProgressService
from services.tflite_drawing_service import TFLiteDrawingService

from services.routine_difficulty_service import RoutineDifficultyService


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # DEV ONLY
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "cognitive_progress_prediction" / "best_cognitive_progress_model.pkl"

service = CognitiveProgressService(MODEL_PATH)

## Cognitive Progress Prediction part
class PredictRequest(BaseModel):
    features: Dict[str, Any]
    top_k: int = 10


@app.get("/health")
def health():
    return service.health()


@app.post("/predict")
def predict(req: PredictRequest):
    return service.predict(features=req.features, top_k=req.top_k)


## Drawing prediction part
MODEL_PATH_DRAWING = BASE_DIR / "gemified" / "chromabloom_model.tflite"
LABELS_PATH_DRAWING = BASE_DIR / "gemified" / "class_labels.json"

# ✅ Create service once (loaded at startup)
drawing_service = TFLiteDrawingService(
    model_path=MODEL_PATH_DRAWING,
    labels_path=LABELS_PATH_DRAWING,
    img_size=(224, 224),
)

@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_found": drawing_service.model_path.exists(),
        "labels_found": drawing_service.labels_path.exists(),
        "labels_count": len(drawing_service.labels),
    }

@app.post("/drawing/predict")
async def predict(file: UploadFile = File(...)):
    image_bytes = await file.read()
    result = drawing_service.predict_topk(image_bytes, k=3)
    return {"top1": result["top1"], "top3": result["topk"]}


# -------------------------------
# Interactive Visual Task Scheduler (Routine Difficulty)
# -------------------------------
ROUTINE_DIR = BASE_DIR / "interactive_visual_task_scheduler"

routine_service = RoutineDifficultyService(ROUTINE_DIR)

class RoutinePredictRequest(BaseModel):
    childId: str
    avg_completion_rate: float
    avg_skepped_steps: float
    avg_duration_minutes: float
    runs_count: int
    completion_rate_trend: float
    current_difficulty_level: str

@app.get("/routine/health")
def routine_health():
    return {
        "status": "ok",
        "routine_model_found": (ROUTINE_DIR / "routine_difficulty_lgbm_model.joblib").exists(),
        "current_encoder_found": (ROUTINE_DIR / "current_level_encoder.joblib").exists(),
        "next_encoder_found": (ROUTINE_DIR / "next_level_encoder.joblib").exists(),
    }

@app.post("/routine/predict-difficulty")
def routine_predict_difficulty(req: RoutinePredictRequest):
    next_level = routine_service.predict_next_level(req.model_dump())
    return {
        "childId": req.childId,
        "next_difficulty_level": next_level
    }


# -------------------------------
# Interactive Visual Task Scheduler
# -------------------------------
ROUTINE_DIR = BASE_DIR / "interactive_visual_task_scheduler"
routine_service = RoutineDifficultyService(ROUTINE_DIR)

class RoutinePredictRequest(BaseModel):
    childId: str
    avg_completion_rate: float
    avg_skepped_steps: float
    avg_duration_minutes: float
    runs_count: int
    completion_rate_trend: float
    current_difficulty_level: str

@app.get("/routine/health")
def routine_health():
    return {
        "status": "ok",
        "routine_model_found": (ROUTINE_DIR / "routine_difficulty_lgbm_model.joblib").exists(),
        "current_encoder_found": (ROUTINE_DIR / "current_level_encoder.joblib").exists(),
        "next_encoder_found": (ROUTINE_DIR / "next_level_encoder.joblib").exists(),
    }

@app.post("/routine/predict-difficulty")
def routine_predict_difficulty(req: RoutinePredictRequest):
    result = routine_service.predict_next_level(req.model_dump())
    return {
        "childId": req.childId,
        **result
    }
