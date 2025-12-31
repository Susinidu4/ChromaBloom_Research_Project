from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import numpy as np
import tensorflow as tf
import json
import io
from pathlib import Path

app = FastAPI()

# -----------------------------
# CORS (allow Flutter Web/Mobile)
# -----------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # DEV ONLY. Later: ["http://localhost:xxxx", "https://yourdomain.com"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Paths (based on app.py location)
# -----------------------------
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "gemified" / "chromabloom_model.tflite"
LABELS_PATH = BASE_DIR / "gemified" / "class_labels.json"

print("✅ BASE_DIR   :", BASE_DIR)
print("✅ MODEL_PATH :", MODEL_PATH)
print("✅ LABELS_PATH:", LABELS_PATH)

# -----------------------------
# Load labels (supports many JSON formats)
# -----------------------------
def load_labels(path: Path):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Case 1: direct list ["a.apple","b.bag",...]
    if isinstance(data, list):
        return [str(x) for x in data]

    # Case 2: wrapped list {"classes":[...]} or {"labels":[...]} or {"class_names":[...]}
    if isinstance(data, dict):
        for key in ["classes", "labels", "class_names"]:
            if key in data and isinstance(data[key], list):
                return [str(x) for x in data[key]]

        # Case 3: idx_to_class dict {"0":"a.apple","1":"b.bag"}
        if "idx_to_class" in data and isinstance(data["idx_to_class"], dict):
            m = data["idx_to_class"]
            return [v for k, v in sorted(((int(k), str(v)) for k, v in m.items()), key=lambda x: x[0])]

        # Case 4: class_to_idx dict {"a.apple":0,"b.bag":1}
        if "class_to_idx" in data and isinstance(data["class_to_idx"], dict):
            m = data["class_to_idx"]
            return [k for k, v in sorted(((str(k), int(v)) for k, v in m.items()), key=lambda x: x[1])]

        # Case 5a: plain dict index->label
        if all(str(k).isdigit() for k in data.keys()):
            return [v for k, v in sorted(((int(k), str(v)) for k, v in data.items()), key=lambda x: x[0])]

        # Case 5b: plain dict label->index
        try:
            return [k for k, v in sorted(((str(k), int(v)) for k, v in data.items()), key=lambda x: x[1])]
        except Exception:
            pass

    raise ValueError(f"Unsupported labels JSON format: {path}")


# -----------------------------
# Validate files exist
# -----------------------------
if not MODEL_PATH.exists():
    raise FileNotFoundError(f"❌ Model file not found: {MODEL_PATH}")

if not LABELS_PATH.exists():
    raise FileNotFoundError(f"❌ Labels file not found: {LABELS_PATH}")

labels = load_labels(LABELS_PATH)
print(f"✅ Loaded labels: {len(labels)} classes")

# -----------------------------
# Load TFLite interpreter
# -----------------------------
interpreter = tf.lite.Interpreter(model_path=str(MODEL_PATH))
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Expect [1,224,224,3] float input usually
print("✅ Input details :", input_details)
print("✅ Output details:", output_details)

# -----------------------------
# Image preprocessing
# -----------------------------
def preprocess_image(image_bytes: bytes):
    im = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    im = im.resize((224, 224))
    arr = np.array(im).astype(np.float32) / 255.0  # normalize like training
    arr = np.expand_dims(arr, axis=0)              # [1,224,224,3]
    return arr

# -----------------------------
# Routes
# -----------------------------
@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_found": MODEL_PATH.exists(),
        "labels_found": LABELS_PATH.exists(),
        "labels_count": len(labels),
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    image_bytes = await file.read()
    x = preprocess_image(image_bytes)

    # Run inference
    interpreter.set_tensor(input_details[0]["index"], x)
    interpreter.invoke()
    preds = interpreter.get_tensor(output_details[0]["index"])[0]  # [num_classes]

    # Top-3
    top3_idx = np.argsort(preds)[-3:][::-1].tolist()
    top3 = [
        {"label": labels[i], "confidence": float(preds[i] * 100.0)}
        for i in top3_idx
    ]

    return {"top1": top3[0], "top3": top3}
