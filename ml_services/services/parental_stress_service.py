from pathlib import Path
import json
import joblib
import numpy as np
import pandas as pd
import tensorflow as tf


class ParentalStressService:
    IDX_TO_LEVEL = {0: "Low", 1: "Medium", 2: "High", 3: "Critical"}
    IDX_TO_LEVEL_LOWER = {0: "low", 1: "medium", 2: "high", 3: "critical"}

    def __init__(self, base_dir: Path | None = None):
        # base_dir should point to ml_services/parental_stress_monitoring
        if base_dir is None:
            base_dir = (
                Path(__file__).resolve().parent.parent / "parental_stress_monitoring"
            )

        self.base_dir = base_dir
        self.model_path = base_dir / "stress_level_model.keras"
        self.preprocessor_path = base_dir / "preprocessor.joblib"
        self.meta_path = base_dir / "meta.json"

        # Load artifacts
        self.model = tf.keras.models.load_model(self.model_path)
        self.preprocessor = joblib.load(self.preprocessor_path)

        meta = json.loads(self.meta_path.read_text(encoding="utf-8"))
        self.feature_cols = meta["feature_cols"]

    def health(self) -> dict:
        return {
            "status": "ok",
            "model_found": self.model_path.exists(),
            "preprocessor_found": self.preprocessor_path.exists(),
            "meta_found": self.meta_path.exists(),
            "feature_cols_count": len(self.feature_cols),
        }

    def predict(self, features: dict) -> dict:
        # Build row exactly as training expected (meta feature order)
        row = {
            "total_screen_time_min": features["total_screen_time_min"],
            "night_usage_min": features["night_usage_min"],
            "unlock_count": features["unlock_count"],
            "app_opened_times_count": features["app_opened_times_count"],
            "social_media_min": features["social_media_min"],
            "video_apps_min": features["video_apps_min"],
            "late_night_usage_flag": int(features["late_night_usage_flag"]),
            "mood": (features.get("mood") or "neutral").strip().lower(),
            "sleep_quality": (features.get("sleep_quality") or "good").strip().lower(),
            "journal_sentiment": features["journal_sentiment"],
        }

        X = pd.DataFrame([row], columns=self.feature_cols)

        Xt = self.preprocessor.transform(X)
        if hasattr(Xt, "toarray"):
            Xt = Xt.toarray()

        probs = self.model.predict(Xt, verbose=0)[0]  # shape (4,)
        probs = np.array(probs, dtype=float)

        if probs.ndim != 1 or probs.shape[0] != 4:
            raise ValueError(f"Unexpected model output shape: {probs.shape}")

        stress_score = int(np.argmax(probs))
        stress_probability = float(probs[stress_score])

        return {
            "stress_score": stress_score,
            "stress_level_lower": self.IDX_TO_LEVEL_LOWER[stress_score],
            "stress_level": self.IDX_TO_LEVEL[stress_score],
            "stress_probability": stress_probability,
            "raw": probs.tolist(),
        }
