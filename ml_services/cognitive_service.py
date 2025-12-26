from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List, Optional

import joblib
import pandas as pd


class CognitiveProgressService:
    def __init__(self, artifact_dir: Path):
        self.artifact_dir = artifact_dir

        self.model = joblib.load(self.artifact_dir / "cognitive_progress_model.pkl")
        self.label_encoders: Dict[str, Any] = joblib.load(self.artifact_dir / "label_encoders.pkl")

        try:
            self.shap_explainer = joblib.load(self.artifact_dir / "shap_explainer.pkl")
        except Exception as e:
            print("⚠️ SHAP explainer load failed:", e)
            self.shap_explainer = None

        # ✅ aligned with dataset columns used for training
        self.FEATURE_COLS: List[str] = [
            "child_id",
            "age",
            "height_cm",
            "weight_kg",
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

        self.CAT_COLS: List[str] = ["child_id", "gender", "diagnosis_type", "mood_label"]

    def _encode_categoricals(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Encode categorical columns using stored LabelEncoders.
        If unseen category appears, fallback to first known class.
        """
        out = dict(data)
        for col in self.CAT_COLS:
            le = self.label_encoders.get(col)
            if le is None:
                continue

            val = str(out.get(col, ""))
            try:
                out[col] = int(le.transform([val])[0])
            except Exception:
                out[col] = int(le.transform([le.classes_[0]])[0])
        return out

    def _to_dataframe(self, data: Dict[str, Any]) -> pd.DataFrame:
        row = [data[c] for c in self.FEATURE_COLS]
        return pd.DataFrame([row], columns=self.FEATURE_COLS)

    def predict(self, record_dict: Dict[str, Any]) -> Dict[str, Any]:
        """Return prediction + (optional) SHAP top factors."""
        data = self._encode_categoricals(record_dict)
        df = self._to_dataframe(data)

        pred = float(self.model.predict(df)[0])

        response: Dict[str, Any] = {
            "cognitive_progress_score_next_14_days": pred
        }

        # SHAP top 5
        if self.shap_explainer is not None:
            shap_vals = self.shap_explainer.shap_values(df)
            if isinstance(shap_vals, list):
                shap_vals = shap_vals[0]

            shap_row = shap_vals[0]
            importance = sorted(
                [
                    {"feature": f, "value": float(df[f].iloc[0]), "impact": float(s)}
                    for f, s in zip(self.FEATURE_COLS, shap_row)
                ],
                key=lambda x: abs(x["impact"]),
                reverse=True,
            )[:5]
            response["top_factors"] = importance

        return response
