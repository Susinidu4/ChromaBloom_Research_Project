import axios from "axios";
import FormData from "form-data";

// Put in .env like: FASTAPI_BASE_URL=http://127.0.0.1:8000
const FASTAPI_BASE_URL = process.env.FASTAPI_BASE_URL || "http://127.0.0.1:8000";

/**
 * POST /api/gamified/drawing/predict
 * body: multipart/form-data with field "file"
 */
export const predictDrawing = async (req, res) => {
  try {
    // multer memoryStorage => file is in req.file.buffer
    if (!req.file) {
      return res.status(400).json({ error: "Image file is required (field name: file)" });
    }

    // Build multipart form for FastAPI
    const form = new FormData();
    form.append("file", req.file.buffer, {
      filename: req.file.originalname || "image.jpg",
      contentType: req.file.mimetype || "image/jpeg",
    });

    // Call FastAPI
    const response = await axios.post(`${FASTAPI_BASE_URL}/predict`, form, {
      headers: {
        ...form.getHeaders(),
      },
      timeout: 30000,
    });

    // Return same payload to frontend
    return res.status(200).json({
      message: "Prediction success",
      data: response.data, // { top1, top3 }
    });
  } catch (error) {
    // If FastAPI returned an error
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
 * GET /api/gamified/drawing/health
 */
export const drawingModelHealth = async (req, res) => {
  try {
    const response = await axios.get(`${FASTAPI_BASE_URL}/health`, { timeout: 10000 });
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
