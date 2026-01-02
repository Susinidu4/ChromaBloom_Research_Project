from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path

from services.tflite_drawing_service import TFLiteDrawingService

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # DEV ONLY
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "gemified" / "chromabloom_model.tflite"
LABELS_PATH = BASE_DIR / "gemified" / "class_labels.json"

# ✅ Create service once (loaded at startup)
drawing_service = TFLiteDrawingService(
    model_path=MODEL_PATH,
    labels_path=LABELS_PATH,
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

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    image_bytes = await file.read()
    result = drawing_service.predict_topk(image_bytes, k=3)
    return {"top1": result["top1"], "top3": result["topk"]}
