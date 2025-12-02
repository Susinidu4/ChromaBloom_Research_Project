// backend/middlewares/uploadImage.js
import multer from "multer";

const storage = multer.memoryStorage(); // keeps file in RAM buffer

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
});

export default upload;
