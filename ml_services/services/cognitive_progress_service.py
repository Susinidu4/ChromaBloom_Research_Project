from pathlib import Path
from typing import Dict, Any, List, Optional

import joblib
import numpy as np
import pandas as pd
import shap
from fastapi import HTTPException


class CognitiveProgressService:
    def __init__(self, model_path: Path):
        self.model_path = model_path

        try:
            self.pipe = joblib.load(self.model_path)
        except Exception as e:
            raise RuntimeError(f"❌ Failed to load model from {self.model_path}: {e}")

        # Pipeline steps
        try:
            self.prep = self.pipe.named_steps["prep"]
            self.model = self.pipe.named_steps["model"]
        except Exception as e:
            raise RuntimeError(f"❌ Pipeline must have steps: 'prep' and 'model'. Error: {e}")

        # SHAP (Tree-based models)
        try:
            self.explainer = shap.TreeExplainer(self.model)
        except Exception as e:
            raise RuntimeError(f"❌ Failed to create SHAP explainer: {e}")

    def health(self) -> Dict[str, Any]:
        return {
            "status": "ok",
            "model_loaded": True,
            "model_path": str(self.model_path),
        }

    def _get_expected_input_columns(self) -> List[str]:
        cols = getattr(self.pipe, "feature_names_in_", None)
        return list(cols) if cols is not None else []

    def _get_feature_names(self) -> List[str]:
        """
        Works for a ColumnTransformer with:
          - transformer name "cat" using OneHotEncoder
          - transformer name "num" for numeric columns
        """
        feature_names: List[str] = []
        for name, transformer, columns in self.prep.transformers_:
            if name == "cat":
                ohe = transformer
                feature_names.extend(list(ohe.get_feature_names_out(columns)))
            elif name == "num":
                feature_names.extend(list(columns))
        return feature_names

    def predict(self, features: Dict[str, Any], top_k: int = 10) -> Dict[str, Any]:
        try:
            X = pd.DataFrame([features])

            # ✅ Validate schema
            expected_cols = self._get_expected_input_columns()
            if expected_cols:
                missing_cols = [c for c in expected_cols if c not in X.columns]
                if missing_cols:
                    raise HTTPException(
                        status_code=400,
                        detail={
                            "message": "columns are missing",
                            "missing": missing_cols,
                            "expected_count": len(expected_cols),
                            "received_count": len(X.columns),
                        },
                    )

            prediction = float(self.pipe.predict(X)[0])

            # SHAP
            X_encoded = self.prep.transform(X)
            shap_values = self.explainer.shap_values(X_encoded)

            # single row
            shap_row = np.array(shap_values)[0]
            feature_names = self._get_feature_names()

            # Safety: mismatch guard
            if len(feature_names) != len(shap_row):
                # still return prediction even if explain fails cleanly
                return {
                    "predicted_score_next_14_days": prediction,
                    "explainability": {
                        "top_positive_factors": [],
                        "top_negative_factors": [],
                        "warning": "Feature-name length mismatch with SHAP output",
                    },
                }

            idx_sorted = np.argsort(np.abs(shap_row))[::-1][:top_k]

            factors = [
                {"feature": feature_names[i], "shap_value": float(shap_row[i])}
                for i in idx_sorted
            ]

            positive = [f for f in factors if f["shap_value"] > 0]
            negative = [f for f in factors if f["shap_value"] < 0]

            return {
                "predicted_score_next_14_days": prediction,
                "explainability": {
                    "top_positive_factors": positive,
                    "top_negative_factors": negative,
                },
            }

        except HTTPException as he:
            raise he
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))
