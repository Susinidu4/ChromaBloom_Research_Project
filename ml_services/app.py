from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List
import joblib
import numpy as np
import shap
import pandas as pd
from pathlib import Path

app = FastAPI(title="Cognitive Progress ML Service")

BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "cognitive_progress_prediction"
MODEL_PATH = MODEL_DIR / "best_cognitive_progress_model.pkl"

try:
    pipe = joblib.load(MODEL_PATH)
except Exception as e:
    raise RuntimeError(f"❌ Failed to load model from {MODEL_PATH}: {e}")

prep = pipe.named_steps["prep"]
model = pipe.named_steps["model"]

explainer = shap.TreeExplainer(model)

class PredictRequest(BaseModel):
    features: Dict[str, Any]
    top_k: int = 10

@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_loaded": True,
        "model_path": str(MODEL_PATH),
    }

def get_expected_input_columns(pipeline) -> List[str]:
    # sklearn pipelines store original training columns here (if available)
    cols = getattr(pipeline, "feature_names_in_", None)
    if cols is None:
        return []
    return list(cols)

def get_feature_names(preprocessor):
    feature_names = []
    for name, transformer, columns in preprocessor.transformers_:
        if name == "cat":
            ohe = transformer
            feature_names.extend(list(ohe.get_feature_names_out(columns)))
        elif name == "num":
            feature_names.extend(list(columns))
    return feature_names

@app.post("/predict")
def predict(req: PredictRequest):
    try:
        X = pd.DataFrame([req.features])

        # ✅ Validate missing columns against training schema
        expected_cols = get_expected_input_columns(pipe)
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

        prediction = float(pipe.predict(X)[0])

        X_encoded = prep.transform(X)
        shap_values = explainer.shap_values(X_encoded)

        shap_row = np.array(shap_values)[0]
        feature_names = get_feature_names(prep)

        idx_sorted = np.argsort(np.abs(shap_row))[::-1][: req.top_k]

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
