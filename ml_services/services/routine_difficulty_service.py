from pathlib import Path
import joblib
import numpy as np

class RoutineDifficultyService:
    def __init__(self, base_dir: Path | None = None):
        # base_dir should point to ml_services/interactive_visual_task_scheduler
        if base_dir is None:
            base_dir = Path(__file__).resolve().parent.parent / "interactive_visual_task_scheduler"

        self.model = joblib.load(base_dir / "routine_difficulty_lgbm_model.joblib")
        self.current_enc = joblib.load(base_dir / "current_level_encoder.joblib")
        self.next_enc = joblib.load(base_dir / "next_level_encoder.joblib")

    def predict_next_level(self, features: dict) -> dict:
        cur_level = features["current_difficulty_level"]
        cur_encoded = self.current_enc.transform([cur_level])[0]

        X = np.array([[
            float(features["avg_completion_rate"]),
            float(features["avg_skepped_steps"]),
            float(features["avg_duration_minutes"]),
            float(features["runs_count"]),
            float(features["completion_rate_trend"]),
            float(cur_encoded),
        ]], dtype=float)

        pred_encoded = self.model.predict(X)
        pred_encoded = int(round(float(pred_encoded[0])))

        next_level = self.next_enc.inverse_transform([pred_encoded])[0]
        return {"next_difficulty_level": str(next_level)}
