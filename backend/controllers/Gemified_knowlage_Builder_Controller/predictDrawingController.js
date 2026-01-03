import axios from "axios";
import FormData from "form-data";

// Put this in .env if you want: FASTAPI_BASE_URL=http://127.0.0.1:8000
const FASTAPI_BASE_URL = process.env.FASTAPI_BASE_URL || "http://localhost:8000";

/**
 * POST /chromabloom/gamified/drawing/predict
 * body: multipart/form-data with field "file"
 */
export const predictDrawing = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: "Image file is required (field name: file)",
      });
    }

    // Build multipart form for FastAPI
    const form = new FormData();
    form.append("file", req.file.buffer, {
      filename: req.file.originalname || "image.jpg",
      contentType: req.file.mimetype || "image/jpeg",
    });

    // ✅ Your FastAPI routes are:
    // GET  /health
    // POST /predict
    // (NOT /drawing/predict)
    const response = await axios.post(`${FASTAPI_BASE_URL}/drawing/predict`, form, {
      headers: { ...form.getHeaders() },
      timeout: 30000,
    });

    // FastAPI returns: { top1, top3 }
    // ✅ Return only top1 to Flutter
    return res.status(200).json({
      message: "Prediction success",
      top1: response.data.top1, // { label, confidence }
    });
  } catch (error) {
    if (error.response) {
      return res.status(error.response.status).json({
        error: "FastAPI error",
        details: error.response.data,
      });
    }

    return res.status(500).json({
      error: "Server error calling FastAPI",
      details: error.message,
    });
  }
};

/**
 * GET /chromabloom/gamified/drawing/health
 */
export const drawingModelHealth = async (req, res) => {
  try {
    const response = await axios.get(`${FASTAPI_BASE_URL}/health`, {
      timeout: 10000,
    });

    return res.status(200).json({
      message: "FastAPI health ok",
      data: response.data,
    });
  } catch (error) {
    if (error.response) {
      return res.status(error.response.status).json({
        error: "FastAPI error",
        details: error.response.data,
      });
    }

    return res.status(500).json({
      error: "Server error calling FastAPI health",
      details: error.message,
    });
  }
};
