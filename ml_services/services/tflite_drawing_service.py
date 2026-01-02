# services/tflite_drawing_service.py
import io
import json
from pathlib import Path

import numpy as np
import tensorflow as tf
from PIL import Image


class TFLiteDrawingService:
    def __init__(self, model_path: Path, labels_path: Path, img_size=(224, 224)):
        self.model_path = Path(model_path)
        self.labels_path = Path(labels_path)
        self.img_size = img_size

        # Validate files
        if not self.model_path.exists():
            raise FileNotFoundError(f"❌ Model file not found: {self.model_path}")
        if not self.labels_path.exists():
            raise FileNotFoundError(f"❌ Labels file not found: {self.labels_path}")

        # Load labels
        self.labels = self._load_labels(self.labels_path)

        # Load interpreter
        self.interpreter = tf.lite.Interpreter(model_path=str(self.model_path))
        self.interpreter.allocate_tensors()
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

    def _load_labels(self, path: Path):
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Case 1: direct list ["a.apple","b.bag",...]
        if isinstance(data, list):
            return [str(x) for x in data]

        if isinstance(data, dict):
            # Case 2: wrapped list {"classes":[...]} or {"labels":[...]} or {"class_names":[...]}
            for key in ["classes", "labels", "class_names"]:
                if key in data and isinstance(data[key], list):
                    return [str(x) for x in data[key]]

            # Case 3: idx_to_class dict {"0":"a.apple","1":"b.bag"}
            if "idx_to_class" in data and isinstance(data["idx_to_class"], dict):
                m = data["idx_to_class"]
                return [
                    v for k, v in sorted(((int(k), str(v)) for k, v in m.items()), key=lambda x: x[0])
                ]

            # Case 4: class_to_idx dict {"a.apple":0,"b.bag":1}
            if "class_to_idx" in data and isinstance(data["class_to_idx"], dict):
                m = data["class_to_idx"]
                return [
                    k for k, v in sorted(((str(k), int(v)) for k, v in m.items()), key=lambda x: x[1])
                ]

            # Case 5a: plain dict index->label
            if all(str(k).isdigit() for k in data.keys()):
                return [
                    v for k, v in sorted(((int(k), str(v)) for k, v in data.items()), key=lambda x: x[0])
                ]

            # Case 5b: plain dict label->index
            try:
                return [
                    k for k, v in sorted(((str(k), int(v)) for k, v in data.items()), key=lambda x: x[1])
                ]
            except Exception:
                pass

        raise ValueError(f"Unsupported labels JSON format: {path}")

    def preprocess_image(self, image_bytes: bytes):
        im = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        im = im.resize(self.img_size)
        arr = np.array(im).astype(np.float32) / 255.0
        arr = np.expand_dims(arr, axis=0)  # [1,H,W,3]
        return arr

    def predict_topk(self, image_bytes: bytes, k: int = 3):
        x = self.preprocess_image(image_bytes)

        # Run inference
        self.interpreter.set_tensor(self.input_details[0]["index"], x)
        self.interpreter.invoke()
        preds = self.interpreter.get_tensor(self.output_details[0]["index"])[0]  # [num_classes]

        k = max(1, min(k, len(preds)))
        top_idx = np.argsort(preds)[-k:][::-1].tolist()

        top = [
            {"label": self.labels[i], "confidence": float(preds[i] * 100.0)}
            for i in top_idx
        ]

        return {"top1": top[0], "topk": top}
